# 코딩 테스트 제출 리포트

---

## AI 도구 사용 고지

본 과제는 **Claude Code(Anthropic)** 를 **광범위하게** 활용해 진행했습니다. 투명하게 밝히면 **코드·테스트·문서 작성의 대부분을 AI가 수행**했고, 저는 **방향 설정·의사결정·리뷰·검증**을 담당하는 방식으로 협업했습니다.

**AI(Claude Code)가 수행한 것**
- Part A: 정적 분석 기반 버그 후보 도출, 버그별 재현 테스트(red)→수정(green) 작성, `flutter test`/`flutter analyze` 검증, 커밋·PR 생성
- 리팩토링(PR #8): 상태관리·repository 구조 개선 구현
- 문서: `docs/`(분석·계획·의사결정 로그), 본 `REPORT.md`
- 환경/워크플로우: 테스트 우선(red→green)·버그당 PR, web(Chrome) 실행·hot reload, git/gh 조작

**제가 주도한 것**
- 전체 워크플로우·규칙 설계(테스트 우선, 버그당 PR, 직접 리뷰/머지, hot reload 확인)
- 모든 PR 리뷰·머지 판단, 자동 코드리뷰(Codex) 대응 방향 결정
- 버그 1건(A-7 닉네임 미반영)을 **웹 수동 확인 중 직접 발견**(정적 분석이 놓친 부분)
- 구조적 개선 포인트(채팅 상태관리·repository 인터페이스·stateless/stateful 구성) 제기 → PR #8로 구현

의사결정 근거·과정은 `docs/04-decision-log.md`에 시간순으로 기록돼 있습니다.

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
| 7 | `lib/pages/home/home_page.dart` | `_HomeBody`의 `context.read<MeState>()` → `context.watch<MeState>()` | `_HomeBody`가 `const` + `context.read`라 MeState 변경(notifyListeners)을 구독/리빌드하지 않아, 닉네임을 바꿔도 홈 인사말·아바타가 갱신되지 않던 버그. watch로 구독해 const 위젯이어도 변경 시 리빌드되게 함(`_CounselorCard`와 일관). *초기 정적 분석에서 누락되어 웹 수동 확인으로 발견 — `docs/04` D-011 참고.* (재현 테스트: `test/home_page_test.dart`, PR #7 red→green) |

### 기타 의견

버그를 고치며 본 **구조적 아쉬움 3가지**입니다. 세 가지 모두 *"구조로 실수를 막고 의도를 드러내자"* 라는 한 가지 테마로 묶입니다. 단순 지적에 그치지 않고 **실제 개선을 리팩토링 PR로 구현**해 두었습니다 → **[PR #8](https://github.com/redhotsixbull/souluniverse-coding-test/pull/8)** (동작 보존, 기존 테스트 그대로 통과). 의사결정 흐름은 PR #8 본문과 `docs/04-decision-log.md`(D-012)에 정리.

1. **채팅 상태가 명령형 `setState`에 의존.** 심어진 버그 A-2/A-3/A-6(및 A-7)이 모두 "상태 변경 후 갱신/구독 누락"이라는 한 뿌리였다. `ConsultationRoomPage`가 가변 `_messages`를 직접 들고 수동 갱신하는 구조라 한 곳만 빠뜨려도 버그가 된다. → 채팅 상태를 `ChangeNotifier`(`ChatRoomController`)로 분리해 "변경 = 자동 알림"으로 만들면 이 부류 버그가 구조적으로 불가능해진다.

2. **위젯 구성: stateless 골조 + stateful 아일랜드.** 바깥은 stateless 셸로 두고 상태는 가장 좁은 leaf에 가두는 형태(`Stateless [ Stateful, … ]`)가 이상적이다. `ChatInputBar`는 좋은 예였지만 `ConsultationRoomPage`는 리스트·스크롤·구독·입력을 혼자 떠안은 거대 StatefulWidget이었다. → 페이지를 셸로 두고 `_MessageList` 등 작은 컴포넌트로 분해.

3. **Repository에 인터페이스(계약)가 없음.** 구체 싱글턴에 함수만 나열돼 있어, 인터페이스만으로 기능을 추측할 수 없고 구현 교체·테스트 fake 주입이 불가능했다(실제로 테스트가 mock의 지연을 그대로 감수해야 했다). → 추상 인터페이스 + 구현 주입(DI)으로 계약을 드러내고 결합을 끊는다.

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
