# 05. Part B — 로컬 실측 시뮬레이션 (문제 현황)

`sql-optimize` 스킬에 따라, 개선 전 문제를 **로컬 MySQL에 실제 데이터를 적재해 EXPLAIN으로 측정**한 기록이다.
(개선안/검증은 확정 후 별도 정리. 본 문서는 *문제 현황* 중심.)

## 실행 환경
- MySQL **9.6.0** (Homebrew, 로컬). DB: `soultalk_test`. 인덱스: **PK만** (과제 초기 상태와 동일).
- 시드 규모(로컬 축소판 — 운영은 users 50만 / chat_rooms 200만):

  | 테이블 | 행 수 | 비고 |
  |---|---|---|
  | users | 50,000 | status 대부분 active |
  | counselors | 5,000 | is_online≈1/3 |
  | chat_rooms | 200,000 | status='ended' 10만 / 최근 30일 ended **8,219** |

- 측정: `EXPLAIN` + `EXPLAIN ANALYZE`(실측 시간). 축소판이라 절대 시간은 작지만 **플랜의 구조적 문제는 동일하게 재현**된다(운영 규모에선 더 극적).

---

## B-2-1 — 일별 상담 완료 통계 (문제 현황)

문제 쿼리: `WHERE DATE_FORMAT(created_at,'%Y-%m-%d') >= ...` / `GROUP BY DATE_FORMAT(...)`.

```
-> Sort: consult_date  (actual time=86.8..86.8 rows=31)
  -> Aggregate using temporary table  (actual time=86.7..86.7 rows=31)
    -> Filter: (status='ended' AND date_format(created_at,'%Y-%m-%d') >= <cache>(...))  (rows=8493)
      -> Table scan on chat_rooms  (cost=20160 rows=199440) (actual time=1.33..46.7 rows=200000)
```

**문제점**
1. **non-SARGable**: WHERE에서 `created_at`을 `DATE_FORMAT()`으로 감싸 인덱스 사용 불가 → `Table scan` **20만 행 전수**.
2. **매 행 함수 평가 + 문자열 비교** 비용(날짜를 문자열로 변환해 비교).
3. status/날짜를 받칠 **인덱스 부재**(PK만).
4. (부차) `GROUP BY DATE_FORMAT(...)` 표현식 그룹화 → `Aggregate using temporary table` + `Sort`.

**측정:** 200,000행 전수 스캔, 실측 **≈86.8ms**.

---

## B-2-2 — 상담사별 누적 완료 상담 (N+1, 문제 현황)

문제 구조: Step1(온라인 상담사 N명) → Step2(`COUNT(*) WHERE counselor_id=? AND status='ended'`)를 **N번 반복**.

```
-- N (온라인+활성 상담사 수) = 1,500  → COUNT 쿼리가 1,500번 반복
-- (참고) 단일 쿼리로 합쳐도 B-2-2 인덱스가 없으면:
-> Sort: total_chat_count DESC  (actual time=1114..1114 rows=1500)
  -> Table scan on c  (rows=5000)                      ← counselors 풀스캔(is_online 인덱스 없음)
  -> Aggregate using temporary table  (actual time=1067)
    -> Index lookup on chat_rooms (status='ended')  (rows≈99720, actual rows=100000)  ← ended 10만 행 그룹화
```

**문제점**
1. **N+1 쿼리**: 1 + **1,500**회 왕복. 쿼리 파싱·네트워크 오버헤드가 곱으로 증가 → 단일 쿼리화 필요.
2. **counselor_id+status를 받칠 인덱스 부재** → 집계가 임시테이블 경유(ended 10만 그룹화).
3. **counselors `is_online` 인덱스 부재** → counselors 풀스캔.
4. **결과셋 불일치**: 요구 컬럼은 `user_id, nickname, gender, birth_year, total_chat_count`인데 Step1은 `c.id, tier, fee_per_30sec, rating`을 조회 → users 기준으로 재구성 필요.

**측정:** N=1,500(왕복), 단일 쿼리(무인덱스) 실측 **≈1,114ms**.

---

## 진단 요약
- **B-2-1**: "컬럼 가공 금지 → 범위 조건으로 SARGable화 + 복합 인덱스".
- **B-2-2**: "N+1 → 사전집계 단일 쿼리 + 그룹화/필터용 인덱스 + 요구 결과셋 정합".

> 개선 쿼리·인덱스와 after 측정은 방향 확정 후 `sql/queries_b.sql`과 `REPORT.md`에 정리한다.
