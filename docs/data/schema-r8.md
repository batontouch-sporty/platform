# Sporty v2 서비스별 DB 설계 R8

> 기준: DB 담당자 전달 R8 ERD·SQL(2026-11-01), [백엔드의 Compose 초기화 스키마](https://github.com/batontouch-sporty/backend/blob/main/docker/mariadb/schema.sql), [API 계약 v1.0](../contracts/api-spec-v1.0.md). 이 문서는 설계와 적용 절차를 설명합니다. 이 문서 작성 과정에서 실제 DB에 SQL을 실행하거나 결과를 확인하지 않았습니다.

## 파일과 적용 대상

| DB 상태 | 실행할 SQL | 뒤따르는 확인 |
| --- | --- | --- |
| 비어 있는 신규 MSA DB | [R8 신규 설치용](02_Sporty_v2_A_R8_DDL.sql) | [R8 적용 결과 확인](04_Sporty_v2_R8_verify.sql) |
| 네 서비스 DB가 R7인 기존 MSA DB | [R7→R8 변경용](03_Sporty_v2_R7_to_R8.sql) | [R8 적용 결과 확인](04_Sporty_v2_R8_verify.sql) |
| 이미 R8인 MSA DB | 설치·변경 SQL을 다시 실행하지 않음 | [R8 적용 결과 확인](04_Sporty_v2_R8_verify.sql) |

두 설치 경로는 **택일**합니다. 1차 모놀리스 `sporty` DB에는 어느 파일도 실행하지 않습니다. 적용 전 DB·데이터 백업과 현재 스키마를 확인하고, 스키마 변경 권한이 있는 DBA/마이그레이션 계정으로 실행합니다. 앱 계정은 자기 DB의 DML 권한만 사용합니다. 백엔드 Compose의 빈 데이터 볼륨 초기화에는 백엔드 저장소의 `docker/mariadb/schema.sql`이 실제 실행 원본입니다. 플랫폼 SQL 사본과 그 원본이 달라지면 적용 전에 대조해야 합니다. 기존 볼륨에 Compose 초기화 스크립트를 다시 올리는 것만으로 R7→R8 변경 SQL이 실행되지는 않습니다.

R7→R8 SQL의 `matches.url`과 `aggregate_id` 인덱스는 `IF NOT EXISTS`로 같은 이름의 대상을 건너뜁니다. **타입이나 인덱스 정의가 같다는 보증은 아니므로 확인 SQL로 검사**합니다. `match_waitlist` 생성은 1회용이며 테이블이 이미 있으면 실패하도록 설계됐습니다. MariaDB DDL은 일괄 롤백되지 않으므로 중간에 실패하면 재실행 전에 확인 SQL로 적용 지점을 파악합니다.

## DB 소유권과 테이블

MariaDB 서버 1대에 서비스별 DB 4개, 기본 테이블 총 **15개**입니다. AI 서비스의 소유 DB는 없습니다. 물리 FK **6개는 모두 같은 DB 안에만** 있으며 다른 서비스의 테이블에는 FK나 직접 JOIN을 걸지 않습니다.

| 서비스 / DB | 소유 테이블 | 같은 DB의 물리 FK |
| --- | --- | --- |
| 회원 / `user_db` | `user`, `profile`, `sport_preference`, `withdrawal_saga`, `processed_events`, `outbox_event` | `profile.user_id`, `sport_preference.profile_id`, `withdrawal_saga.user_id` |
| 시설 / `facility_db` | `location`, `service` | `service.location_id` |
| 매치 / `match_db` | `matches`, `match_participants`, `match_waitlist`, `processed_events`, `outbox_event` | `match_participants.match_id`, `match_waitlist.match_id` |
| 알림 / `notification_db` | `notification`, `processed_events` | 없음 |

`matches.facility_id`는 `facility_db.service.id`인 내부 PK를 저장합니다. 시설의 외부 API 식별자 `service.service_id`가 아닙니다. `match_participants.user_id`, `match_waitlist.user_id`, `notification.recipient_user_id`와 `notification.target_match_id`도 다른 서비스 ID의 **논리 참조**입니다. 대상 존재·상태 확인은 소유 서비스 API 또는 이벤트 계약에 따릅니다.

## R7에서 바뀐 스키마: `match_db` 세 항목

| 변경 | R8 정의 | 사용 흐름 |
| --- | --- | --- |
| `matches.url` | `VARCHAR(200) NULL` | 매치 생성 시 시설의 예약 링크를 스냅샷으로 복사. 이후 시설 데이터가 변해도 이미 저장한 매치 값은 자동 갱신되지 않음 |
| `match_waitlist` 신규 | `id` PK, `match_id` FK, `user_id` 논리 참조, `registered_at TIMESTAMP(6)` | `(match_id,user_id)` UNIQUE로 중복 대기 방지. `user_id` 인덱스. 매치 삭제 시 `ON DELETE CASCADE`로 대기 기록 제거 |
| `outbox_event.aggregate_id` | `idx_outbox_event_aggregate_id` 인덱스 | 탈퇴 Saga의 매치 결과 Outbox 이력 조회 지원 |

`match_participants.match_id` FK는 `ON DELETE RESTRICT`로 유지됩니다. 매치 삭제 시 참가자 정리 규칙은 대기열 CASCADE와 별개입니다. 매치 취소(`CANCELLED`)는 삭제가 아니므로 대기 기록을 보존합니다. 참가 취소에 따른 FIFO 자동 승급, 자격 재확인, 잠금·Outbox의 원자성은 [매치 서비스 구현 문서](https://github.com/batontouch-sporty/backend/blob/main/match-service/WAITLIST.md)와 코드에서 다룹니다. DDL만으로 승급 로직이 실행되지는 않습니다.

R7에서 이미 도입된 `user.role`(`USER`/ `ADMIN`), `withdrawal_saga`의 `PROCESSING`·종료 상태, `claim_token`은 **이번 R8의 새 변경이 아닙니다**. R8에서도 서비스별 회원 탈퇴 결과는 API·Kafka 이벤트로 연결하고, 늦은 `CLEANED`의 운영 경보는 별도 모니터링 정책으로 다룹니다.

## 적용 결과 확인과 해석

[확인 SQL](04_Sporty_v2_R8_verify.sql)은 `information_schema`만 조회합니다. `matches.url` 타입·NULL 허용, 대기열 컬럼과 시각 기본값·UNIQUE·인덱스·FK의 삭제 규칙·CHECK, 참가 FK 규칙, Outbox 인덱스, 테이블 15개 및 내부 FK 6개를 확인합니다. **각 검사와 마지막 `SUMMARY`가 `PASS`인지** 확인하고 실제 결과를 기록합니다. 이 SQL 자체가 데이터 이전이나 서비스 동작을 검증하지는 않습니다.

기본 테이블 15개와 물리 FK 6개는 R8 **기준 스키마의 정확한 개수**를 검사합니다. 후속 버전에서 테이블이나 FK를 추가한 DB라면 해당 검사는 FAIL이 될 수 있으므로 버전과 실제 스키마를 대조해야 합니다. 서비스별 `ddl-auto=validate` 기동 및 A9/A18/A19·탈퇴 Saga·알림의 API/이벤트 통합은 별도의 실행 검증입니다.

[R7 설계 문서](schema-r7.md)와 [R7 DDL](01_Sporty_v2_A_R7_DDL.sql)은 변경 이력으로 보관합니다. R4와 v0.1 명세도 과거 검토 자료이며 현재 신규 설치의 기준은 R8입니다.
