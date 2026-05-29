# 01. Part A — Flutter 버그 분석

> 코드 정독 기반 **버그 후보**. 각 항목은 수정 단계에서 실제 동작으로 재확인한다.
> 신뢰도: 🔴 확정 / 🟡 유력 / ⚪ 의심(개선 여지)

## 앱 구조 한눈에

- `MeState`(ChangeNotifier) — 프로필/쿠키/즐겨찾기 전역 상태, `MultiProvider`로 제공
- `HomePage` — 프로필 카드 + 상담사 목록(`_CounselorCard`), 닉네임 변경 다이얼로그
- `ConsultationRoomPage` — 채팅방. 초기 메시지 로드 + 10초 주기 mock 스트림 + 전송
- `ChatInputBar` / `MessageBubble` — 입력 바 / 말풍선
- Repository 2종은 mock (지연만 줌, 실제 저장 없음)

---

## 버그 후보 목록

### 🔴 A-1. 즐겨찾기 삭제가 반대로 동작
**파일:** `lib/app/me_state.dart:30-35`
```dart
_favoriteCounselorIds = _favoriteCounselorIds
    .where((id) => id == counselorId)   // ← 버그
    .toList();
```
- `id == counselorId` → 지우려는 대상만 남기고 **나머지를 전부 삭제**.
- 정상: 해당 id를 *제외*해야 하므로 `id != counselorId`.
- 증상: 하트 해제 시 목록이 깨짐(다른 즐겨찾기 사라짐, 정작 대상은 남음).

### 🔴 A-2. 실시간(10초) 수신 메시지가 화면에 안 뜸
**파일:** `lib/pages/chats/consultation_room_page.dart:75-78`
```dart
).listen((msg) {
  _messages.add(msg);   // 리스트만 변경, setState 없음
  _scrollToBottom();
});
```
- `setState` 누락 → 리빌드 안 됨. 10초마다 메시지가 와도 화면 갱신 X.
- 수정: `setState(() => _messages.add(msg));`

### 🔴 A-3. 내가 보낸 메시지가 채팅창에 안 나타남
**파일:** `lib/pages/chats/consultation_room_page.dart:98-103`
```dart
Future<void> _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;
  _controller.clear();
  await ChatsRepository.instance.sendMessage(widget.roomId, text); // 전송만
}
```
- 전송 후 로컬 `_messages`에 추가/`setState` 없음 → 보낸 메시지가 화면에 안 보임.
- 과제 명세: "직접 입력해 전송하면 채팅창에 입력한 메시지를 전송할 수 있다" → 보여야 함.
- 수정: 보낸 메시지를 `ChatMessage`(senderId = 본인)로 만들어 `setState`로 추가 후 스크롤.

### 🟡 A-4. 내 메시지/상대 메시지 정렬 구분 안 됨
**파일:** `lib/pages/chats/consultation_room_page.dart:139-140` + `lib/widgets/message_bubble.dart:15`
```dart
MessageBubble(message: _messages[index])   // currentUserId 안 넘김
...
bool get _isMine => message.senderId == currentUserId; // 항상 null과 비교
```
- `currentUserId` 미전달 → `_isMine` 항상 false → **모든 말풍선이 좌측 정렬/회색**.
- mock 데이터의 senderId는 `user-demo`(나) / `counselor-1`(상대)로 구분돼 있는데 시각적 구분이 사라짐.
- 수정: `MessageBubble(message: ..., currentUserId: 본인 id)` 전달. (본인 id = `user-demo`, `MeState.user.id`에서 가져오는 게 자연스러움)

### 🟡 A-5. 채팅방 종료 시 스트림 미해제 (리소스 누수)
**파일:** `lib/pages/chats/consultation_room_page.dart:155-160`
```dart
void dispose() {
  _controller.dispose();
  _scrollController.dispose();
  super.dispose();          // _messageSubscription.cancel() 없음
}
```
- `_messageSubscription`을 cancel 안 함 → 페이지를 나가도 10초 타이머가 계속 동작, dispose된 state에 `_messages.add`/scroll 시도 가능 → 누수 및 잠재적 예외.
- 수정: `_messageSubscription?.cancel();` 추가.

### ⚪ A-6. 초기 메시지 로드에 setState 누락
**파일:** `lib/pages/chats/consultation_room_page.dart:45-55`
```dart
Future<void> _loadInitialMessages() async {
  _isLoadingMore = true;
  final msgs = await ...fetchMessages(...);
  _messages = msgs;        // setState 없음
  _isLoadingMore = false;
  _scrollToBottom();
}
```
- `setState` 없이 `_messages` 할당 → 첫 진입 시 안 그려질 수 있음(이후 다른 리빌드에 우연히 보일 뿐, 신뢰 불가).
- A-2를 고치면 우연히 가려질 수 있으나 **독립 버그로 명시 수정** 권장.
- `_isLoadingMore` 토글도 `LinearProgressIndicator` 표시와 연동되므로 setState 대상.

## 추가 관찰 (버그는 아니나 개선 후보 / REPORT 기타 의견용)

- `_isSending`이 항상 false → 전송 중 입력 비활성화(`isDisabled`)가 실제로 동작 안 함. A-3 수정 시 함께 `_isSending` 토글하면 중복 전송 방지 가능.
- `ConsultationRoomPage`가 자체 `_controller`를 두고, `ChatInputBar`도 자체 컨트롤러 보유 → `onSend`에서 `_controller.text = text` 후 재읽기하는 우회 구조. A-3 정리 시 본인 컨트롤러 제거하고 `onSend(text)`만 쓰는 방향이 단순.
- `_onScroll`은 `pixels == 0`에서만 추가 로드 → 정확히 0이어야 트리거. 큰 결함은 아님.

## 검증 방법

`flutter analyze`로 정적 오류 확인 + 가능하면 `flutter run`(플랫폼 파일 필요 시 `flutter create . --platforms android,ios`)으로 3개 시나리오(닉네임/즐겨찾기/채팅) 수동 확인.
