# Sporty v2 R10 테이블 명세서

> **확정 원본:** [Sporty_R10_테이블명세서.xlsx](Sporty_R10_테이블명세서.xlsx). 아래는 7개 시트를 값 기준으로 옮긴 것입니다. 데이터 타입·NULL·제약·승인 상태는 원본과 백엔드 PR #126의 R10 DDL을 우선합니다. 이 문서 자체가 팀 DB에 마이그레이션을 적용했다는 증거는 아닙니다.

## 기준과 적용 경계

- MariaDB 서버 1대, 서비스 DB 4개, 테이블 **16개**, 컬럼 **130개**, 기본 물리 FK **7개**(모두 동일 DB 내부). AI DB는 없습니다.
- `03` 선택 제약 적용 시 `owner_request_key` 생성 컬럼과 방장 요청 ID FK가 추가되어 기본 수치와 달라집니다.
- 신규 설치용 `schema.sql` 또는 `01_R10`은 **택일**합니다. `02_R9_to_R10`은 R9 전용이고 지정 테이블이 비어 있어야 하며 R8에 직접 실행하면 안 됩니다. 백업·실행 기록·서비스 E2E 검증이 별도로 필요합니다.
- 원본의 「차이_결정」 시트는 과거 제안/확인 필요 상태를 포함합니다. 아래 표기는 원문 그대로 보존하며 일괄적으로 팀 최종 승인으로 변경하지 않습니다.

## 서비스별 테이블 개요

> 원본 시트 `테이블_개요`: R10 기준: MariaDB 서버 1개 · 서비스 DB 4개 · 테이블 16개 · 컬럼 130개 · 기본 물리 FK 7개(같은 DB 내부만). AI DB 없음. 03 선택 제약은 기본 수치에서 제외.

| 테이블 | 논리명 | 소유 서비스 | DB/스키마 | 범위 | 기능 ID | 설명 |
| --- | --- | --- | --- | --- | --- | --- |
| user | 회원 | user-service | user_db | 기존 테이블 · R10 확장 | USR | 회원·권한·탈퇴 상태, 포인트(0~100), 정상 출석 누적(0~4), 정지 종료 시각 |
| point_history | 포인트 변경 이력 | user-service | user_db | R10 포인트 구조 | PT-01~PT-06 | 요청별 차감·반환·몰수·보상·정지 해제 이력 및 중복 방지 |
| profile | 회원 프로필 | user-service | user_db | 기존 유지 | PR | 회원 1:1, 활동 자치구·닉네임 |
| sport_preference | 선호 종목 | user-service | user_db | 기존 유지 | PR | 프로필 1:N, (profile_id,sport_type) 복합 고유 |
| withdrawal_saga | 탈퇴 Saga | user-service | user_db | 신규 | USR-04 | 탈퇴 처리 상태·기한 관리 (PROCESSING/CLEANED/REJECTED/TIMED_OUT) |
| processed_events | 이벤트 소비 이력 | user-service | user_db | 신규 | MSA-06 | 처리한 event_id 기록으로 중복 소비 방지 |
| outbox_event | 발행할 이벤트 | user-service | user_db | 신규 | MSA-06 | DB 커밋과 이벤트 저장 원자화 |
| location | 시설 장소 | facility-service | facility_db | 기존 유지 | FC | 자치구, 장소명, 좌표 |
| service | 예약 서비스 정보 | facility-service | facility_db | 기존 유지 | FC | 공공시설 API 원본 SVCID, 상태, 이용시간, 예약 URL |
| matches | 운동 매치 | match-service | match_db | 기존 테이블 · R10 확장 | EM | 생성 요청 UUID, 생성 대기/실패 포함 7개 상태, 최소 정원 2명, 시설 예약 URL 스냅샷 |
| match_participants | 참가자 | match-service | match_db | 기존 테이블 · R10 확장 | EM | 요청 UUID·참가 확정 상태·출석 결과. (match_id,user_id)와 request_id UNIQUE. 방장 요청 ID=생성 요청 ID |
| match_waitlist | 매치 대기자 | match-service | match_db | 신규 | EM | 매치 대기 등록; (match_id,user_id) 복합고유 |
| processed_events | 이벤트 소비 이력 | match-service | match_db | 신규 | MSA-06 | 처리한 event_id 기록으로 중복 소비 방지 |
| outbox_event | 발행할 이벤트 | match-service | match_db | 신규 | MSA-06 | DB 커밋과 이벤트 저장 원자화 |
| notification | 알림 | notification-service | notification_db | 신규 | NT-01~NT-03 | 수신자별 알림. (event_id,recipient_user_id,type) 복합 UNIQUE. 다른 DB ID는 논리 참조 |
| processed_events | 이벤트 소비 이력 | notification-service | notification_db | 신규 | MSA-06 | 처리한 event_id 기록으로 중복 소비 방지 |

## 컬럼 명세

> 원본 시트 `컬럼_명세`: R10 기준: PR #126 @cd038ce schema.sql = 01 신규 설치 DDL. 기본 130컬럼이며 03 선택 생성 컬럼(owner_request_key)은 제외. R8 대비 변경과 신규 컬럼을 구분.

| DB | 소유 서비스 | 테이블 | No | 컬럼 | SQL 타입 | NULL(Y/N) | 키/인덱스 | DEFAULT | 설명 | 이관 상태 / 변경 | 근거 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| user_db | user-service | user | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 회원 ID | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 2 | email | VARCHAR(50) | N | UK (uk_user_email) |  | 로그인 이메일 | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 3 | password | VARCHAR(255) | N |  |  | 암호화된 비밀번호 | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 4 | role | VARCHAR(10) | N |  | USER | 권한 (USER, ADMIN) · CHECK ck_user_role | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 5 | gender | VARCHAR(10) | N |  |  | 성별 (MALE, FEMALE) · CHECK ck_user_gender | 타입 변경: ENUM → VARCHAR(10) + CHECK | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 6 | status | VARCHAR(20) | N |  | ACTIVE | 회원 상태 (ACTIVE, WITHDRAWING, WITHDRAWN) · CHECK ck_user_status | 타입 변경: ENUM → VARCHAR(20) + CHECK, WITHDRAWING 값 추가 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 7 | points | INT | N |  | 50 | 현재 포인트. 기본 50, 범위 0~100 · CHECK ck_user_points | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 8 | attendance_reward_count | INT | N |  | 0 | 정상 출석 보상용 누적 횟수. 기본 0, 범위 0~4. 5회 달성 시 보상 지급 후 0으로 초기화 | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 9 | suspended_until | DATETIME(6) | Y | IDX (idx_user_suspended_until) |  | 참가 활동 정지 종료 시각. Asia/Seoul(KST) 기준으로 저장하며 정지 해제는 7일 후 00:00 기준. NULL은 정지 없음 · idx_user_suspended_until | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 10 | withdrawn_at | DATETIME(6) | Y |  |  | 탈퇴 일시 | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 11 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | user | 12 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 포인트 이력 ID · AUTO_INCREMENT | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 2 | user_id | BIGINT | N | IDX (idx_point_history_user_created; 복합), FK (fk_point_history_user) |  | 포인트 소유 회원 ID · 같은 user_db 내부 FK, ON DELETE/UPDATE RESTRICT | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 3 | match_id | BIGINT | Y |  |  | match_db.matches.id의 논리 참조(FK 없음). 매치 관련 사유는 NOT NULL, SIGNUP/SUSPENSION_EXPIRED는 NULL | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 4 | request_id | VARCHAR(36) | Y | UK (uk_point_history_request_reason; 복합) |  | 보증금을 식별하는 생성·참가·승급 요청 UUID. request_id+reason 복합 UNIQUE. 재신청은 새 요청 ID | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 5 | reason | VARCHAR(30) | N | UK (uk_point_history_request_reason; 복합) |  | SIGNUP / SUSPENSION_EXPIRED / DEPOSIT_CHARGED / DEPOSIT_RETURNED / DEPOSIT_CANCELLED / ATTENDANCE_REWARDED / NO_SHOW_FORFEITED · CHECK | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 6 | before_points | INT | N |  |  | 처리 전 포인트(0~100) | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 7 | after_points | INT | N |  |  | 처리 후 포인트(0~100) | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 8 | delta | INT | N |  |  | 실제 증감량 = after_points - before_points. 차감<0, 반환·보상>=0, 취소 선도착·노쇼=0 | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 9 | source_event_id | VARCHAR(64) | Y |  |  | 원인 이벤트 ID. 매치 관련 사유는 NOT NULL, SIGNUP/SUSPENSION_EXPIRED는 NULL. 단독 UNIQUE 아님 | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 10 | created_at | DATETIME(6) | N | IDX (idx_point_history_user_created; 복합) | CURRENT_TIMESTAMP(6) | 포인트 이력 생성 시각 · DATETIME(6), 기본 CURRENT_TIMESTAMP(6) | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | point_history | 11 | request_decision_key | VARCHAR(40) | Y | UK (uk_point_history_request_decision) | 생성 컬럼(PERSISTENT) · 직접 입력하지 않음 | PERSISTENT 생성 컬럼. 차감/취소 선도착은 C:request_id, 반환/몰수는 S:request_id. UNIQUE로 상충 결정 차단. 그 외 사유는 NULL | R10 포인트 이력 테이블 (R8 대비 신규, R9 구조 변경) | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 프로필 ID | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 2 | user_id | BIGINT | N | UK (uk_profile_user), FK (fk_profile_user) |  | 회원 ID (user.id), 회원당 1개 · FK ON DELETE RESTRICT | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 3 | nickname | VARCHAR(50) | N | UK (uk_profile_nickname) |  | 닉네임 | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 4 | district | VARCHAR(30) | N |  |  | 활동 자치구 (서울 25개 자치구 enum 문자열, 예: MAPO, GANGNAM) · DB CHECK 없음, 애플리케이션 검증 | 타입 변경: ENUM → VARCHAR(30) | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 5 | image_url | VARCHAR(255) | Y |  |  | 프로필 이미지 URL | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 6 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | profile | 7 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | sport_preference | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 선호 종목 ID | 기존 유지 | R10 / PR #126 @cd038ce |
| user_db | user-service | sport_preference | 2 | profile_id | BIGINT | N | UK (uk_sport_preference_profile_sport; 복합), FK (fk_sport_preference_profile) |  | 프로필 ID (profile.id) · FK ON DELETE CASCADE · (profile_id,sport_type) 복합 UNIQUE, 각 컬럼 단독 UNIQUE 아님 | 기존 유지 (FK 삭제 규칙 CASCADE) | R10 / PR #126 @cd038ce |
| user_db | user-service | sport_preference | 3 | sport_type | VARCHAR(15) | N | UK (uk_sport_preference_profile_sport; 복합) |  | SOCCER, FUTSAL, BASKETBALL, BASEBALL, TENNIS, BADMINTON, TABLE_TENNIS, VOLLEYBALL, SWIMMING, RUNNING · CHECK ck_sport_preference_type | 타입 변경: ENUM → VARCHAR(15) + CHECK | R10 / PR #126 @cd038ce |
| user_db | user-service | sport_preference | 4 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | sport_preference | 5 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 1 | saga_id | CHAR(36) | N | PK |  | 탈퇴 Saga ID (UUID) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 2 | user_id | BIGINT | N | IDX (idx_withdrawal_saga_user), FK (fk_withdrawal_saga_user) |  | 회원 ID (user.id) · FK ON DELETE RESTRICT | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 3 | status | VARCHAR(20) | N | IDX (idx_withdrawal_saga_status_deadline; 복합) | PROCESSING | Saga 상태 (PROCESSING, CLEANED, REJECTED, TIMED_OUT) · CHECK ck_withdrawal_saga_status | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 4 | reason | VARCHAR(200) | Y |  |  | 탈퇴 거절/실패 사유 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 5 | requested_at | DATETIME(6) | N |  |  | 탈퇴 요청 일시 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 6 | deadline_at | DATETIME(6) | N | IDX (idx_withdrawal_saga_status_deadline; 복합) |  | 처리 기한 · CHECK deadline_at > requested_at | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 7 | claim_token | VARCHAR(64) | N | UK (uk_withdrawal_saga_claim_token) |  | 탈퇴 요청 event_id; 요청 이벤트와 Saga 연결 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | withdrawal_saga | 8 | finished_at | DATETIME(6) | Y |  |  | 종료 일시 · PROCESSING이면 NULL, CLEANED/REJECTED/TIMED_OUT이면 NOT NULL (CHECK ck_withdrawal_saga_finished) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | processed_events | 1 | event_id | VARCHAR(64) | N | PK |  | 처리한 이벤트 ID (중복 처리 방지) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | processed_events | 2 | event_type | VARCHAR(80) | N |  |  | 이벤트 유형 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | processed_events | 3 | processed_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 처리 시각 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 1 | event_id | VARCHAR(64) | N | PK |  | 이벤트 ID | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 2 | aggregate_id | VARCHAR(64) | N |  |  | 집계 ID | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 3 | event_type | VARCHAR(80) | N |  |  | 이벤트 유형 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 4 | payload | JSON | N |  |  | 이벤트 JSON 문서 · MariaDB는 LONGTEXT + JSON_VALID 검사로 구현하는 JSON 별칭 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 5 | created_at | TIMESTAMP(6) | N | IDX (idx_user_outbox_unpublished; 복합) | CURRENT_TIMESTAMP(6) | 발행 기록 시각 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| user_db | user-service | outbox_event | 6 | published_at | TIMESTAMP(6) | Y | IDX (idx_user_outbox_unpublished; 복합) |  | 실제 발행 완료 시각 (NULL = 미발행) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 장소 ID | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 2 | region | VARCHAR(20) | N |  |  | 자치구명 (예: 강남구) | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 3 | name | VARCHAR(100) | N |  |  | 장소명 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 4 | facility_name | VARCHAR(100) | Y |  |  | 시설명 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 5 | contact | VARCHAR(100) | Y |  |  | 연락처 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 6 | latitude | DECIMAL(18,15) | Y |  |  | 위도 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 7 | longitude | DECIMAL(18,15) | Y |  |  | 경도 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 8 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | location | 9 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 서비스 ID | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 2 | location_id | BIGINT | N | IDX (idx_facility_service_location), FK (fk_facility_service_location) |  | 장소 ID (location.id) · FK ON DELETE RESTRICT | 기존 유지 (인덱스 명시) | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 3 | service_id | VARCHAR(50) | N | UK (uk_facility_service_external_id) |  | 공공데이터 원본 서비스 ID (SVCID) | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 4 | name | VARCHAR(200) | N |  |  | 서비스명 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 5 | status | VARCHAR(20) | Y |  |  | 예약 상태 (공공데이터 원본 값) | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 6 | start_time | TIME | Y |  |  | 이용 시작 시간 | 타입 변경: TIME(6) → TIME | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 7 | end_time | TIME | Y |  |  | 이용 종료 시간 | 타입 변경: TIME(6) → TIME | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 8 | is_free | BOOLEAN | Y |  |  | 무료 여부 | 타입 변경: BIT(1) → BOOLEAN | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 9 | url | VARCHAR(200) | Y |  |  | 예약 페이지 URL | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 10 | reservation_deadline_at | DATETIME(6) | Y |  |  | 예약 마감 일시 | 기존 유지 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 11 | active | BOOLEAN | N |  | TRUE | 활성 여부 (상세 조회는 활성 서비스만) | 타입 변경: BIT(1) → BOOLEAN | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 12 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| facility_db | facility-service | service | 13 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 매치 ID | 테이블명 변경: match → matches | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 2 | title | VARCHAR(50) | N |  |  | 제목 · CHECK 공백만 입력 불가 | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 3 | description | VARCHAR(500) | Y |  |  | 설명 | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 4 | start_at | DATETIME(6) | N | IDX (idx_matches_status_start; 복합), IDX (idx_matches_sport_status_start; 복합), IDX (idx_matches_region_start; 복합) |  | 시작 일시 | 정밀도 변경: DATETIME → DATETIME(6) | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 5 | end_at | DATETIME(6) | N | IDX (idx_matches_status_end; 복합) |  | 종료 일시 · CHECK end_at > start_at | 정밀도 변경: DATETIME → DATETIME(6) | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 6 | max_participant | INT | N |  |  | 방장을 포함한 최대 참가 인원 · CHECK max_participant >= 2 | R10 변경: 최소 정원/생성 상태/요청·출석 구조 반영 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 7 | status | VARCHAR(20) | N | IDX (idx_matches_status_start; 복합), IDX (idx_matches_status_end; 복합), IDX (idx_matches_sport_status_start; 복합) | CREATION_PENDING | CREATION_PENDING / CREATION_FAILED / RECRUITING / CLOSED / IN_PROGRESS / COMPLETED / CANCELLED · 기본 CREATION_PENDING | R10 변경: 최소 정원/생성 상태/요청·출석 구조 반영 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 8 | status_changed_at | DATETIME(6) | Y |  |  | 상태 변경 일시 | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 9 | creation_request_id | VARCHAR(36) | N | UK (uk_matches_creation_request) |  | 모임 생성 요청 UUID. NOT NULL·UNIQUE. 방장 참가 행의 request_id와 같은 값 | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 10 | cancel_reason | VARCHAR(200) | Y |  |  | 취소 사유 | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 11 | cancelled_at | DATETIME(6) | Y |  |  | 취소 일시 · status가 CANCELLED이면 NOT NULL (CHECK ck_matches_cancelled_at) | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 12 | skill_level | VARCHAR(30) | N |  | BEGINNER | 실력 수준 (BEGINNER, INTERMEDIATE, ADVANCED) · CHECK ck_matches_skill | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 13 | sport_type | VARCHAR(15) | N | IDX (idx_matches_sport_status_start; 복합) |  | 종목 (sport_preference와 같은 10개 값) · CHECK ck_matches_sport_type | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 14 | gender_group | VARCHAR(10) | N |  |  | 성별 구성 (MALE, FEMALE, MIXED) · CHECK ck_matches_gender | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 15 | facility_id | BIGINT | N | IDX (idx_matches_facility) |  | facility_db.service.id의 논리 참조; FK 없음 · CHECK > 0 · API 필드명 serviceId | 컬럼명 변경: service_id → facility_id, 교차 DB FK 제거 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 16 | facility_name | VARCHAR(200) | N |  |  | 시설 서비스명 스냅샷 | DDL 신규 컬럼 (구 facility_name_snapshot 대체, NOT NULL) | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 17 | location_name | VARCHAR(100) | N |  |  | 장소명 스냅샷 | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 18 | region | VARCHAR(20) | N | IDX (idx_matches_region_start; 복합) |  | 시설 지역(자치구) 스냅샷 | DDL 신규 컬럼 (구 region_snapshot 대체, NOT NULL) | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 19 | is_free | BOOLEAN | Y |  |  | 시설 무료 여부 스냅샷 | DDL 신규 컬럼 (구 is_free_snapshot 대체) | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 20 | url | VARCHAR(200) | Y |  |  | 시설 예약 링크 복사본, facility_db.service.url 스냅샷 | DDL 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 21 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 생성 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| match_db | match-service | matches | 22 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 1 | match_participant_id | BIGINT | N | PK | AUTO_INCREMENT | 참가 ID | 테이블명 변경: match_participant → match_participants | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 2 | match_id | BIGINT | N | UK (uk_match_participants_match_user; 복합), FK (fk_match_participants_match) |  | 매치 ID (matches.id) · FK ON DELETE RESTRICT · (match_id,user_id) 복합 UNIQUE | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 3 | user_id | BIGINT | N | UK (uk_match_participants_match_user; 복합), IDX (idx_match_participants_user) |  | user_db.user.id의 논리 참조; FK 없음 · CHECK > 0 | 교차 DB FK 제거 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 4 | role | VARCHAR(20) | N |  |  | 역할 (OWNER: 개설자, PARTICIPANT: 참가자) · CHECK ck_match_participants_role | 기존 유지 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 5 | request_id | VARCHAR(36) | N | UK (uk_match_participants_request) |  | 참가 요청 UUID. NOT NULL·UNIQUE. 방장은 creation_request_id와 동일, 일반 참가·승급·재신청은 새 UUID | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 6 | participation_status | VARCHAR(20) | N |  | PENDING | PENDING / CONFIRMED / FAILED / CANCELLED. 기본 PENDING. 실제 참가 인원·명단·정산은 CONFIRMED 기준 | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 7 | match_participant_status | VARCHAR(20) | N |  | ATTENDED | ATTENDED / NO_SHOW. 기본 ATTENDED. 참가 확정 상태와 구분하는 출석 결과 | R10 신규 컬럼 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 8 | created_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 참가 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT 명시 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_participants | 9 | updated_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | 수정 일시 | 정밀도 변경: TIMESTAMP → TIMESTAMP(6), DEFAULT/ON UPDATE 명시 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_waitlist | 1 | id | BIGINT | N | PK, IDX (idx_match_waitlist_match_order; 복합) | AUTO_INCREMENT | 대기 ID | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_waitlist | 2 | match_id | BIGINT | N | UK (uk_match_waitlist_match_user; 복합), IDX (idx_match_waitlist_match_order; 복합), FK (fk_match_waitlist_match) |  | 매치 ID (matches.id) · FK ON DELETE CASCADE | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_waitlist | 3 | user_id | BIGINT | N | UK (uk_match_waitlist_match_user; 복합), IDX (idx_match_waitlist_user) |  | user_db.user.id의 논리 참조, FK 없음 · CHECK > 0 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | match_waitlist | 4 | registered_at | TIMESTAMP(6) | N | IDX (idx_match_waitlist_match_order; 복합) | CURRENT_TIMESTAMP(6) | 대기 등록 일시 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | processed_events | 1 | event_id | VARCHAR(64) | N | PK |  | 처리한 이벤트 ID (중복 처리 방지) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | processed_events | 2 | event_type | VARCHAR(80) | N |  |  | 이벤트 유형 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | processed_events | 3 | processed_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 처리 시각 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 1 | event_id | VARCHAR(64) | N | PK |  | 이벤트 ID | DDL 신규 테이블 (구 설계의 BIGINT id/event_id CHAR(36) 구조에서 변경) | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 2 | aggregate_id | VARCHAR(64) | N | IDX (idx_outbox_event_aggregate_id) |  | 이벤트 key용 식별자. 기존 매치 알림은 matchId, 보증금·정산 및 내부 요청 상태는 userId (VARCHAR(64)) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 3 | event_type | VARCHAR(80) | N |  |  | 이벤트 유형. 예: match.joined.v1, match.status-changed.v1, match.deposit-charge-requested.v1, match.attendance-settlement-requested.v1 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 4 | payload | JSON | N |  |  | 이벤트 JSON 문서 · MariaDB는 LONGTEXT + JSON_VALID 검사로 구현하는 JSON 별칭 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 5 | created_at | TIMESTAMP(6) | N | IDX (idx_match_outbox_unpublished; 복합) | CURRENT_TIMESTAMP(6) | 발행 기록 시각 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| match_db | match-service | outbox_event | 6 | published_at | TIMESTAMP(6) | Y | IDX (idx_match_outbox_unpublished; 복합) |  | 업무 이벤트는 발행 완료 시각(NULL=미발행). 내부 타입 match.deposit-request.state는 요청 대기/종결 표식으로 사용 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 알림 ID | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 2 | event_id | VARCHAR(64) | N | UK (uk_notification_event_recipient_type; 복합) |  | 알림을 만든 이벤트 ID | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 3 | recipient_user_id | BIGINT | N | UK (uk_notification_event_recipient_type; 복합), IDX (idx_notification_recipient_read_created; 복합) |  | user_db.user.id의 논리 참조; FK 없음 · CHECK > 0 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 4 | type | VARCHAR(50) | N | UK (uk_notification_event_recipient_type; 복합) |  | 알림 유형 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 5 | title | VARCHAR(100) | N |  |  | 알림 제목 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 6 | body | VARCHAR(500) | N |  |  | 알림 본문 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 7 | target_match_id | BIGINT | Y |  |  | match_db.matches.id의 논리 참조; FK 없음 · CHECK NULL 또는 > 0 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 8 | created_at | TIMESTAMP(6) | N | IDX (idx_notification_recipient_read_created; 복합) | CURRENT_TIMESTAMP(6) | 생성 일시 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | notification | 9 | read_at | TIMESTAMP(6) | Y | IDX (idx_notification_recipient_read_created; 복합) |  | 읽음 일시 (NULL = 미읽음) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | processed_events | 1 | event_id | VARCHAR(64) | N | PK |  | 처리한 이벤트 ID (중복 처리 방지) | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | processed_events | 2 | event_type | VARCHAR(80) | N |  |  | 이벤트 유형 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |
| notification_db | notification-service | processed_events | 3 | processed_at | TIMESTAMP(6) | N |  | CURRENT_TIMESTAMP(6) | 처리 시각 | DDL 신규 테이블 | R10 / PR #126 @cd038ce |

## 관계·인덱스·제약

> 원본 시트 `관계_인덱스`: R10 SQL 명시 PK·UNIQUE·CHECK·인덱스·FK 79개 + MariaDB JSON 자동 CHECK 2개. NO FK는 논리 참조 설명. 마지막 03 선택 제약 2건은 기본 스키마 제외.

| DB | 테이블 | 명칭 | 제약/인덱스 | 목적 | 조치 |
| --- | --- | --- | --- | --- | --- |
| user_db | user | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| user_db | user | idx_user_suspended_until | INDEX (suspended_until) | R10 DDL의 조회 성능 지원 | R10 기본 (추가) |
| user_db | user | uk_user_email | UNIQUE (email) | 로그인 이메일 중복 방지 | R10 기본 (갱신) |
| user_db | user | ck_user_role | CHECK (role IN ('USER','ADMIN')) | 권한 값 제한 | R10 기본 (갱신) |
| user_db | user | ck_user_gender | CHECK (gender IN ('MALE','FEMALE')) | 성별 값 제한 (ENUM 대체) | R10 기본 (갱신) |
| user_db | user | ck_user_status | CHECK (status IN ('ACTIVE','WITHDRAWING','WITHDRAWN')) | 상태 값 제한 (ENUM 대체) | R10 기본 (갱신) |
| user_db | user | ck_user_points | CHECK (points BETWEEN 0 AND 100) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | user | ck_user_attendance_reward_count | CHECK (attendance_reward_count BETWEEN 0 AND 4) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| user_db | point_history | uk_point_history_request_reason | UNIQUE (request_id,reason) | 같은 요청·같은 사유 중복 이력 방지. NULL 요청인 가입/정지 해제 이력은 서비스에서 중복 방지 | R10 기본 (추가) |
| user_db | point_history | uk_point_history_request_decision | UNIQUE (request_decision_key) | C:요청은 차감/취소 선도착 배타, S:요청은 반환/노쇼 배타. 반환과 출석 보상은 함께 허용 | R10 기본 (추가) |
| user_db | point_history | idx_point_history_user_created | INDEX (user_id,created_at) | R10 DDL의 조회 성능 지원 | R10 기본 (추가) |
| user_db | point_history | fk_point_history_user | FOREIGN KEY (user_id) REFERENCES user_db.`user`(id) ON DELETE RESTRICT ON UPDATE RESTRICT | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | ck_point_history_reason | CHECK (reason IN ('SIGNUP','SUSPENSION_EXPIRED','DEPOSIT_CHARGED','DEPOSIT_RETURNED','DEPOSIT_CANCELLED','ATTENDANCE_REWARDED','NO_SHOW_FORFEITED')) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | ck_point_history_points | CHECK (before_points BETWEEN 0 AND 100 AND after_points BETWEEN 0 AND 100 AND delta = after_points - before_points) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | ck_point_history_delta | CHECK ( (reason = 'DEPOSIT_CHARGED' AND delta < 0) OR (reason IN ('DEPOSIT_RETURNED','ATTENDANCE_REWARDED') AND delta >= 0) OR (reason IN ('DEPOSIT_CANCELLED','NO_SHOW_FORFEITED') AND delta = 0) OR reason IN ('SIGNUP','SUSPENSION_EXPIRED')) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | ck_point_history_match | CHECK ( (reason IN ('DEPOSIT_CHARGED','DEPOSIT_RETURNED','DEPOSIT_CANCELLED','ATTENDANCE_REWARDED','NO_SHOW_FORFEITED') AND match_id IS NOT NULL AND request_id IS NOT NULL AND source_event_id IS NOT NULL) OR (reason IN ('SIGNUP','SUSPENSION_EXPIRED') AND match_id IS NULL AND request_id IS NULL AND source_event_id IS NULL)) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| user_db | point_history | (FK 없음) | NO FK(match_id,request_id,source_event_id) | 다른 서비스의 매치·참가 요청·이벤트는 값으로 연결. 물리 FK 없음 | FK 없음(의도) |
| user_db | profile | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| user_db | profile | uk_profile_user | UNIQUE (user_id) | 동일 계정 1프로필 (구 uq_profile_user) | R10 기본 (갱신) |
| user_db | profile | uk_profile_nickname | UNIQUE (nickname) | 닉네임 중복 방지 | R10 기본 (갱신) |
| user_db | profile | fk_profile_user | FOREIGN KEY (user_id) REFERENCES user_db.`user`(id) ON DELETE RESTRICT ON UPDATE RESTRICT | 같은 User DB 내부 FK | R10 기본 (갱신) |
| user_db | sport_preference | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| user_db | sport_preference | uk_sport_preference_profile_sport | UNIQUE (profile_id,sport_type) | 동일 선호종목 중복 방지 (구 uq_profile_sport) | R10 기본 (갱신) |
| user_db | sport_preference | ck_sport_preference_type | CHECK (sport_type IN ('SOCCER','FUTSAL','BASKETBALL','BASEBALL','TENNIS','BADMINTON','TABLE_TENNIS','VOLLEYBALL','SWIMMING','RUNNING')) | 종목 값 제한 (ENUM 대체) | R10 기본 (갱신) |
| user_db | sport_preference | fk_sport_preference_profile | FOREIGN KEY (profile_id) REFERENCES user_db.profile(id) ON DELETE CASCADE ON UPDATE RESTRICT | 같은 User DB 내부 FK; 프로필 삭제 시 선호 종목 삭제 | R10 기본 (갱신) |
| user_db | withdrawal_saga | PRIMARY | PRIMARY KEY (saga_id) | 기본키 및 행 식별 | R10 기본 (추가) |
| user_db | withdrawal_saga | uk_withdrawal_saga_claim_token | UNIQUE (claim_token) | 탈퇴 요청 이벤트 중복 방지 | R10 기본 (갱신) |
| user_db | withdrawal_saga | idx_withdrawal_saga_status_deadline | INDEX (status,deadline_at) | 기한 초과 Saga 조회 | R10 기본 (갱신) |
| user_db | withdrawal_saga | idx_withdrawal_saga_user | INDEX (user_id) | 회원별 Saga 조회 | R10 기본 (갱신) |
| user_db | withdrawal_saga | fk_withdrawal_saga_user | FOREIGN KEY (user_id) REFERENCES user_db.`user`(id) ON DELETE RESTRICT ON UPDATE RESTRICT | 같은 User DB 내부 FK | R10 기본 (갱신) |
| user_db | withdrawal_saga | ck_withdrawal_saga_status | CHECK (status IN ('PROCESSING','CLEANED','REJECTED','TIMED_OUT')) | Saga 상태 값 제한 | R10 기본 (갱신) |
| user_db | withdrawal_saga | ck_withdrawal_saga_deadline | CHECK (deadline_at > requested_at) | 기한 정합성 | R10 기본 (갱신) |
| user_db | withdrawal_saga | ck_withdrawal_saga_finished | CHECK ((status = 'PROCESSING' AND finished_at IS NULL) OR (status IN ('CLEANED','REJECTED','TIMED_OUT') AND finished_at IS NOT NULL)) | 종료 시각 정합성 | R10 기본 (갱신) |
| user_db | processed_events | PRIMARY | PRIMARY KEY (event_id) | Consumer 중복 처리 방지(멱등) | R10 기본 (갱신) |
| user_db | outbox_event | PRIMARY | PRIMARY KEY (event_id) | 이벤트 ID 중복 방지 | R10 기본 (갱신) |
| user_db | outbox_event | idx_user_outbox_unpublished | INDEX (published_at,created_at) | 미발행 이벤트 조회 | R10 기본 (갱신) |
| user_db | outbox_event | payload | CHECK(json_valid(payload)) | MariaDB JSON 타입이 자동 생성하는 유효 JSON 검사. SQL에 직접 명명한 제약과 구분 | MariaDB 암묵 생성 |
| facility_db | location | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| facility_db | service | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| facility_db | service | uk_facility_service_external_id | UNIQUE (service_id) | 공공데이터 원본 ID 기준 upsert (구 uq_svcid) | R10 기본 (갱신) |
| facility_db | service | idx_facility_service_location | INDEX (location_id) | location 조인 지원 | R10 기본 (갱신) |
| facility_db | service | fk_facility_service_location | FOREIGN KEY (location_id) REFERENCES facility_db.location(id) ON DELETE RESTRICT ON UPDATE RESTRICT | 같은 Facility DB 내부 FK (구 fk_location) | R10 기본 (갱신) |
| match_db | matches | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| match_db | matches | uk_matches_creation_request | UNIQUE (creation_request_id) | R10 DDL의 고유성 보장 | R10 기본 (추가) |
| match_db | matches | idx_matches_status_start | INDEX (status,start_at) | 상태별 시작 시각 조회 | R10 기본 (갱신) |
| match_db | matches | idx_matches_status_end | INDEX (status,end_at) | 상태별 종료 시각 조회 | R10 기본 (갱신) |
| match_db | matches | idx_matches_sport_status_start | INDEX (sport_type,status,start_at) | 복합 매치 검색 성능 개선 (구 ix_match_filter) | R10 기본 (갱신) |
| match_db | matches | idx_matches_region_start | INDEX (region,start_at) | 지역별 매치 조회 | R10 기본 (갱신) |
| match_db | matches | idx_matches_facility | INDEX (facility_id) | 시설별 매치 조회 | R10 기본 (갱신) |
| match_db | matches | ck_matches_fields | CHECK (CHAR_LENGTH(TRIM(title)) > 0 AND max_participant >= 2 AND end_at > start_at AND facility_id > 0) | 제목 공백 금지·방장 포함 최소 정원 2명·시간 순서·시설 ID 양수 | R10 기본 (갱신) |
| match_db | matches | ck_matches_status | CHECK (status IN ('CREATION_PENDING','CREATION_FAILED','RECRUITING','CLOSED','IN_PROGRESS','COMPLETED','CANCELLED')) | 상태 값 제한 | R10 기본 (갱신) |
| match_db | matches | ck_matches_cancelled_at | CHECK (status <> 'CANCELLED' OR cancelled_at IS NOT NULL) | 취소 시각 정합성 | R10 기본 (갱신) |
| match_db | matches | ck_matches_skill | CHECK (skill_level IN ('BEGINNER','INTERMEDIATE','ADVANCED')) | 실력 값 제한 | R10 기본 (갱신) |
| match_db | matches | ck_matches_sport_type | CHECK (sport_type IN ('SOCCER','FUTSAL','BASKETBALL','BASEBALL','TENNIS','BADMINTON','TABLE_TENNIS','VOLLEYBALL','SWIMMING','RUNNING')) | 종목 값 제한 | R10 기본 (갱신) |
| match_db | matches | ck_matches_gender | CHECK (gender_group IN ('MALE','FEMALE','MIXED')) | 성별 구성 값 제한 | R10 기본 (갱신) |
| match_db | matches | (FK 없음) | NO FK(facility_id) | 다른 DB Facility 서비스 PK 논리 참조; Feign 검증 (구 fk_match_facility) | FK 없음(의도) |
| match_db | match_participants | PRIMARY | PRIMARY KEY (match_participant_id) | 기본키 및 행 식별 | R10 기본 (추가) |
| match_db | match_participants | uk_match_participants_match_user | UNIQUE (match_id,user_id) | 같은 매치 중복 참가 방지 (구 uq_match_user) | R10 기본 (갱신) |
| match_db | match_participants | uk_match_participants_request | UNIQUE (request_id) | R10 DDL의 고유성 보장 | R10 기본 (추가) |
| match_db | match_participants | idx_match_participants_user | INDEX (user_id) | 회원별 참가 매치 조회 | R10 기본 (갱신) |
| match_db | match_participants | fk_match_participants_match | FOREIGN KEY (match_id) REFERENCES match_db.matches(id) ON DELETE RESTRICT ON UPDATE RESTRICT | 같은 Match DB 내부 FK (구 fk_participant_match) | R10 기본 (갱신) |
| match_db | match_participants | ck_match_participants_user_id | CHECK (user_id > 0) | 논리 참조 ID 정합성 | R10 기본 (갱신) |
| match_db | match_participants | ck_match_participants_role | CHECK (role IN ('OWNER','PARTICIPANT')) | 역할 값 제한 | R10 기본 (갱신) |
| match_db | match_participants | ck_match_participants_participation | CHECK (participation_status IN ('PENDING','CONFIRMED','FAILED','CANCELLED')) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| match_db | match_participants | ck_match_participants_attendance | CHECK (match_participant_status IN ('ATTENDED','NO_SHOW')) | R10 DDL의 데이터 값·관계 정합성 | R10 기본 (추가) |
| match_db | match_participants | (FK 없음) | NO FK(user_id) | 다른 DB user-service PK 논리 참조; JWT/프로필 검증 (구 fk_participant_user) | FK 없음(의도) |
| match_db | match_waitlist | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| match_db | match_waitlist | uk_match_waitlist_match_user | UNIQUE (match_id,user_id) | 동일 매치 중복 대기 방지 | R10 기본 (갱신) |
| match_db | match_waitlist | idx_match_waitlist_match_order | INDEX (match_id,registered_at,id) | R10 DDL의 조회 성능 지원 | R10 기본 (추가) |
| match_db | match_waitlist | idx_match_waitlist_user | INDEX (user_id) | 회원별 대기 매치 조회 | R10 기본 (갱신) |
| match_db | match_waitlist | fk_match_waitlist_match | FOREIGN KEY (match_id) REFERENCES match_db.matches(id) ON DELETE CASCADE ON UPDATE RESTRICT | 같은 Match DB 내부 FK; 매치 삭제 시 대기자 삭제 | R10 기본 (갱신) |
| match_db | match_waitlist | ck_match_waitlist_user_id | CHECK (user_id > 0) | 논리 참조 ID 정합성 | R10 기본 (갱신) |
| match_db | match_waitlist | (FK 없음) | NO FK(user_id) | 다른 DB user-service PK 논리 참조 | FK 없음(의도) |
| match_db | processed_events | PRIMARY | PRIMARY KEY (event_id) | Consumer 중복 처리 방지(멱등) | R10 기본 (갱신) |
| match_db | outbox_event | PRIMARY | PRIMARY KEY (event_id) | 이벤트 ID 중복 방지 (구 uq_outbox_eventid) | R10 기본 (갱신) |
| match_db | outbox_event | idx_outbox_event_aggregate_id | INDEX (aggregate_id) | 집계 ID별 이벤트 조회 (R8 추가) | R10 기본 (갱신) |
| match_db | outbox_event | idx_match_outbox_unpublished | INDEX (published_at,created_at) | 미발행 이벤트 조회 | R10 기본 (갱신) |
| match_db | outbox_event | payload | CHECK(json_valid(payload)) | MariaDB JSON 타입이 자동 생성하는 유효 JSON 검사. SQL에 직접 명명한 제약과 구분 | MariaDB 암묵 생성 |
| notification_db | notification | PRIMARY | PRIMARY KEY (id) | 기본키 및 행 식별 | R10 기본 (추가) |
| notification_db | notification | uk_notification_event_recipient_type | UNIQUE (event_id,recipient_user_id,type) | 동일 이벤트·수신자·유형 알림 중복 방지 | R10 기본 (갱신) |
| notification_db | notification | idx_notification_recipient_read_created | INDEX (recipient_user_id,read_at,created_at) | 수신자별 읽음/최신순 조회 | R10 기본 (갱신) |
| notification_db | notification | ck_notification_recipient_id | CHECK (recipient_user_id > 0) | 논리 참조 ID 정합성 | R10 기본 (갱신) |
| notification_db | notification | ck_notification_match_id | CHECK (target_match_id IS NULL OR target_match_id > 0) | 논리 참조 ID 정합성 | R10 기본 (갱신) |
| notification_db | notification | (FK 없음) | NO FK(recipient_user_id), NO FK(target_match_id) | 다른 DB user_db.user / match_db.matches 논리 참조 | FK 없음(의도) |
| notification_db | processed_events | PRIMARY | PRIMARY KEY (event_id) | Consumer 중복 처리 방지(멱등) | R10 기본 (갱신) |
| match_db | matches | uk_matches_id_creation | UNIQUE(id,creation_request_id) | 03 선택 FK의 부모 복합키. 기본 스키마에는 없음 | 03 선택 · 기본 제외 |
| match_db | match_participants | fk_participants_owner_request | FOREIGN KEY(match_id,owner_request_key) REFERENCES matches(id,creation_request_id) ON DELETE RESTRICT ON UPDATE RESTRICT | 03에서만 생성되는 PERSISTENT owner_request_key로 방장 요청 ID 일치 강제 | 03 선택 · 기본 제외 |

## 마이그레이션 절차

> 원본 시트 `마이그레이션`: R10 적용 절차(실행 완료 로그 아님). 신규 설치와 R9→R10 변경 중 한 경로 선택. 기존 R8에 02 직접 실행 금지. 백업·빈 테이블 가드·코드 동시 배포 필요.

| 순서 | 단계 | 작업 | 검증/완료 기준 | 담당 영역 |
| --- | --- | --- | --- | --- |
| 1 | 기준 고정 | PR #126 cd038ce의 schema.sql·01·02·03 구분 | schema.sql과 01의 본문 일치, 03은 선택 파일 | DB·BE |
| 2 | 백업 및 경로 선택 | 기존 데이터/구조 백업 후 신규 설치 또는 R9→R10 중 한 경로 선택 | 기존 R8에는 02를 바로 실행하지 않음 | DB·Infra |
| 3 | 신규 설치 | 빈 DB 환경에서 schema.sql 또는 01_R10 실행. 둘은 같은 DDL이므로 한 번만 실행 | DB 4개·테이블 16개·컬럼 130개·기본 FK 7개 | DB·Infra |
| 4 | 기존 R9 사전 점검 | 02 실행 전 point_history·matches·match_participants가 비어 있어야 함. 데이터 삭제는 별도 승인/공지 절차 | 비어 있지 않으면 SIGNAL로 ALTER 전 중단 | DB |
| 5 | 기존 R9 변경 | 02_R9_to_R10은 DELIMITER·복합문을 지원하는 mariadb 클라이언트로 실행. 1회용, --force 금지, 오류 시 즉시 중단 | 신규 설치와 컬럼·인덱스·CHECK·FK 일치 | DB |
| 6 | 선택 제약 | 01 또는 02 적용 후 선택 적용. 먼저 OWNER 참가 행의 request_id와 같은 매치의 creation_request_id 불일치가 0건인지 조회. 불일치가 있으면 원인을 확인·정리한 뒤 03 실행; 그대로 실행하면 FK 추가 실패 | owner_request_key 생성 컬럼·방장 요청 ID FK 추가, FK 7→8개 | DB·BE |
| 7 | 권한 | init.sql에서 서비스별 앱 계정에 자기 DB의 SELECT/INSERT/UPDATE/DELETE만 부여 | 다른 DB 접근 및 DDL 거부 확인은 배포 환경에서 수행 | DB·Infra |
| 8 | 코드와 동시 전환 | R10 필수 요청 ID·참가 상태를 쓰는 서비스 코드와 같은 배포 단위로 적용 | DDL만 먼저 적용해 기존 생성·참가가 깨지지 않도록 일정 조율 | BE·Infra |
| 9 | 구조·제약 검증 | DEFAULT·UNIQUE·CHECK·RESTRICT/CASCADE·선택 FK를 확인 | 격리 MariaDB 11.4.13에서 DDL 24항목 통과(팀 DB 적용 아님) | DB |
| 10 | 서비스 검증 | 회원 가입·생성·참가·취소·출석·정산·정지 및 Kafka 중복/지연 통합 확인 | Compose 전체 E2E는 별도 검증 결과로 기록 | BE·QA |
| 11 | 적용 증빙 | 팀 DB 적용 날짜·버전·SHOW CREATE TABLE·실행 로그 기록 | 현재 문서 수정/격리 검증과 실제 팀 DB 적용을 구분 | DB·Infra |

## 상태값·Redis

> 원본 시트 `Enum_Redis`: R10 DDL의 상태·권한·종목·포인트 사유와 저장 범위. Redis 항목은 기존 참고이며 DDL 테이블이 아님.

| 타입/키 | 값 | 소유 | 주의 |
| --- | --- | --- | --- |
| UserStatus | ACTIVE, WITHDRAWING, WITHDRAWN | user-service | 탈퇴 시 물리 삭제 아닌 상태 전환; DDL: VARCHAR(20) + CHECK (WITHDRAWING 추가) |
| UserRole | USER, ADMIN | user-service | R10 VARCHAR(10)+CHECK. 기본 USER |
| Gender | MALE, FEMALE | user-service | DDL: VARCHAR(10) + CHECK (ENUM 대체) |
| District | 서울 25개 자치구 enum | user-service | DDL: VARCHAR(30), CHECK 없음 → 애플리케이션에서 enum 검증; 단순 지역 문자열(region)과 매핑 필요 |
| SportType | SOCCER,FUTSAL,BASKETBALL,BASEBALL,TENNIS,BADMINTON,TABLE_TENNIS,VOLLEYBALL,SWIMMING,RUNNING | 공통 계약 | API 문자열 값은 계약에서 고정; DDL: VARCHAR(15) + CHECK (sport_preference, matches) |
| SkillLevel | BEGINNER, INTERMEDIATE, ADVANCED | match-service | DDL: VARCHAR(30) + CHECK |
| GenderGroup | MALE, FEMALE, MIXED | match-service | 사용자 성별 vs 매치 조건 구분; DDL: VARCHAR(10) + CHECK |
| MatchStatus | CREATION_PENDING, CREATION_FAILED, RECRUITING, CLOSED, IN_PROGRESS, COMPLETED, CANCELLED | match-service | R10 VARCHAR(20)+CHECK 7개 상태. 기본 CREATION_PENDING. CANCELLED는 cancelled_at 필수 |
| MatchParticipantRole | OWNER, PARTICIPANT | match-service | 개설자가 OWNER로 참가; DDL: VARCHAR(20) + CHECK |
| WithdrawalSagaStatus | PROCESSING, CLEANED, REJECTED, TIMED_OUT | user-service | DDL 신규; PROCESSING이면 finished_at NULL, 그 외는 NOT NULL |
| ParticipationStatus | PENDING, CONFIRMED, FAILED, CANCELLED | match-service | 기본 PENDING. 실제 참가 인원/명단/정산은 CONFIRMED 기준 |
| MatchParticipantStatus | ATTENDED, NO_SHOW | match-service | 출석 결과, 기본 ATTENDED. participation_status와 구분 |
| PointHistoryReason | SIGNUP, SUSPENSION_EXPIRED, DEPOSIT_CHARGED, DEPOSIT_RETURNED, DEPOSIT_CANCELLED, ATTENDANCE_REWARDED, NO_SHOW_FORFEITED | user-service | R10 CHECK 7개 사유. 매치 관련은 match_id/request_id/source_event_id 필수; SIGNUP·SUSPENSION_EXPIRED는 모두 NULL |
| points | 기본 50, 0~100 | user-service | CHECK ck_user_points |
| attendance_reward_count | 기본 0, 0~4 | user-service | 5회 달성 시 보상 후 0으로 초기화. CHECK로 저장 범위 제한 |
| Redis | refresh:{userId} | user-service | TTL은 Refresh 토큰 만료 시각과 동일 |

## 차이와 결정 이력

> 원본 시트 `차이_결정`: 기존 1차 대비 결정 이력을 유지하고 R10 DB 관련 항목을 갱신. 명세 반영·DDL 실행 검증·사람의 승인·팀 DB 적용을 구분.

| 결정ID | 범주 | 기존 자료의 차이 | 근거 | 제안 처리 | 승인 상태 |
| --- | --- | --- | --- | --- | --- |
| D-01 | 매치 목록 API | 1차 테스트 일부 /api/matches/search 표기 vs 코드 /api/matches | GitHub MatchController @GetMapping + 1차 요구사항 API 표 | 공개 API는 GET /api/matches 유지; /search 별도 추가하지 않음 | 확정 제안 |
| D-02 | PK 데이터 타입 | ERD 이미지 일부 INT vs 9/29 테이블 명세와 Entity Long/BIGINT | 테이블 명세(9/29), JPA Entity | BIGINT 기준. 원본 ERD는 설명용으로만 사용 | 확정 제안 |
| D-03 | 시설 예약 | 시설 예약 서비스 목록·외부 URL 제공 vs 실제 예약 처리 | 1차 발표자료·API·ServiceEntity | 직접 예약/결제 기능은 범위 밖. 외부 예약 링크 제공 | 확인 |
| D-04 | DB 분리 | 1차 단일 DB의 JPA FK가 서비스 경계 간 연결 | MatchEntity/MatchParticipantEntity | matches.facility_id와 참가자.user_id 등은 타 DB ID 값만 저장. 같은 DB 내부만 FK | R10 DDL 반영 |
| D-05 | 정원/상태 | 원본 RECRUITING/CLOSED, 개설자 OWNER 자동 참가 | 테이블 명세·MatchService | 방장을 포함한 최소 정원 2명. CREATION_* 포함 7개 상태 및 CONFIRMED 기준 참가 | R10 DDL 반영 |
| D-06 | 차별화 기술 | 2차 10번 기술은 조별 1개 채택 | 2차 공식 안내 PDF 8p | 모니터링(Micrometer/Prometheus/Grafana) 우선 제안; 팀 확정 필요 | 승인 필요 |
| D-07 | 버전 호환성 | 1차 Spring Boot 3.5.4 | build.gradle + Spring Cloud 호환성 표 | Spring Cloud 2025.0.x 계열 BOM 사용, 부트 3.5.x 버전 조합 실제 빌드 검증 | 확인 필요 |
| D-08 | 데이터 샘플 | 공공 API 접근·키·원본 데이터는 환경 의존 | 1차 요구/시연 | 기존 DB 시드 및 Mock으로 필수 E2E 재현; 실제 API 키는 팀 준비 | 확인 필요 |
| D-09 | API 오류 형식 | 1차 컨트롤러마다 검증 오류 DTO 형태가 일부 다름 | MatchController, ErrorResponse | 2차 Gateway 전면 오류 표준화는 선택적; 기존 FE 호환 우선 | 승인 필요 |
| D-10 | 테스트 상태 | 1차 테스트 케이스 표에 Pass 기재 | 1차 테스트 문서 | R10 DDL 격리 검증 24개 PASS. 과거 테스트 기록·서비스 통합·팀 DB 적용은 별도 | DDL 검증 완료 / 통합 별도 |
| D-11 | DB/스키마 명칭 | 이전 명세 sporty_identity/facility/match/ai 4개 vs DDL user_db/facility_db/match_db/notification_db 4개; AI 서비스는 DB 없음 | PR #126 schema.sql / R10 DDL | R10 DB 4개·16테이블·130컬럼 기준. AI DB 없음. 교차 DB 물리 FK 없음 | 명세 반영 / 교차 검토 대기 |
| D-12 | 테이블·컬럼명 | match → matches, match_participant → match_participants, match.service_id → matches.facility_id (API 필드명은 serviceId) | PR #126 schema.sql / R10 DDL | DDL 기준 반영. API 명세서 경로·DTO 필드명은 유지하고 엔티티에서 매핑 | 확인 |
| D-13 | 상태값 | 1차 MatchStatus 2개에서 R10은 7개로 확장: CREATION_PENDING / CREATION_FAILED / RECRUITING / CLOSED / IN_PROGRESS / COMPLETED / CANCELLED. UserStatus는 WITHDRAWING을 포함하며 취소 시각·사유를 기록 | PR #126 schema.sql / R10 DDL | MatchStatus 7개, ParticipationStatus 4개, 출석 상태 2개 및 포인트 사유 7개를 명세에 반영 | 명세 반영 / 교차 검토 대기 |
| D-14 | 타입 표기 | ENUM → VARCHAR + CHECK, TIMESTAMP → TIMESTAMP(6), BIT(1) → BOOLEAN, TIME(6) → TIME, DATETIME → DATETIME(6); district는 CHECK 없이 VARCHAR(30) | PR #126 schema.sql / R10 DDL | DDL 타입으로 반영; district 값 검증은 애플리케이션 책임 | 확인 |
| D-15 | 이벤트 계약 | API 명세서 Kafka_이벤트는 ai-service match_projection·aggregateVersion 기반(EVT-01~04), DDL에는 projection 테이블과 matches.aggregate_version이 없고 outbox_event.aggregate_id는 VARCHAR(64) | PR #126 schema.sql / R10 DDL | 기존 projection/aggregateVersion 설명은 이전 자료. R10은 Outbox·processed_events·request_id를 사용하며 이벤트 전문은 POINT_SAGA.md에서 관리 | DDL 명세 반영 / 이벤트 별도 |
| D-16 | 신규 테이블 대응 API | match_waitlist, notification, withdrawal_saga, matches 취소 컬럼(cancel_reason 등)에 대응하는 API가 API 명세서에 없음; API-I01 응답에는 locationName·url이 없어 matches.location_name(NOT NULL)·url 스냅샷 채우기에 부족 | PR #126 schema.sql / R10 DDL | 이전 API 누락 판단은 과거 이력. R10 DB 명세는 요청/참가/출석 구조를 기술하며 API의 202·상태 조회·출석 응답은 별도 명세와 대조 | DDL 명세 반영 / API 별도 |
| R10-01 | 포인트 이력 | R9 UNIQUE(user_id,match_id)는 차감·반환을 함께 기록할 수 없음 | R10 point_history | 기존 고유키 제거, UNIQUE(request_id,reason) 및 생성 컬럼 UNIQUE(request_decision_key) | 명세 반영 / 교차 검토 대기 |
| R10-02 | 방장 요청 ID | 방장 request_id가 creation_request_id와 다르면 정산 식별 불일치 | R10 matches / match_participants | 코드 규칙은 동일 ID. 03 FK는 선택 파일로 기본 스키마와 분리 | 명세 반영 / 교차 검토 대기 |
| R10-03 | 신규/변경 SQL | 신규 설치와 기존 DB 변경은 서로 다른 실행 경로 | R10 01 / 02 / 03 | 01은 빈 환경, 02는 비어 있는 지정 테이블의 R9 전용, 03은 별도 선택 | 명세 반영 / 교차 검토 대기 |

## 근거와 용어

> 원본 시트 `근거_및_용어`: 최신 기준: PR #126 @cd038ce의 R10 DDL. 과거 자료는 이력으로 유지. 격리 MariaDB 실행 검증과 실제 팀 DB 적용은 별도.

| 자료 | 경로·URL | 활용·주의 | 기준일 |
| --- | --- | --- | --- |
| 1차 프로젝트 계획 | 2조_프로젝트_수행계획서.pdf | 원본 팀/주제/목표/제외범위 | 2026-09-16 |
| 1차 요구사항 | 2조_요구사항_명세서(1).pdf | USR/PR/EM/AI/FC 기능과 API 요구 | 2026-09-29 |
| 1차 DB 명세 | 2조_테이블_명세서.xlsx | 기존 7개 엔티티/컬럼(최신) | 2026-09-29 |
| 1차 ERD 이미지 | 2조_ERD.png | 참고 이미지, 일부 ID INT 표기 | 1차 |
| 1차 테스트 케이스 | 2조_테스트_케이스.pdf | 1차 TC; 2차 재실행 아님 | 1차 |
| 1차 발표자료 | 2조_발표자료.pptx | 1차 성과/기능/시스템 구조 | 2026-09-30 |
| 1차 화면설계 | 2조_화면설계도(1).pdf | 12페이지 UI 플로우/라우트 | 1차 |
| 1차 WBS | 2조_WBS.xlsm | 과거 41개 완료 업무, 2차 WBS와 별개 | 1차 |
| GitHub main | https://github.com/livelykitten/inspire_6th_mini_1_sporty/tree/main | 정적 코드 확인(실행 X), SHA 02533ba6ca253e2cbb6beb75c2f78fdf68a7ba8c | 2026-10-30 |
| 2차 공식 안내 | [CNS 6기]_미니PJT2 수강생 안내.pdf | MSA 필수 1~10 및 평가 기준 | 2026-10-30 |
| 이전 DDL (R8·이력) | Sporty_v2_A_R8_install.sql | 이전 명세 기준 이력. 현재 구조는 아래 R10 기준을 사용 | R8 (2026-10-30 계획 기준) |
| 최신 통합 PR (R10) | https://github.com/batontouch-sporty/backend/pull/126 | 명세 기준 커밋 cd038ce6756571bbc95d24a6673e777651a64954. PR 병합/팀 DB 적용과 문서 반영은 별도 | 2026-11-03 |
| R10 기준 스키마 | https://github.com/batontouch-sporty/backend/blob/cd038ce6756571bbc95d24a6673e777651a64954/docker/mariadb/schema.sql | 기본 DB 4·테이블 16·컬럼 130·물리 FK 7. 모든 타입/제약/인덱스 기준 | 2026-11-03 |
| R10 신규 설치 01 | https://github.com/batontouch-sporty/backend/blob/cd038ce6756571bbc95d24a6673e777651a64954/docker/mariadb/r10/01_Sporty_v2_A_R10_DDL.sql | schema.sql과 동일. 빈 환경 설치용 | 2026-11-03 |
| R9→R10 변경 02 | https://github.com/batontouch-sporty/backend/blob/cd038ce6756571bbc95d24a6673e777651a64954/docker/mariadb/r10/02_Sporty_v2_A_R9_to_R10_migration.sql | R9 전용·1회용. 지정 3개 테이블 비움·백업·오류 시 중단 필요 | 2026-11-03 |
| 선택 제약 03 | https://github.com/batontouch-sporty/backend/blob/cd038ce6756571bbc95d24a6673e777651a64954/docker/mariadb/r10/03_optional_owner_request_fk.sql | 기본 130컬럼/7FK에 포함 안 함. 적용 시 owner_request_key·복합 UNIQUE·FK 추가 | 2026-11-03 |
| DDL 실행 검증 | MariaDB 11.4.13 · 격리된 임시 DB | 별도 격리 MariaDB 11.4.13 검증 기록: 24항목 PASS. 01과 R9+02 구조 일치·주요 제약·03 검증. 팀 DB 미변경. 아래 10.11.14 대조 결과와 실행 환경·검증 범위를 구분 | 2026-11-03 |
| 논리 참조 | 서비스 간 ID 값만 저장 | 다른 DB를 FK/JOIN으로 직접 참조하지 않음. API/이벤트로 확인 | R10 |
| 생성 컬럼 | point_history.request_decision_key | 일반 입력 컬럼이 아님. PERSISTENT 표현식을 DB가 계산하며 UNIQUE에 사용 | R10 |
| 요구사항 명세서 v1.0 | Sporty_v2_요구사항_명세서.pdf · 작성 2026-11-02 · 이상혁 | 테이블_개요의 EM·PT·NT·AD 등 기능 ID 근거. DB 분리 공통 8번, EM-01·09·11, PT-01~06과 대조 | 2026-11-03 |
| DDL·명세 별도 대조 기록 | MariaDB 10.11.14 · 교차 검토 기록 | schema.sql 신규 설치 후 130컬럼·명시 제약 79개·자동 JSON CHECK 2개 대조. 03 별도 구분. 11.4.13의 24항목을 이 환경에서 재실행한 결과는 아님 | 2026-11-03 |
