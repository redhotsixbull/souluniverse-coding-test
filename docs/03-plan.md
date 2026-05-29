# 03. 작업 플랜 & 커밋 전략

## 단계별 플랜

### Step 0. 준비 (현재)
- [x] 저장소 clone 및 환경 파악
- [x] 코드/스키마 정독, 버그·쿼리 분석 (`docs/`)
- [ ] `flutter pub get` + `flutter analyze`로 빌드 가능 상태 확인
  - 필요 시 `flutter create . --platforms android,ios`로 실행 플랫폼 생성

### Step 1. Part A 버그 수정 (각 1커밋 = 1버그 원칙)
원칙: **버그 하나당 커밋 하나**, 메시지에 *원인·근거* 명시. 각 수정마다 `REPORT.md` 표 1행 채움.
순서(독립적 → 묶기 좋은 채팅방 관련 묶음):
1. A-1 즐겨찾기 삭제 로직 (`me_state.dart`)
2. A-2 실시간 수신 setState (`consultation_room_page.dart`)
3. A-3 보낸 메시지 화면 반영 (`consultation_room_page.dart`)
4. A-4 말풍선 정렬 currentUserId 전달 (`consultation_room_page.dart` + `message_bubble.dart`)
5. A-5 스트림 dispose 누수 (`consultation_room_page.dart`)
6. A-6 초기 로드 setState (`consultation_room_page.dart`)

> A-2·A-3·A-5·A-6은 같은 파일이라 한 커밋에 묶고 싶을 수 있으나, **버그별 근거를 분리**하는 게 평가 의도에 부합 → 가급적 분리 커밋. 단 A-6은 A-2와 함께 "상태 갱신 누락" 묶음으로 합치는 것도 합리적(트레이드오프는 커밋 메시지/REPORT에 한 줄 명시).

### Step 2. Part B SQL 작성
1. B-2-1 개선 쿼리 + 인덱스 → `sql/queries_b.sql` 지정 위치 (1커밋)
2. B-2-2 단일 쿼리 + 인덱스 → 동일 (1커밋)
- 가능하면 EXPLAIN 비교를 `REPORT.md`에 첨부.

### Step 3. 문서 마무리
- `REPORT.md` 완성: 버그 표 5~6행 + Part B 문제점/개선쿼리/개선이유.
- **AI 사용 고지**: README + REPORT에 "Claude Code로 코드 분석·버그 진단·문서 초안 작성에 활용, 최종 판단/검증은 직접 수행" 취지 명시(필수 요건).

### Step 4. 제출 준비
- 본인 GitHub repo로 remote 변경 후 push (origin이 현재 Soul-Universe-Inc를 가리킴).
  - 예: `git remote set-url origin <본인-repo>` 또는 `git remote rename origin upstream` 후 새 origin 추가.
- 평가 후 repo 비공개 전환(요건).

## 커밋 메시지 컨벤션(제안)
- `fix(favorite): 즐겨찾기 삭제가 대상만 남기던 조건 != 로 수정` 처럼 **무엇을·왜**가 보이게.
- 타입: `fix`(버그), `perf`(쿼리 성능), `docs`(문서), `chore`(설정).
- 한국어로 통일(README/REPORT가 한국어).

## docs/ 폴더 처리 결정
- **커밋 포함 권장.** 평가가 "왜 그렇게 결정했는가"를 보므로 분석/트레이드오프 기록은 가점 요소.
- 단 `REPORT.md`가 공식 제출물 → docs는 보조. 부담되면 제출 직전 제외 가능(트레이드오프는 자유).

## 미해결/확인 필요 항목
- 의도된 버그 정확한 개수(5 vs 6) — 수정하며 동작으로 확정.
- B-2 "최근 30일" 경계 정의, 완료 0건 상담사 포함 여부 → 요구사항 해석을 REPORT에 명시.
- 실제 MySQL 실행 환경 유무(EXPLAIN 실측 가능 여부).
