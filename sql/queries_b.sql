-- 소울톡 코딩 테스트 — Part B 쿼리 개선
-- 아래 문제 쿼리의 문제를 진단하고, 개선된 버전을 지정된 위치에 작성하세요.

-- ════════════════════════════════════════════════════════════
-- [스키마 참조] 수정 금지
-- ════════════════════════════════════════════════════════════

-- 사용자 테이블 (~50만 행)
CREATE TABLE users (
  id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  nickname    VARCHAR(50) NOT NULL,
  gender      ENUM('M','F','N') NOT NULL,
  birth_year  SMALLINT NOT NULL,
  region      VARCHAR(30),
  status      ENUM('active','dormant','banned') DEFAULT 'active',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login  DATETIME
);

-- 상담사 테이블 (~5,000명)
CREATE TABLE counselors (
  id             BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT NOT NULL UNIQUE,
  tier           ENUM('grand_soul','soul_healer','soul_master','soul_talker') NOT NULL,
  is_online      TINYINT(1) DEFAULT 0,
  fee_per_30sec  SMALLINT NOT NULL, -- 쿠키 단위
  rating         DECIMAL(3,2),
  review_count   INT DEFAULT 0,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 상담 채팅방 테이블 (~200만 건)
CREATE TABLE chat_rooms (
  id                   BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id              BIGINT NOT NULL,
  counselor_id         BIGINT NOT NULL,
  status               ENUM('waiting','in_progress','ended','canceled') NOT NULL,
  fee_per_30sec        SMALLINT NOT NULL,
  total_billed_cookies INT DEFAULT 0,
  billing_started_at   DATETIME,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at             DATETIME,
  FOREIGN KEY (user_id)       REFERENCES users(id),
  FOREIGN KEY (counselor_id)  REFERENCES counselors(id)
);

-- 현재 인덱스: PK만 존재


-- ════════════════════════════════════════════════════════════
-- B-2-1. 일별 상담 완료 통계
-- 최근 30일간 날짜별 상담 완료 건수와 평균 쿠키 소비량 조회
-- 현재 응답 시간 5초 이상 → 개선 필요
-- ════════════════════════════════════════════════════════════

-- [문제 쿼리] 수정 금지
SELECT
  DATE_FORMAT(created_at, '%Y-%m-%d') AS consult_date,
  COUNT(*)                            AS consult_count,
  AVG(total_billed_cookies)           AS avg_cookies
FROM chat_rooms
WHERE DATE_FORMAT(created_at, '%Y-%m-%d') >= DATE_FORMAT(
    DATE_SUB(NOW(), INTERVAL 30 DAY), '%Y-%m-%d'
  )
  AND status = 'ended'
GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
ORDER BY consult_date;

-- [개선된 쿼리] 여기에 작성하세요
-- 핵심: WHERE에서 created_at을 함수(DATE_FORMAT)로 감싸지 않고 "범위 조건"으로 비교(SARGable)
--       → 아래 인덱스를 탈 수 있게 됨. SELECT/GROUP BY의 날짜 포맷은 출력용이라 그대로 둔다(성능 영향 없음).
SELECT
  DATE_FORMAT(created_at, '%Y-%m-%d') AS consult_date,
  COUNT(*)                            AS consult_count,
  AVG(total_billed_cookies)           AS avg_cookies
FROM chat_rooms
WHERE status = 'ended'
  AND created_at >= CURDATE() - INTERVAL 30 DAY
GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
ORDER BY consult_date;

-- [CREATE INDEX] 여기에 작성하세요
-- 등치 컬럼(status)을 선두, 범위 컬럼(created_at)을 후행에 둔 복합 인덱스.
-- status='ended'로 먼저 좁힌 뒤 created_at 범위를 인덱스 레인지 스캔한다.
-- (B-tree는 범위 컬럼 이후로는 추가 탐색을 못 하므로 "등치 먼저, 범위 나중" 순서가 정답.)
CREATE INDEX idx_chat_rooms_status_created ON chat_rooms (status, created_at);



-- ════════════════════════════════════════════════════════════
-- B-2-2. 상담사 목록 — N+1 쿼리
-- 온라인 상담사 목록 + 각 상담사의 누적 완료 상담 횟수를 단일 쿼리로 조회
--
-- 결과 컬럼: user_id, nickname, gender, birth_year, total_chat_count
-- 정렬: total_chat_count DESC
-- ════════════════════════════════════════════════════════════

-- [문제 쿼리 Step 1] 온라인 상담사 목록 조회 / 수정 금지
SELECT c.id, u.nickname, c.tier, c.fee_per_30sec, c.rating
FROM counselors c
  JOIN users u ON c.user_id = u.id
WHERE c.is_online = 1
  AND u.status = 'active';

-- [문제 쿼리 Step 2] 각 상담사마다 반복 실행됨 (N번) / 수정 금지
SELECT COUNT(*) AS total_consultations
FROM chat_rooms
WHERE counselor_id = ?
  AND status = 'ended';

-- [개선된 단일 쿼리] 여기에 작성하세요


-- [CREATE INDEX] 여기에 작성하세요
