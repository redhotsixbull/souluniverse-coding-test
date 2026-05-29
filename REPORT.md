# 코딩 테스트 제출 리포트

---

## Part A — Flutter 버그 수정

### 수정한 버그 목록

| # | 파일 경로 | 수정 내용 | 원인 분석 |
|---|-----------|-----------|-----------|
| 1 | `lib/app/me_state.dart` | `removeFavoriteCounselor`의 필터 조건을 `id == counselorId` → `id != counselorId` | 삭제인데 "대상만 남기는" 조건이라, 하트 해제 시 해제 대상은 남고 나머지 즐겨찾기가 모두 사라짐. 삭제 의미에 맞게 부정 조건으로 정정. (재현 테스트: `test/me_state_test.dart`, PR #1 red→green) |
| 2 | `lib/pages/chats/consultation_room_page.dart` | `dispose`에 `_messageSubscription?.cancel()` 추가 | 10초 주기 실시간 스트림 구독을 dispose에서 해제하지 않아, 채팅방을 벗어난 뒤에도 타이머가 계속 동작하는 리소스 누수. 이 누수가 채팅방 관련 widget 테스트를 종료 시 'Timer pending'으로 모두 실패시켜, 다른 채팅 버그(A-2/3/4/6)보다 먼저 수정함. (재현 테스트: `test/consultation_room_page_test.dart`, PR #2 red→green) |
| 3 | `lib/pages/chats/consultation_room_page.dart` | `_loadInitialMessages`의 상태 변경을 `setState`로 감싸고 비동기 완료 후 `mounted` 가드 추가 | 초기 메시지 로드 후 `_isLoadingMore`/`_messages`를 `setState` 없이 바꿔, 로드가 끝나도 리빌드되지 않아 상단 로딩바만 계속 돌고 채팅 리스트가 빈 채로 멈추던 버그. (재현 테스트: `test/consultation_room_page_test.dart`, PR #3 red→green) |
| 4 | `lib/pages/chats/consultation_room_page.dart` | `_sendMessage`에 보낸 메시지의 로컬 목록 추가(낙관적)+`setState` 추가, `_scrollToBottom`을 post-frame 실행으로 변경 | 전송 시 mock repository로 보내기만 하고 로컬 `_messages`에 추가/갱신하지 않아, 내가 보낸 메시지가 채팅창에 안 보이던 버그. 또한 스크롤이 setState 직후 동기 호출돼 갱신 전 범위로 이동하던 문제를 post-frame으로 고쳐 새 메시지가 실제로 보이게 함. (재현 테스트: `test/consultation_room_send_test.dart`, PR #4 red→green) |
| 5 | `lib/pages/chats/consultation_room_page.dart` | build에서 `MessageBubble`에 `currentUserId`(=`MeState.user?.id`) 전달 | `MessageBubble`은 `senderId == currentUserId`로 내 메시지 여부를 판단하는데, 채팅방에서 `currentUserId`를 넘기지 않아 `_isMine`이 항상 false → 모든 말풍선이 좌측 회색으로만 표시되던 버그. 현재 사용자 id를 전달해 내 메시지는 우측, 상대 메시지는 좌측으로 구분. (재현 테스트: `test/consultation_room_alignment_test.dart`, PR #5 red→green) |
| 6 | `lib/pages/chats/consultation_room_page.dart` | `_connectFirestore`의 listen 콜백에 `setState`+`mounted` 가드 추가 | 10초 주기로 도착하는 상담사 실시간 메시지를 `_messages`에 추가만 하고 `setState`를 호출하지 않아, 화면에 반영되지 않던 버그. setState로 감싸 갱신하고, 비동기 콜백이므로 mounted 가드를 추가. (재현 테스트: `test/consultation_room_realtime_test.dart`, PR #6 red→green) |

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
