# 02. Part B — MySQL 쿼리 분석

> 작성 위치: `sql/queries_b.sql`의 `[개선된 쿼리]`/`[CREATE INDEX]` 자리.
> 상단 스키마 블록은 **수정 금지**. 근거는 `REPORT.md`에 정리.
> 규모: `users`(~50만), `counselors`(~5천), `chat_rooms`(~200만), 인덱스 **PK만 존재**.

---

## B-2-1. 일별 상담 완료 통계 (응답 5초+)

### 문제 쿼리
```sql
SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS consult_date, COUNT(*) ...
FROM chat_rooms
WHERE DATE_FORMAT(created_at, '%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 30 DAY), '%Y-%m-%d')
  AND status = 'ended'
GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
ORDER BY consult_date;
```

### 진단
1. **컬럼을 함수로 감쌈(`DATE_FORMAT(created_at, ...)`)** → `created_at`에 인덱스가 있어도 **SARGable 하지 않아** 인덱스 레인지 스캔 불가. 200만 행 풀스캔.
2. **WHERE 안에서 매 행 `DATE_FORMAT` 평가** → 함수 호출 비용.
3. 인덱스 PK뿐 → status/날짜 필터를 받쳐줄 인덱스 자체가 없음.

### 개선 방향
- 날짜 조건을 **범위 조건**으로 바꿔 컬럼을 가공하지 않게:
  `WHERE created_at >= (CURDATE() - INTERVAL 29 DAY) AND created_at < (CURDATE() + INTERVAL 1 DAY)`
  - "최근 30일"의 정의(오늘 포함 30일 vs 30일 전~지금)는 요구사항에 맞춰 확정 — 본 과제는 *날짜별*이므로 `CURDATE()` 기준 일 경계 정렬이 깔끔.
- `status='ended'`를 인덱스 선두에 두면 등치 조건으로 먼저 좁히고 날짜 범위 스캔.
- GROUP BY/ORDER BY는 `DATE(created_at)` 또는 `DATE_FORMAT` 유지 가능(집계 키이므로 인덱스 영향 적음). SELECT 표현식과 일치시킴.

### 개선 쿼리(초안)
```sql
SELECT DATE(created_at)              AS consult_date,
       COUNT(*)                      AS consult_count,
       AVG(total_billed_cookies)     AS avg_cookies
FROM chat_rooms
WHERE status = 'ended'
  AND created_at >= (CURDATE() - INTERVAL 29 DAY)
  AND created_at <  (CURDATE() + INTERVAL 1 DAY)
GROUP BY DATE(created_at)
ORDER BY consult_date;
```

### 인덱스(초안)
```sql
CREATE INDEX idx_chat_rooms_status_created
  ON chat_rooms (status, created_at);
```
- 선두 `status` 등치 → `created_at` 범위 → 복합 인덱스로 필터+정렬 동시 활용.
- (선택) 커버링까지 노리면 `(status, created_at, total_billed_cookies)` 검토 — 트레이드오프(쓰기·저장 비용)는 REPORT에 기술.

---

## B-2-2. 상담사 목록 N+1 → 단일 쿼리

### 문제: Step1으로 N명 뽑고 각자 COUNT를 N번 재실행 → N+1.

### 요구 결과셋
- 컬럼: `user_id, nickname, gender, birth_year, total_chat_count`
- 정렬: `total_chat_count DESC`
- (주의) Step1은 온라인 상담사이지만 **요구 컬럼은 users 기준(user_id, gender, birth_year)** → counselors와 users 조인 필요. tier/fee/rating은 최종 결과셋에 불필요.

### 개선 방향
- COUNT를 **상관 서브쿼리 대신 사전 집계 후 JOIN**:
  `chat_rooms`를 `counselor_id`로 `status='ended'`만 group by한 파생 테이블과 조인.
- 온라인+활성 필터(`c.is_online=1`, `u.status='active'`)는 그대로.
- 상담사가 완료 상담 0건이어도 목록에 나와야 하면 `LEFT JOIN` + `COALESCE(...,0)`. (요구사항 해석에 따라 결정 — REPORT에 명시)

### 개선 쿼리(초안, LEFT JOIN 안)
```sql
SELECT u.id              AS user_id,
       u.nickname,
       u.gender,
       u.birth_year,
       COALESCE(cc.total_chat_count, 0) AS total_chat_count
FROM counselors c
JOIN users u ON u.id = c.user_id
LEFT JOIN (
    SELECT counselor_id, COUNT(*) AS total_chat_count
    FROM chat_rooms
    WHERE status = 'ended'
    GROUP BY counselor_id
) cc ON cc.counselor_id = c.id
WHERE c.is_online = 1
  AND u.status = 'active'
ORDER BY total_chat_count DESC;
```

### 인덱스(초안)
```sql
CREATE INDEX idx_chat_rooms_counselor_status
  ON chat_rooms (counselor_id, status);     -- 파생 집계 가속
CREATE INDEX idx_counselors_online ON counselors (is_online); -- 온라인 5천 중 필터
-- users.status, counselors.user_id(UNIQUE 이미 인덱스), 조인 키 점검
```
- `(counselor_id, status)`: 파생 테이블의 group by + status 필터를 인덱스로 처리.
- B-2-1의 `(status, created_at)`와 컬럼 순서가 다른 이유(선두 컬럼 카디널리티/접근 패턴)도 REPORT에서 설명하면 가점.

---

## 공통 검증 아이디어
- `EXPLAIN`(가능하면 `EXPLAIN ANALYZE`)으로 before/after type(ALL→range/ref), rows, Extra(Using filesort/temporary) 비교를 REPORT에 첨부하면 설득력↑.
- 실제 MySQL 환경이 없으면 논리적 근거 + EXPLAIN 예상으로 기술.
