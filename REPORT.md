# 코딩 테스트 제출 리포트

---

## Part A — Flutter 버그 수정

### 수정한 버그 목록

| # | 파일 경로 | 수정 내용 | 원인 분석 |
|---|-----------|-----------|-----------|
| 1 | `lib/app/me_state.dart` | `removeFavoriteCounselor`의 필터 조건을 `id == counselorId` → `id != counselorId` | 삭제인데 "대상만 남기는" 조건이라, 하트 해제 시 해제 대상은 남고 나머지 즐겨찾기가 모두 사라짐. 삭제 의미에 맞게 부정 조건으로 정정. (재현 테스트: `test/me_state_test.dart`, PR #1 red→green) |
| 2 | `lib/pages/chats/consultation_room_page.dart` | `dispose`에 `_messageSubscription?.cancel()` 추가 | 10초 주기 실시간 스트림 구독을 dispose에서 해제하지 않아, 채팅방을 벗어난 뒤에도 타이머가 계속 동작하는 리소스 누수. 이 누수가 채팅방 관련 widget 테스트를 종료 시 'Timer pending'으로 모두 실패시켜, 다른 채팅 버그(A-2/3/4/6)보다 먼저 수정함. (재현 테스트: `test/consultation_room_page_test.dart`, PR #2 red→green) |
| 3 | | | |
| 4 | | | |
| 5 | | | |

### 기타 의견

(선택) 수정하면서 느낀 점, 추가로 개선하고 싶었던 부분 등 자유롭게 작성해주세요.

---

## Part B — SQL 쿼리 개선

### B-2-1. 일별 상담 완료 통계

**문제점:**

**개선된 쿼리:**

```sql
-- 여기에 작성해주세요
```

**개선 이유:**

---

### B-2-2. 상담사 목록 N+1 쿼리

**문제점:**

**개선된 쿼리:**

```sql
-- 여기에 작성해주세요
```

**개선 이유:**
