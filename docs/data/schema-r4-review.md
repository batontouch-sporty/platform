# Sporty_v2 서비스별 DB DDL R4 대조

> 기준: DB 담당자가 전달한 `Sporty_v2_A_DDL.sql` R4와 `Sporty_v2_A_permissions.sql.template`, 팀 확정 [API 계약 v1.0](../contracts/api-spec-v1.0.md). 2026-10-31 정적 대조 기록입니다. **실행 DB의 스키마 조회·DDL 적용·데이터 이관·통합 테스트는 수행하지 않았습니다.** R4는 신규 빈 환경 설치용이며 1차 `sporty` DB에 적용하는 마이그레이션이 아닙니다.

## 현재 DDL 구성

| DB | 테이블 | 책임 |
| --- | --- | --- |
| `user_db` | `user`, `profile`, `sport_preference`, `withdrawal_saga`, `processed_events`, `outbox_event` | 계정·프로필·Saga·이벤트 |
| `facility_db` | `location`, `service` | 시설 카탈로그 |
| `match_db` | `matches`, `match_participants`, `processed_events`, `outbox_event` | 매치·참가·이벤트 |
| `notification_db` | `notification`, `processed_events` | 알림·소비 이력 |

총 4개 DB·14개 테이블입니다. AI 전용 DB가 없고, 다른 서비스의 회원·시설 ID에는 교차 DB FK가 없습니다. 같은 DB 내 FK와 중복 방지 인덱스는 포함되어 있습니다.

## API와 맞추기 전에 해결할 사항

| 우선 | 관련 계약 | R4 상태 | 필요한 결정·수정 |
| --- | --- | --- | --- |
| 필수 | A2 내 정보의 `role`, A4 로그인 `role`·JWT ADMIN, A28·A31 관리자 권한 | `user_db.user`에 `role` 컬럼이 없음. `match_participants.role`은 방장/참가자 구분이어서 대신할 수 없음 | 회원 역할 `USER`/`ADMIN` 저장 방식, 기본값·관리자 초기 계정·기존 회원 이관 결정. DB 컬럼을 택한다면 DDL·엔티티·발급 로직 동시 변경 |
| 필수 | A9·A12 매치 생성·수정 시 시설 예약 링크 복사 | `facility_db.service.url`은 있으나 `match_db.matches`에 복사할 `url` 컬럼 없음 | 매치 스냅샷 컬럼 추가 또는 API의 복사 항목 변경을 팀 계약으로 합의. 계약 유지 시 DDL·엔티티·생성/수정 로직 동시 반영 |
| 확인 | A25 알림 `{message,matchId,read}` | DB는 `title,body,target_match_id,read_at` | API 응답의 `message`를 `body`로, `matchId`를 `target_match_id`로, `read`를 `read_at != null`로 매핑할지 확정. `title`의 화면 사용도 확인 |
| 확인 | A28 `withdrawalSaga.{succeeded,rejected,timedOut,inProgress}` | Saga 상태는 `REQUESTED,PROCESSING,CLEANED,REJECTED,TIMED_OUT` | `CLEANED`를 succeeded로 집계할지, `REQUESTED`·`PROCESSING`을 inProgress로 합산할지 통계 정의. `claimed_at`·`claim_token`의 처리 주체도 확정 |
| P1 | A18·A19 대기 등록·취소 및 자동 승급 | `match_waitlist` 테이블 없음 | P1 착수 시 대기 순서·중복·승급 원자성을 고려해 DDL·인덱스 추가. P0에서는 대기열 API 구현 여부를 구분 |

`notification`의 `(event_id,recipient_user_id,type)` 고유 제약은 알림 중복 저장을 막는 구조입니다. 소비 이력 `processed_events`를 여러 수신자 알림 저장과 어떤 트랜잭션 순서로 처리할지는 서비스 코드에서 확인해야 합니다.

## 배포·운영 주의

- DDL은 `CREATE DATABASE IF NOT EXISTS`를 사용하지만 각 `CREATE TABLE`에는 `IF NOT EXISTS`가 없습니다. 재실행 가능한 버전 마이그레이션 스크립트로 간주하지 않습니다.
- 권한 템플릿의 네 앱 계정에는 자기 DB에 대한 `SELECT, INSERT, UPDATE, DELETE`만 부여합니다. 초기 DDL은 별도 DBA 권한으로 실행하고, 각 계정의 타 DB 조회 차단을 실제 연결로 검증합니다.
- 템플릿의 호스트와 비밀번호는 플레이스홀더입니다. `CREATE USER IF NOT EXISTS`는 이미 있는 계정의 비밀번호를 바꾸지 않습니다. 실제 비밀번호는 Git/문서에 올리지 않습니다.
- 1차 모놀리스의 JPA 매핑과 R4의 `matches`·`match_participants` 등 테이블명이 다릅니다. 서비스 분리 전 코드를 이 스키마에 그대로 연결하지 않습니다. 특히 Hibernate 스키마 생성/삭제 설정을 사용하는 실행 프로필을 새 DB에 연결하지 않습니다.
- `SHOW CREATE TABLE`로 실제 적용 상태를 확인하고, 신규 설치 검증 및 기존 데이터 이관 절차를 별도로 작성합니다. 이 문서의 정적 대조는 SQL 실행 성공을 보장하지 않습니다.

## 문서 우선순위

[v0.1 테이블 명세](table-spec-v0.1.md)는 이 R4보다 오래된 원본 초안이며 `sporty_identity`, `sporty_ai`, `match`, `match_participant` 등의 이름과 AI projection 가정을 보존합니다. 구현자는 DB 담당자가 R4의 위 불일치와 실제 적용 버전을 확정한 뒤 그 결과를 기준으로 삼아야 합니다.
