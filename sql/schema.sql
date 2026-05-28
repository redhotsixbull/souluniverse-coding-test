-- 소울톡 코딩 테스트 — Part B 스키마
-- Part B 쿼리 작성 시 이 스키마를 기준으로 하세요.

-- 사용자 테이블 (~50만 행)
CREATE TABLE users (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  nickname   VARCHAR(50)                             NOT NULL,
  gender     ENUM('M', 'F', 'N')                    NOT NULL,
  birth_year SMALLINT                                NOT NULL,
  region     VARCHAR(30),
  status     ENUM('active', 'dormant', 'banned')     DEFAULT 'active',
  created_at DATETIME NOT NULL                       DEFAULT CURRENT_TIMESTAMP,
  last_login DATETIME
);

-- 상담사 테이블 (~5,000명)
CREATE TABLE counselors (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT        NOT NULL UNIQUE,
  tier          ENUM('grand_soul', 'soul_healer', 'soul_master', 'soul_talker') NOT NULL,
  is_online     TINYINT(1)    DEFAULT 0,
  fee_per_30sec SMALLINT      NOT NULL,  -- 쿠키 단위
  rating        DECIMAL(3, 2),
  review_count  INT           DEFAULT 0,
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- 상담 채팅방 테이블 (~200만 건)
CREATE TABLE chat_rooms (
  id                   BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id              BIGINT        NOT NULL,
  counselor_id         BIGINT        NOT NULL,
  status               ENUM('waiting', 'in_progress', 'ended', 'canceled') NOT NULL,
  fee_per_30sec        SMALLINT      NOT NULL,
  total_billed_cookies INT           DEFAULT 0,
  billing_started_at   DATETIME,
  created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at             DATETIME,
  FOREIGN KEY (user_id)     REFERENCES users (id),
  FOREIGN KEY (counselor_id) REFERENCES counselors (id)
);

-- 쿠키 내역 테이블 (~3,000만 건)
CREATE TABLE cookie_histories (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT  NOT NULL,
  room_id    BIGINT,
  amount     INT     NOT NULL,  -- 양수: 충전, 음수: 차감
  type       ENUM('charge', 'deduction', 'refund', 'bonus') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (room_id) REFERENCES chat_rooms (id)
);

-- 현재 인덱스: PK만 존재
-- Part B 답변에서 CREATE INDEX 문으로 필요한 인덱스를 추가하세요.
