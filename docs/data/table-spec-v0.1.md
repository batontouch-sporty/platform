# Sporty v2 테이블 명세서

> 출처: `Sporty_MSA_2조_테이블_명세서(1).xlsx` · v0.1 · 팀 합의 전 설계 초안. 1차 코드 정적 확인은 2차 구현·실행 검증을 뜻하지 않습니다.
> **최신 결정:** [고도화 범위와 문서 차이](../decisions/2026-10-30-scope-update.md)를 먼저 확인하세요. 이 변환본은 원본 보존을 위해 4개 서비스와 기존 이벤트 설계를 그대로 담습니다.


## 테이블 개요

1차 7개 테이블을 유지하되 물리/논리 DB를 서비스별로 분리합니다. 교차 DB FK는 제거합니다.

| 테이블 | 논리명 | 소유 서비스 | DB/스키마 | 범위 | 기능 ID | 설명 |
| --- | --- | --- | --- | --- | --- | --- |
| user | 회원 | identity-service | sporty_identity | 기존 유지 | USR | 이메일, 비밀번호 해시, 상태 및 탈퇴 시각 |
| profile | 회원 프로필 | identity-service | sporty_identity | 기존 유지 | PR | 회원 1:1, 활동 자치구·닉네임 |
| sport_preference | 선호 종목 | identity-service | sporty_identity | 기존 유지 | PR | 프로필 1:N, (profile_id,sport_type) 복합 고유 |
| location | 시설 장소 | facility-service | sporty_facility | 기존 유지 | FC | 자치구, 장소명, 좌표 |
| service | 예약 서비스 정보 | facility-service | sporty_facility | 기존 유지 | FC | 공공시설 API 원본 SVCID, 상태, 이용시간, 예약 URL |
| match | 운동 매치 | match-service | sporty_match | FK 경계 변경 | EM | 종목·상태·정원·시설 참조 ID |
| match_participant | 참가자 | match-service | sporty_match | FK 경계 변경 | EM | OWNER / PARTICIPANT; (match_id,user_id) 복합고유 |
| outbox_event | 발행할 이벤트 | match-service | sporty_match | 신규 개선(비배점 P2) | MSA-06/ENH-05 | DB 커밋과 이벤트 저장 원자화(선택 사항) |
| match_projection | AI 추천 조회 모델 | ai-service | sporty_ai | 신규 필수(P0) | MSA-06 | Match 이벤트로 비동기 갱신 |
| processed_event | 이벤트 소비 이력 | ai-service | sporty_ai | 신규 필수(P0) | MSA-06 | eventId 중복 처리 방지 |


## 컬럼 명세

기존 컬럼 = 1차 9/29 테이블 명세에서 이관. 신규 컬럼 = 2차 설계안; FK/제약은 분리 후 재정의 필요.

| DB | 소유 서비스 | 테이블 | No | 컬럼 | SQL 타입 | NULL(Y/N) | 키/인덱스 | DEFAULT | 설명 | 이관 상태 / 변경 | 근거 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sporty_identity | identity-service | user | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 회원 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 2 | email | VARCHAR(50) | N | UK |  | 로그인 이메일 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 3 | password | VARCHAR(255) | N |  |  | 암호화된 비밀번호 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 4 | gender | ENUM('MALE','FEMALE') | N |  |  | 성별 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 5 | status | ENUM('ACTIVE','WITHDRAWN') | N |  | ACTIVE | 회원 상태 (탈퇴 시 WITHDRAWN) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 6 | withdrawn_at | DATETIME(6) | Y |  |  | 탈퇴 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 7 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | user | 8 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 프로필 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 2 | user_id | BIGINT | N | FK, UK |  | 회원 ID (user.id), 회원당 1개 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 3 | nickname | VARCHAR(50) | N | UK |  | 닉네임 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 4 | district | ENUM(서울 25개 자치구) | N |  |  | 활동 자치구 (예: MAPO, GANGNAM) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 5 | image_url | VARCHAR(255) | Y |  |  | 프로필 이미지 URL | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 6 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | profile | 7 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | sport_preference | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 선호 종목 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | sport_preference | 2 | profile_id | BIGINT | N | FK, UK |  | 프로필 ID (profile.id) | (profile_id,sport_type) 복합 UNIQUE, 각 컬럼 단독 UNIQUE 아님 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | sport_preference | 3 | sport_type | ENUM(10개 종목) | N | UK |  | SOCCER, FUTSAL, BASKETBALL, BASEBALL, TENNIS, BADMINTON, TABLE_TENNIS, VOLLEYBALL, SWIMMING, RUNNING | (profile_id,sport_type) 복합 UNIQUE, 각 컬럼 단독 UNIQUE 아님 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | sport_preference | 4 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_identity | identity-service | sport_preference | 5 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 장소 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 2 | region | VARCHAR(20) | N |  |  | 자치구명 (예: 강남구) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 3 | name | VARCHAR(100) | N |  |  | 장소명 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 4 | facility_name | VARCHAR(100) | Y |  |  | 시설명 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 5 | contact | VARCHAR(100) | Y |  |  | 연락처 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 6 | latitude | DECIMAL(18,15) | Y |  |  | 위도 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 7 | longitude | DECIMAL(18,15) | Y |  |  | 경도 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 8 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | location | 9 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 서비스 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 2 | location_id | BIGINT | N | FK |  | 장소 ID (location.id) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 3 | service_id | VARCHAR(50) | N | UK |  | 공공데이터 원본 서비스 ID (SVCID) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 4 | name | VARCHAR(200) | N |  |  | 서비스명 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 5 | status | VARCHAR(20) | Y |  |  | 예약 상태 (공공데이터 원본 값) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 6 | start_time | TIME(6) | Y |  |  | 이용 시작 시간 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 7 | end_time | TIME(6) | Y |  |  | 이용 종료 시간 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 8 | is_free | BIT(1) | Y |  |  | 무료 여부 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 9 | url | VARCHAR(200) | Y |  |  | 예약 페이지 URL | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 10 | reservation_deadline_at | DATETIME(6) | Y |  |  | 예약 마감 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 11 | active | BIT(1) | N |  | 1 | 활성 여부 (상세 조회는 활성 서비스만) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 12 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_facility | facility-service | service | 13 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | 매치 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 2 | service_id | BIGINT | N | FK |  | 체육시설 서비스 ID (service.id) | 2차: 교차 서비스 FK 제거, ID 값 참조 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 3 | title | VARCHAR(50) | N |  |  | 제목 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 4 | description | VARCHAR(500) | Y |  |  | 설명 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 5 | sport_type | VARCHAR(15) | N |  |  | 종목 (sport_preference와 같은 10개 값) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 6 | skill_level | VARCHAR(30) | N |  | 'BEGINNER' | 실력 수준 (BEGINNER, INTERMEDIATE, ADVANCED) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 7 | gender_group | VARCHAR(10) | N |  |  | 성별 구성 (MALE, FEMALE, MIXED) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 8 | max_participant | INT | N |  |  | 최대 참가 인원 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 9 | start_at | DATETIME | N |  |  | 시작 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 10 | end_at | DATETIME | N |  |  | 종료 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 11 | status | VARCHAR(10) | N |  | 'RECRUITING' | 모집 상태 (RECRUITING, CLOSED) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 12 | created_at | TIMESTAMP | N |  |  | 생성 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 13 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 1 | match_participant_id | BIGINT | N | PK | AUTO_INCREMENT | 참가 ID | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 2 | match_id | BIGINT | N | FK, UK |  | 매치 ID (match.id) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 3 | user_id | BIGINT | N | FK, UK |  | 회원 ID (user.id) | 2차: 교차 서비스 FK 제거, ID 값 참조 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 4 | role | VARCHAR(20) | N |  |  | 역할 (OWNER: 개설자, PARTICIPANT: 참가자) | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 5 | created_at | TIMESTAMP | N |  |  | 참가 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match_participant | 6 | updated_at | TIMESTAMP | N |  |  | 수정 일시 | 기존 유지 | 1차 테이블명세서(2026.09.29) |
| sporty_match | match-service | match | 1 | facility_name_snapshot | VARCHAR(200) | Y |  |  | 시설 서비스 장애 시 기존 표시/조회 지원 | 2차 추가(P1) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | match | 2 | region_snapshot | VARCHAR(20) | Y |  |  | 시설 지역 스냅샷 | 2차 추가(P1) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | match | 3 | is_free_snapshot | BOOLEAN | Y |  |  | 시설 무료 여부 스냅샷 | 2차 추가(P1) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | match | 4 | aggregate_version | BIGINT | N |  | 0 | Match 이벤트의 순서 제어용 버전 | 2차 추가(P1) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 1 | id | BIGINT | N | PK | AUTO_INCREMENT | Outbox row ID | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 2 | event_id | CHAR(36) | N | UK |  | 전역 UUID | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 3 | aggregate_type | VARCHAR(40) | N |  |  | 예: MATCH | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 4 | aggregate_id | BIGINT | N | IDX |  | match.id | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 5 | aggregate_version | BIGINT | N |  | 0 | 이벤트 순서 | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 6 | event_type | VARCHAR(60) | N |  |  | 예: MatchCreated | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 7 | payload | JSON | N |  |  | 이벤트 JSON 문서 | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 8 | publish_status | VARCHAR(16) | N |  | PENDING | PENDING/PUBLISHED/FAILED | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 9 | created_at | TIMESTAMP | N |  | CURRENT_TIMESTAMP | 발행 기록 시각 | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_match | match-service | outbox_event | 10 | published_at | TIMESTAMP | Y |  |  | 실제 발행 완료 시각 | 2차 비배점 개선(P2, ENH-05) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 1 | match_id | BIGINT | N | PK |  | match-service 식별자. DB FK 없음 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 2 | service_id | BIGINT | N | IDX |  | facility-service 식별자. DB FK 없음 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 3 | title | VARCHAR(50) | N |  |  | 검색 제목 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 4 | sport_type | VARCHAR(15) | N | IDX |  | 운동 종목 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 5 | skill_level | VARCHAR(30) | N |  |  | 숙련도 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 6 | gender_group | VARCHAR(10) | N |  |  | 성별 구성 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 7 | region | VARCHAR(20) | Y | IDX |  | 지역 스냅샷 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 8 | status | VARCHAR(10) | N | IDX |  | RECRUITING/CLOSED | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 9 | start_at | DATETIME | N |  |  | 시작 일시 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 10 | end_at | DATETIME | N |  |  | 종료 일시 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 11 | max_participant | INT | N |  |  | 정원 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 12 | current_participant_count | INT | N |  | 0 | 현재 인원 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 13 | aggregate_version | BIGINT | N |  | 0 | out-of-order 이벤트 방지 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | match_projection | 14 | updated_at | TIMESTAMP | N |  | CURRENT_TIMESTAMP | 최근 projection 갱신 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | processed_event | 1 | event_id | CHAR(36) | N | PK |  | 한 번 처리한 이벤트 UUID | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | processed_event | 2 | topic | VARCHAR(100) | N |  |  | 수신 Topic | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | processed_event | 3 | aggregate_id | BIGINT | N | IDX |  | Match ID | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | processed_event | 4 | aggregate_version | BIGINT | N |  | 0 | 수신 버전 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |
| sporty_ai | ai-service | processed_event | 5 | processed_at | TIMESTAMP | N |  | CURRENT_TIMESTAMP | 처리 시각 | 2차 신규 필수(P0, MSA-06) | 2차 MSA 신규 설계(미구현) |


## 관계 인덱스

유지 관계: user↔profile↔sport_preference, location↔service, match↔match_participant. 경계 간 FK는 제거.

| DB | 테이블 | 명칭 | 제약/인덱스 | 목적 | 조치 |
| --- | --- | --- | --- | --- | --- |
| sporty_identity | profile | uq_profile_user | UNIQUE(user_id) | 동일 계정 1프로필 | 유지 |
| sporty_identity | sport_preference | uq_profile_sport | UNIQUE(profile_id,sport_type) | 동일 선호종목 중복 방지 | 유지 |
| sporty_facility | service | uq_svcid | UNIQUE(service_id) | 공공데이터 원본 ID 기준 upsert | 유지 |
| sporty_facility | service | fk_location | FK(location_id)→location.id | 같은 Facility DB 내부 FK | 유지 |
| sporty_match | match_participant | uq_match_user | UNIQUE(match_id,user_id) | 같은 매치 중복 참가 방지 | 유지 |
| sporty_match | match_participant | fk_participant_match | FK(match_id)→match.id | 같은 Match DB 내부 FK | 유지 |
| sporty_match | match | fk_match_facility | NO FK(service_id) | 다른 DB Facility 서비스 PK 참조; Feign 검증 | 삭제 필수 |
| sporty_match | match_participant | fk_participant_user | NO FK(user_id) | 다른 DB Identity 서비스 PK 참조; JWT/프로필 검증 | 삭제 필수 |
| sporty_match | match | ix_match_filter | INDEX(sport_type,status,start_at) | 복합 매치 검색 성능 개선 | 신규 제안 |
| sporty_match | outbox_event | uq_outbox_eventid | UNIQUE(event_id) | 이벤트 발행 이력 중복 차단 | 선택(P2) |
| sporty_ai | processed_event | pk_processed_event | PRIMARY KEY(event_id) | Consumer exactly-once 효과(멱등) | 신규 필수 |
| sporty_ai | match_projection | ix_projection_query | INDEX(sport_type,region,status,start_at) | 추천 조건 조회 최적화 | 신규 필수 |


## 마이그레이션

주의: 이 목록은 적용 순서 제안이며 실행 완료 로그가 아님. 데이터 복제 전 원본 백업 필수.

| 순서 | 단계 | 작업 | 검증/완료 기준 | 담당 영역 |
| --- | --- | --- | --- | --- |
| 1 | Freeze | 1차 스키마 덤프/ERD, 기준 commit·테스트 fixture 고정 | 기존 코드에 영향 없는 복사본 확보 | 전체 |
| 2 | DB 생성 | sporty_identity / sporty_facility / sporty_match / sporty_ai DB와 독립 계정 준비 | 다른 DB SELECT 거부 | Infra·DB |
| 3 | Identity 이관 | user → profile → sport_preference 순서로 DDL/데이터 적재 | 기존 로그인/프로필 API 회귀 | BE |
| 4 | Facility 이관 | location → service 적재, source service_id(SVCID) UNIQUE 확인 | public serviceId(DB PK) 유지 | BE |
| 5 | Match 이관 | match + match_participant 적재 전 외부 FK 제거, service_id/user_id 값 유지 | 로컬 FK/UNIQUE 유지, cross DB FK 0 | BE |
| 6 | Projection 준비 | match_projection / processed_event 생성; 최초 match 데이터 백필 | 신규 이벤트 후 조회 모델 일치 | BE |
| 7 | Kafka 발행 | MatchCreated/Joined/Left/Deleted eventId + version 계약 반영 | 두 번 소비해도 집계 1회 | BE |
| 8 | Feign 연동 | Match→Facility, AI→Identity/Match 내부 API 연결 | 타 DB 직접 접근 0 | BE |
| 9 | 검증 | 전체 기능 회귀/동시성/장애/통합, 데이터 수 검증 | TC Pass 캡처 및 FAIL 이슈화 | QA |
| 10 | Cutover | Gateway 환경변수/경로 스위치; 롤백은 이전 Compose+DB 백업 | 기존 React 경로·토큰 플로우 정상 | Infra |


## Enum Redis

데이터 필드의 Enum은 1차 코드/명세 기준. Redis는 Identity Service 데이터로 논리적으로 소유.

| 타입/키 | 값 | 소유 | 주의 |
| --- | --- | --- | --- |
| UserStatus | ACTIVE, WITHDRAWN | identity-service | 탈퇴 시 물리 삭제 아닌 상태 전환 |
| Gender | MALE, FEMALE | identity-service | 기존 enum |
| District | 서울 25개 자치구 enum | identity-service | 단순 지역 문자열과 매핑 필요 |
| SportType | SOCCER,FUTSAL,BASKETBALL,BASEBALL,TENNIS,BADMINTON,TABLE_TENNIS,VOLLEYBALL,SWIMMING,RUNNING | 공통 계약 | API 문자열 값은 계약에서 고정 |
| SkillLevel | BEGINNER, INTERMEDIATE, ADVANCED | match-service | 기존 enum |
| GenderGroup | MALE, FEMALE, MIXED | match-service | 사용자 성별 vs 매치 조건 구분 |
| MatchStatus | RECRUITING, CLOSED | match-service | 기존 상태를 더 세분화하지 않음 |
| MatchParticipantRole | OWNER, PARTICIPANT | match-service | 개설자가 OWNER로 참가 |
| Redis | refresh:{userId} | identity-service | TTL은 Refresh 토큰 만료 시각과 동일 |


## 차이 결정

1차 자료 간 불일치/2차 보완안은 승인 후 반영. 이관 방향을 숨기지 않습니다.

| 결정ID | 범주 | 기존 자료의 차이 | 근거 | 제안 처리 | 승인 상태 |
| --- | --- | --- | --- | --- | --- |
| D-01 | 매치 목록 API | 1차 테스트 일부 /api/matches/search 표기 vs 코드 /api/matches | GitHub MatchController @GetMapping + 1차 요구사항 API 표 | 공개 API는 GET /api/matches 유지; /search 별도 추가하지 않음 | 확정 제안 |
| D-02 | PK 데이터 타입 | ERD 이미지 일부 INT vs 9/29 테이블 명세와 Entity Long/BIGINT | 테이블 명세(9/29), JPA Entity | BIGINT 기준. 원본 ERD는 설명용으로만 사용 | 확정 제안 |
| D-03 | 시설 예약 | 시설 예약 서비스 목록·외부 URL 제공 vs 실제 예약 처리 | 1차 발표자료·API·ServiceEntity | 직접 예약/결제 기능은 범위 밖. 외부 예약 링크 제공 | 확인 |
| D-04 | DB 분리 | 1차 단일 DB의 JPA FK가 서비스 경계 간 연결 | MatchEntity/MatchParticipantEntity | match.service_id,participant.user_id는 타 DB ID 참조만; cross-DB FK 금지 | 2차 제안 |
| D-05 | 정원/상태 | 원본 RECRUITING/CLOSED, 개설자 OWNER 자동 참가 | 테이블 명세·MatchService | 회원 이탈/정원 변경/동시 참여 시 원자 처리 유지 | 2차 제안 |
| D-06 | 차별화 기술 | 2차 10번 기술은 조별 1개 채택 | 2차 공식 안내 PDF 8p | 모니터링(Micrometer/Prometheus/Grafana) 우선 제안; 팀 확정 필요 | 승인 필요 |
| D-07 | 버전 호환성 | 1차 Spring Boot 3.5.4 | build.gradle + Spring Cloud 호환성 표 | Spring Cloud 2025.0.x 계열 BOM 사용, 부트 3.5.x 버전 조합 실제 빌드 검증 | 확인 필요 |
| D-08 | 데이터 샘플 | 공공 API 접근·키·원본 데이터는 환경 의존 | 1차 요구/시연 | 기존 DB 시드 및 Mock으로 필수 E2E 재현; 실제 API 키는 팀 준비 | 확인 필요 |
| D-09 | API 오류 형식 | 1차 컨트롤러마다 검증 오류 DTO 형태가 일부 다름 | MatchController, ErrorResponse | 2차 Gateway 전면 오류 표준화는 선택적; 기존 FE 호환 우선 | 승인 필요 |
| D-10 | 테스트 상태 | 1차 테스트 케이스 표에 Pass 기재 | 1차 테스트 문서 | 2차 신규 테스트는 전부 Not Run; 실제 재실행 후만 Pass | 확정 |


## 근거 및 용어

검증 기준: 1차 코드 정적 확인과 2차 신규 설계를 구분. 진행 완료 여부는 실제 실행 증빙으로 갱신.

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
| Spring Cloud 호환표 | https://spring.io/projects/spring-cloud/ | Boot 3.5.x ↔ Cloud 2025.0.x | 2026-10-30 확인 |
