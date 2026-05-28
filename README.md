# 소울톡 개발자 채용

---

## 시작 전 안내

이 테스트는 단순히 코드를 고치는 능력이 아닌, **"왜 그렇게 결정했는가"** 를 보는 테스트입니다.
정답이 하나인 문제가 아니므로, 여러분의 판단과 트레이드오프 분석이 핵심 평가 대상입니다.

---

## 제출 방법

### 1. GitHub Repository 제출

- 완성된 코드를 본인 GitHub Repository에 업로드해 주세요.
- 커밋은 가능한 한 논리적인 작업 단위로 나누어 작성해 주세요.
- 커밋 메시지는 변경 내용을 파악할 수 있도록 간단하고 명확하게 작성해 주세요.
- 제출 시 GitHub Repository 링크를 메일로 회신해 주세요.
- 평가 결과 통보 후 해당 Repository는 비공개로 전환해 주세요.

### 2. ZIP 파일 제출

- GitHub 제출이 어렵거나 Repository 공개가 부담스러운 경우, 전체 프로젝트 폴더를 ZIP 파일로 압축하여 제출해 주세요.
- ZIP 파일 제출 시에는 `REPORT.md` 파일을 작성해 반드시 포함해 주세요.
- 아래와 같은 실행 및 평가에 불필요한 폴더는 제외해 주세요.
  - `node_modules`
  - `build`
  - `.dart_tool`
  - `.idea`
  - `.vscode`

---

## 환경 설정

```bash
flutter pub get
```

> **참고**: `flutter run`을 위한 플랫폼 파일이 필요한 경우 `flutter create . --platforms android,ios`를 실행하세요.

---

## Part A — Flutter 코드 디버깅

의도적으로 버그가 심어진 파일들입니다. 버그를 찾아 수정하고, 각 수정마다 근거를 `REPORT.md`에 작성해 주세요.

---

## Part B — MySQL 쿼리 개선

스키마: [`sql/schema.sql`](sql/schema.sql)  
현재 쿼리: [`sql/queries_b.sql`](sql/queries_b.sql)

각 쿼리의 성능 문제와 설계 결함을 진단하고, 개선된 쿼리와 필요한 인덱스(`CREATE INDEX`)를 작성하세요.  
결과는 `sql/queries_b.sql` 파일에 직접 작성하고, 개선 이유는 `REPORT.md`에 함께 정리해 주세요.

---

### 정성 평가 체크포인트

- 커밋 메시지가 변경 이유를 설명하는가? (GitHub 제출의 경우)
- `REPORT.md`가 코드 설명이 아닌 의사결정 근거를 담고 있는가?
- AI 도구를 사용했다면 어떻게 활용했는지 `REPORT.md`에 간략히 언급했는가?

---

궁금한 점은 채용 담당자 이메일로 문의하세요. 건투를 빕니다.
