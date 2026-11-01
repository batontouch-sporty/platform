-- Sporty v2 A안 R8 적용 결과 확인 (읽기 전용). 신규 설치와 R7->R8 변경 어느 경로 뒤에도 같은 결과여야 한다.
-- SELECT만 사용하며 아무것도 바꾸지 않는다. 모든 행이 PASS이고 마지막 SUMMARY가 PASS여야 한다.
WITH checks (check_name, result, detail) AS (
  SELECT 'matches.url VARCHAR(200) NULL', IF(COUNT(*)=1,'PASS','FAIL'), IFNULL(MAX(COLUMN_TYPE),'column missing')
    FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='matches' AND COLUMN_NAME='url'
     AND COLUMN_TYPE='varchar(200)' AND IS_NULLABLE='YES'
  UNION ALL
  SELECT 'match_waitlist columns (id, match_id, user_id, registered_at)',
         IF(GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION)='id,match_id,user_id,registered_at','PASS','FAIL'),
         IFNULL(GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION),'table missing')
    FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='match_waitlist'
  UNION ALL
  SELECT 'match_waitlist.registered_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)',
         IF(COUNT(*)=1,'PASS','FAIL'), IFNULL(MAX(COLUMN_DEFAULT),'column missing')
    FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='match_waitlist' AND COLUMN_NAME='registered_at'
     AND COLUMN_TYPE='timestamp(6)' AND IS_NULLABLE='NO' AND LOWER(COLUMN_DEFAULT) LIKE 'current_timestamp(6)%'
  UNION ALL
  SELECT 'match_waitlist UNIQUE (match_id, user_id)', IF(COUNT(*)=1,'PASS','FAIL'), IFNULL(MAX(INDEX_NAME),'missing')
    FROM (SELECT INDEX_NAME FROM information_schema.STATISTICS
           WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='match_waitlist' AND NON_UNIQUE=0
             AND INDEX_NAME='uk_match_waitlist_match_user'
           GROUP BY INDEX_NAME
          HAVING GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX)='match_id,user_id') u
  UNION ALL
  SELECT 'match_waitlist INDEX (user_id)', IF(COUNT(*)=1,'PASS','FAIL'), IFNULL(MAX(INDEX_NAME),'missing')
    FROM information_schema.STATISTICS
   WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='match_waitlist' AND INDEX_NAME='idx_match_waitlist_user'
     AND SEQ_IN_INDEX=1 AND COLUMN_NAME='user_id'
  UNION ALL
  SELECT 'match_waitlist FK match_id -> matches ON DELETE CASCADE', IF(COUNT(*)=1,'PASS','FAIL'),
         IFNULL(MAX(CONCAT('DELETE ',DELETE_RULE,', UPDATE ',UPDATE_RULE)),'missing')
    FROM information_schema.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='match_db' AND TABLE_NAME='match_waitlist' AND CONSTRAINT_NAME='fk_match_waitlist_match'
     AND REFERENCED_TABLE_NAME='matches' AND DELETE_RULE='CASCADE' AND UPDATE_RULE='RESTRICT'
  UNION ALL
  SELECT 'match_waitlist has exactly one FK (no cross-service FK)', IF(COUNT(*)=1,'PASS','FAIL'), CONCAT(COUNT(*),' FK')
    FROM information_schema.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='match_db' AND TABLE_NAME='match_waitlist'
  UNION ALL
  SELECT 'match_waitlist CHECK user_id > 0', IF(COUNT(*)=1,'PASS','FAIL'), IFNULL(MAX(CHECK_CLAUSE),'missing')
    FROM information_schema.CHECK_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='match_db' AND TABLE_NAME='match_waitlist' AND CONSTRAINT_NAME='ck_match_waitlist_user_id'
  UNION ALL
  SELECT 'match_participants FK stays ON DELETE RESTRICT', IF(COUNT(*)=1,'PASS','FAIL'),
         IFNULL(MAX(CONCAT('DELETE ',DELETE_RULE)),'missing')
    FROM information_schema.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA='match_db' AND TABLE_NAME='match_participants'
     AND CONSTRAINT_NAME='fk_match_participants_match' AND DELETE_RULE='RESTRICT'
  UNION ALL
  SELECT 'match_db.outbox_event has exactly one index starting with aggregate_id', IF(COUNT(DISTINCT INDEX_NAME)=1,'PASS','FAIL'),
         IFNULL(GROUP_CONCAT(DISTINCT INDEX_NAME),'missing')
    FROM information_schema.STATISTICS
   WHERE TABLE_SCHEMA='match_db' AND TABLE_NAME='outbox_event' AND SEQ_IN_INDEX=1 AND COLUMN_NAME='aggregate_id'
  UNION ALL
  SELECT 'user_db.outbox_event has no aggregate_id index (no reader yet)', IF(COUNT(*)=0,'PASS','FAIL'), CONCAT(COUNT(*),' index')
    FROM information_schema.STATISTICS
   WHERE TABLE_SCHEMA='user_db' AND TABLE_NAME='outbox_event' AND COLUMN_NAME='aggregate_id'
  UNION ALL
  SELECT 'base tables in the 4 service DBs = 15', IF(COUNT(*)=15,'PASS','FAIL'), CONCAT(COUNT(*),' tables')
    FROM information_schema.TABLES
   WHERE TABLE_SCHEMA IN ('user_db','facility_db','match_db','notification_db') AND TABLE_TYPE='BASE TABLE'
  UNION ALL
  SELECT 'physical FKs = 6 and none cross-schema', IF(COUNT(*)=6 AND SUM(CONSTRAINT_SCHEMA<>UNIQUE_CONSTRAINT_SCHEMA)=0,'PASS','FAIL'),
         CONCAT(COUNT(*),' FK, ',SUM(CONSTRAINT_SCHEMA<>UNIQUE_CONSTRAINT_SCHEMA),' cross-schema')
    FROM information_schema.REFERENTIAL_CONSTRAINTS
   WHERE CONSTRAINT_SCHEMA IN ('user_db','facility_db','match_db','notification_db')
)
SELECT check_name, result, detail FROM checks
UNION ALL
SELECT 'SUMMARY', IF(SUM(result='FAIL')=0,'PASS','FAIL'), CONCAT(SUM(result='PASS'),' PASS / ',SUM(result='FAIL'),' FAIL') FROM checks;
