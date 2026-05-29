---
name: flutter-bugfix
description: Part A의 Flutter 버그 "하나"를 착수하는 시점에 — 코드를 건드리기 전에 — 실행한다. 버그당 1회. 진단→브랜치→테스트 우선(실패=red)→수정(통과=green)→REPORT/로그→PR(머지 안 함)의 전 과정을 강제한다. "버그 고치자", "A-? 수정", 즐겨찾기/채팅/닉네임 동작 오류를 다룰 때 트리거.
---

# flutter-bugfix

소울유니버스 코딩 테스트 Part A 전용. **버그 1개를 테스트 우선(TDD red→green) + PR 단위로** 끝까지 처리하는 절차.
평가 기준은 "왜 그렇게 고쳤는가 + 과정"이므로, **실패하는 테스트로 버그를 증명하고 → 고쳐서 통과**시키는 과정을 git 이력에 남기는 게 목적이다.

## 언제 실행하는가 (When)
- **Part A 버그 하나를 착수하는 시점, 코드를 수정하기 전에** 실행한다. **버그당 1회.**
- 여러 버그를 동시에 다루지 않는다. 하나 끝(PR 생성)나면 다음 버그에서 다시 처음부터.

## 전제 (Preconditions)
- 최신 `main`에서 시작하고 작업트리가 clean한지 확인.
- 테스트는 `flutter test`로 헤드리스 실행(Chrome 불필요). 앱 수동 확인이 필요하면 `flutter run -d chrome`.

## 절차 (Procedure)

### 0. 진단 (Diagnose)
- 증상 → 원인 코드 위치(`파일:라인`) → 근본 원인을 각각 한 문장으로.
- 정상 동작 기준은 `docs/00-overview.md` 3개 시나리오(닉네임/즐겨찾기/채팅), 후보·신뢰도는 `docs/01-part-a-analysis.md`와 대조.

### 1. 브랜치 (Branch)
- `main` 기준 `fix/a{번호}-{짧은-slug}` 브랜치 생성. 예: `fix/a1-favorite-removal`.

### 2. 테스트 우선 — Red (Test first)
- **의도된 시나리오**를 재현하는 테스트를 `test/`에 작성. (상태 로직은 unit test, UI 동작은 widget test)
- `flutter test`로 실행해 **실패(red)** 를 확인하고 **실패 메시지를 기록**(PR 본문/REPORT 근거).
- 커밋(red 상태 박제): `test(scope): {버그} 재현 테스트 추가 — 현재 실패(버그 증명)`

### 3. 수정 — Green (Fix)
- **근본 원인만 최소 침습** 수정. 주변 리팩터링은 분리.
- `flutter test` 재실행 → **통과(green)** 확인. `flutter analyze`로 회귀 없음 확인.
- 커밋: `fix(scope): {무엇을} — {왜}` (한국어, 이유가 드러나게)

### 4. 기록 (Report & Log)
- `REPORT.md` Part A 표 1행: 파일·수정·**원인(왜)**.
- 새로 내린 판단/트레이드오프가 있으면 `docs/04-decision-log.md`에 항목 추가.

### 5. PR 생성 — 머지하지 않음 (Pull Request)
- 브랜치 push 후 `gh pr create --base main`로 PR 생성. **머지는 하지 않는다(사용자가 직접 리뷰/머지).**
- PR 본문 필수 포함:
  - 어떤 버그 / 근본 원인(`파일:라인`)
  - 테스트: 무엇을 검증하는지 + **red(실패 로그) → green(통과)** 결과
  - 검증 방법(`flutter test`, 필요 시 web 수동 확인)
- 같은 파일의 다른 버그는 보통 다른 메서드라 독립 브랜치로도 GitHub 자동 머지됨. 충돌 시 PR에 명시.

### 6. 다음 버그
- 사용자가 이전 PR을 머지했으면 갱신된 `main`에서, 아니면 `main`에서 다시 0번부터.

## 산출물 체크리스트 (버그 1건당)
- [ ] `fix/...` 브랜치 생성
- [ ] 시나리오 재현 테스트 작성 → `flutter test` **실패 확인** → red 커밋
- [ ] 최소 침습 수정 → `flutter test` **통과** + `flutter analyze` 무회귀 → green 커밋
- [ ] `REPORT.md` 표 1행 (+ 필요 시 decision-log)
- [ ] push + PR 생성(머지 X), 본문에 버그/원인/테스트 red→green/검증 기재

## 참고
- 버그 후보·신뢰도: `docs/01-part-a-analysis.md`
- 전역 규칙(커밋/테스트/PR): 루트 `CLAUDE.md`
