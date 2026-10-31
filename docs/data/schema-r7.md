# Sporty v2 서비스별 DB 설계 R7

> 기준: DB 담당자 전달 [R7 DDL 원본](01_Sporty_v2_A_R7_DDL.sql), 서비스별 ERD 및 [HTTP API 계약 v1.0](../contracts/api-spec-v1.0.md). 2026-10-31 정적 대조입니다. **실제 DB에 적용하거나 데이터를 이관하고 통합 테스트한 결과는 아닙니다.** R7 DDL은 신규 빈 환경 설치용이며 1차 `sporty` DB의 마이그레이션 스크립트가 아닙니다.

## 데이터 소유권과 관계

MariaDB 서버 한 대 안에 서비스 소유 DB 네 개를 둡니다. `ai-service`의 자체 DB는 없습니다. **DB 사이에는 FK와 JOIN을 두지 않고**, 다른 서비스의 ID를 논리 참조로 저장합니다. 아래 FK는 같은 DB 안에서만 유효합니다.

| 소유 서비스 / DB | 테이블 | 같은 DB의 FK | 다른 서비스와의 경계 |
| --- | --- | --- | --- |
| `user-service` / `user_db` | `user`, `profile`, `sport_preference`, `withdrawal_saga`, `processed_events`, `outbox_event` | `profile.user_id`, `sport_preference.profile_id`, `withdrawal_saga.user_id` | 회원 ID·탈퇴 결과를 API·이벤트로 전달 |
| `facility-service` / `facility_db` | `location`, `service` | `service.location_id` | 시설 존재·운영 여부는 시설 API에서 확인 |
| `match-service` / `match_db` | `matches`, `match_participants`, `processed_events`, `outbox_event` | `match_participants.match_id` | `matches.facility_id`는 `facility_db.service.id`, `match_participants.user_id`는 `user_db.user.id`의 논리 참조 |
| `notification-service` / `notification_db` | `notification`, `processed_events` | 없음 | `recipient_user_id`·`target_match_id`는 다른 서비스의 ID만 저장 |

총 **14개 테이블**입니다. 매치 생성 시 시설 API로 검증하고 시설명·장소명·지역·무료 여부를 `matches`에 당시 값으로 복사합니다. 이후 시설 데이터 변경이 기존 매치 스냅샷에 어떻게 반영되는지는 별도 업무 규칙이 필요합니다.

## R4 이후 확인된 변경

- `user.role`은 `USER` 기본값이며 `USER`·`ADMIN`만 허용합니다. `match_participants.role`의 `OWNER`·`PARTICIPANT`와 다른 값입니다. 관리자 API A28~A31은 [API 계약](../contracts/api-spec-v1.0.md)에 따라 ADMIN JWT 권한 검사가 필요합니다. DDL의 역할 컬럼만으로 접근 제어가 완성되는 것은 아닙니다.
- 회원 탈퇴 요청은 `user-service`가 `withdrawal_saga`를 즉시 `PROCESSING`으로 저장하고, `claim_token`에 요청 이벤트 ID를 기록하는 설계입니다. `match-service`는 `user_db`를 변경하거나 Saga를 선점하지 않고 자기 DB의 매치를 정리해 `CLEANED` 또는 `REJECTED` 결과를 보냅니다. 요청의 Saga ID·이벤트 ID와 일치하는 결과만 적용합니다.
- 결과가 5분 동안 없으면 `user-service`가 30초 유예 후 `TIMED_OUT`으로 처리하고 회원 상태를 `ACTIVE`로 복구하는 흐름입니다. 마감 직후 도착하는 결과와의 경합, 중복 결과의 처리에는 애플리케이션 로직 및 실행 검증이 필요합니다. 타임아웃 이후 늦은 `CLEANED`는 회원 상태를 다시 바꾸지 않고 장애 기록과 지표를 남겨 운영자가 확인하도록 설계합니다. **운영 알림의 전달 방식(관리자 알림함 또는 로그·모니터링 경보)은 회의 후 결정**합니다. DDL 자체는 5분·30초 타이머나 알림 전송을 구현하지 않습니다.
- `withdrawal_saga`는 `PROCESSING`, `CLEANED`, `REJECTED`, `TIMED_OUT`을 허용하고, 종료 상태에는 `finished_at`을 요구합니다. `claim_token`은 고유합니다. 각 서비스의 `processed_events`는 이벤트 중복 처리 방지, `outbox_event`는 발행 대기 이벤트용입니다.

## API·구현과 대조할 사항

| 항목 | R7 DDL에서 확인한 사실 | 필요한 확인 |
| --- | --- | --- |
| A9 매치 생성의 예약 URL 복사 | `facility_db.service.url`은 있으나 `match_db.matches`에 예약 URL 스냅샷 컬럼은 없음 | API 계약의 URL 복사를 유지한다면 DB·서비스 구현을 함께 변경하거나 계약 변경을 팀과 합의 |
| A25 알림 응답 | `notification`에는 `title`, `body`, `target_match_id`, `read_at`이 있음 | `message`/`matchId`/`read` 응답 매핑과 관리자 운영 알림함 사용 여부를 각각 확인. 운영 알림 방식은 미정 |
| A28 탈퇴 Saga 통계 | `withdrawal_saga`에는 요청 시각·상태가 있음 | `requested`·`succeeded`·`rejected`·`timedOut`·`inProgress`의 기간 없는 누적 집계 기준과 재시도 처리 확인 |
| A18·A19 대기열(P1) | `match_waitlist` 테이블 없음 | P1 구현 시 스키마·동시성 규칙 결정 |
| 서비스 코드와 DB | R7은 신규 테이블과 제약을 정의함 | JPA 엔티티·DDL 자동 생성 설정·실제 `SHOW CREATE TABLE`과 대조한 뒤 연결 |

## 설치 및 권한 경계

- R7 SQL은 `CREATE DATABASE IF NOT EXISTS` 다음에 `IF NOT EXISTS` 없는 `CREATE TABLE`을 사용합니다. 반복 실행 가능한 변경 마이그레이션으로 취급하지 않습니다. 배포 전 MariaDB 버전과 `CHECK` 제약, 빈 DB 설치 결과를 검증합니다.
- 별도 전달된 `A_v2_permissions_local.sql`은 **같은 PC에서 서비스와 MariaDB를 실행하는 로컬 개발용**이며 실제 DB에 아직 적용되지 않았습니다. 각 앱 계정에 자기 DB의 `SELECT`, `INSERT`, `UPDATE`, `DELETE`만 주고 DDL 권한은 주지 않습니다. DB 생성·변경은 관리자 권한의 별도 절차로 수행해야 합니다.
- 권한 SQL에는 개발 비밀번호가 직접 들어 있으며 기존 로컬 계정을 `ALTER USER`로 갱신합니다. **이 원문은 저장소에 게시하지 않습니다.** 팀·운영 환경은 별도 비밀 관리와 실제 접속 호스트에 맞춘 계정 권한을 사용합니다. 앱 계정에 DDL 권한이 없으므로 Hibernate의 `create`, `create-drop`, `update` 같은 자동 스키마 변경 설정과 함께 사용하지 않습니다.
- 실제 적용 여부, 기존 데이터 이전, 서비스별 교차 DB 접근 차단, Saga 경합·장애 복구, 관리자 권한 및 대시보드 연동은 아직 검증되지 않았습니다.

[R4 대조 기록](schema-r4-review.md)과 [v0.1 테이블 명세](table-spec-v0.1.md)는 이전 설계의 검토 이력입니다. 실제 구현은 최신 팀 합의와 적용된 DB 스키마를 우선 확인해야 합니다.
