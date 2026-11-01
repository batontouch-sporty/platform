-- Sporty v2 A안 R7 -> R8 변경 SQL (match_db 3가지 변경).
-- 실행 주체: 스키마 변경 권한이 있는 DBA 또는 마이그레이션 계정. match_app 같은 앱 계정으로 실행하지 않는다.
-- 사용 조건: user_db, match_db 등이 이미 R7로 만들어진 DB. 빈 환경에는 R8 신규 설치 SQL을 사용하고, 둘 중 하나만 실행한다.
-- 기존 1차 sporty DB에는 실행하지 않는다.
--
-- 앞의 두 문장은 다시 실행해도 안전하다(IF NOT EXISTS). 마지막 CREATE TABLE은 1회용이며, match_waitlist가 이미 있으면
-- 일부러 실패한다. 다른 정의의 테이블을 조용히 건너뛰지 않기 위해서다. DDL은 롤백되지 않으므로 중간에 실패하면
-- 3_적용후_확인용.sql로 어디까지 적용됐는지 먼저 확인한다.

-- 1) matches.url: 시설 예약 링크의 복사본. 이미 같은 이름의 컬럼이 있으면 건너뛴다(정의는 validate로 확인).
ALTER TABLE match_db.matches
  ADD COLUMN IF NOT EXISTS url VARCHAR(200) NULL COMMENT '시설 예약 링크 복사본, facility_db.service.url 스냅샷' AFTER is_free;

-- 2) outbox 조회 인덱스: PR #36의 WithdrawalStore.completed()가 aggregate_id로 조회한다.
--    docs/sql/003_match_outbox_aggregate_index.sql이 먼저 적용됐어도 같은 이름이라 건너뛴다.
CREATE INDEX IF NOT EXISTS idx_outbox_event_aggregate_id ON match_db.outbox_event (aggregate_id);

-- 3) match_waitlist: 대기열. 1회 생성.
CREATE TABLE match_db.match_waitlist (
  id BIGINT NOT NULL AUTO_INCREMENT,
  match_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL COMMENT 'user_db.user.id의 논리 참조, FK 없음',
  registered_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  CONSTRAINT uk_match_waitlist_match_user UNIQUE (match_id,user_id),
  KEY idx_match_waitlist_user (user_id),
  CONSTRAINT fk_match_waitlist_match FOREIGN KEY (match_id) REFERENCES match_db.matches(id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT ck_match_waitlist_user_id CHECK (user_id > 0)
) ENGINE=InnoDB;
