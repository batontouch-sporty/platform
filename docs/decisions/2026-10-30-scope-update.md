# Sporty v2 고도화 범위와 v0.1 문서 차이

**기준일:** 2026-10-30  
**상태:** 5개 서비스 방향과 [HTTP API v1.0](../contracts/api-spec-v1.0.md) 확정. Kafka 이벤트·테이블·실행 결과는 별도 확인이 필요합니다.

> **DB 후속 자료(2026-10-31):** 서비스별 [R7 DDL·정적 대조](../data/schema-r7.md)가 전달됐습니다. 아래 표는 2026-10-30의 범위 변경을 기록한 것으로, 실제 DB 적용·코드 연동을 뜻하지 않습니다. 탈퇴 처리의 늦은 결과에 대한 기록·지표·운영 확인은 설계됐지만 관리자 알림함과 로그·모니터링 경보 중 전달 방식은 회의 후 결정합니다.

첨부된 5개 v0.1 문서는 4개 비즈니스 서비스, AI 조회 모델용 Kafka 이벤트, `ACTIVE → WITHDRAWN` 탈퇴를 전제로 작성된 팀 합의 전 초안입니다. 이후 정한 Sporty v2 범위를 이 문서에 기록합니다. 구현자는 v0.1을 최신 계약으로 취급하지 말고 아래 차이를 먼저 해결해야 합니다.

| 주제 | v0.1 원본 | 최신 방향 | 필요한 갱신 |
| --- | --- | --- | --- |
| 서비스 | `identity`, `facility`, `match`, `ai` 4개 | `user`, `match`, `facility`, `ai`, 신규 `notification` 5개 | 서비스명·라우팅·소유 DB·포트·Health·Compose |
| Kafka | `sporty.match.events.v1`을 AI projection에 소비, `UserWithdrawn` 후속 | 참가·상태·시작 전·탈퇴 거절 알림 및 탈퇴 Saga 이벤트 | Producer/Consumer, topic/key/envelope, 멱등·재시도·DLT, 기존 projection 유지 여부 |
| 탈퇴 | Identity가 바로 `WITHDRAWN`, Match는 비동기 정리 | `ACTIVE → WITHDRAWING → WITHDRAWN`, 거절·5분 타임아웃 시 `ACTIVE` 보상 | API 응답 의미, `withdrawal_saga`, Match 정리·보상·중복/지연 이벤트 |
| 데이터 | Identity·Facility·Match·AI 네 DB와 projection | User·Match·Facility·Notification 소유 DB; AI는 DB 없음으로 계획 | AI projection 제거/대체 결론, Notification 알림·처리 이력, 교차 FK 0 |
| 모니터링 | MSA-10 기본 요청량·오류·응답·UP/DOWN | 서비스·Feign/CB·Kafka Lag/DLT·JVM·AI·Saga 지표와 장애/복구 검증 | Grafana 패널·계측·테스트·증빙, 선택 추적/부하/Slack |
| 선택 항목 | Circuit Breaker/K8s/부하/CI-CD 후보 | Circuit Breaker·분산 추적·부하·Slack·Saga 우선, Bus/암호화 후순위 | 공식 요구사항 번호와 점수 매핑 재확인 |

## 최신 목표 서비스와 데이터 경계

| 서비스 | 책임 | 데이터 소유 |
| --- | --- | --- |
| `user-service` | 인증·프로필·탈퇴 Saga | `user_db`, Redis, `withdrawal_saga` 계획 |
| `match-service` | 매치·참가·상태·탈퇴 정리 | `match_db` |
| `facility-service` | 공공시설 수집·조회 | `facility_db` |
| `ai-service` | 자연어 검색·초안·추천 | 자체 DB 없음 계획. v0.1 projection 설계의 처리 방향 합의 필요 |
| `notification-service` | 이벤트 소비·알림함·읽음 상태 | `notification_db` |

Gateway(8000), Eureka(8761), Config Server(8888), Feign, Kafka, Compose, Micrometer/Prometheus/Grafana를 공통 인프라로 계획합니다. 내부 API는 Gateway 외부 접근을 차단하고, 클라이언트의 `X-User-Id` 헤더를 신뢰하지 않습니다. 서비스별 DB 직접 접근 및 교차 DB FK는 허용하지 않습니다.

## 후속 계약 작업

1. [요구사항](../requirements/requirements-v0.1.md): `MSA-01/06/08`, `USR-04`와 신규 알림·Saga 요구 ID 및 인수 기준을 개정합니다. 기존 기능 21개 회귀는 유지합니다.
2. [HTTP API v1.0](../contracts/api-spec-v1.0.md)의 알림 목록·읽음·미읽음 수 및 탈퇴 202 응답은 확정되었습니다. Kafka 알림·Saga 이벤트의 `eventId`, 수신자, 실패 처리 등은 별도로 문서화합니다. v0.1의 `EVT-01~05`는 확정된 알림/Saga 계약이 아닙니다.
3. [R7 데이터 설계](../data/schema-r7.md): `notification_db`, `withdrawal_saga`, 소비 이벤트 이력과 AI 자체 DB 없음이 DDL에 반영됐습니다. 실제 DB 적용과 API·서비스 코드 정합성은 별도 검증합니다. [v0.1 테이블 명세](../data/table-spec-v0.1.md)는 이력으로 보존합니다.
4. [테스트](../testing/test-cases-v0.1.md): 알림 중복·DLT, Saga 성공·거절·타임아웃·지연 이벤트, 장애 전후 Grafana 지표와 복구를 TC로 추가합니다. 실행 전 `Not Run` 유지.
5. 수행계획서의 4서비스 일정·역할/아키텍처 그림을 5서비스 기준으로 다시 승인하고, 변경된 API·DB·이벤트·TC ID를 연결합니다.

## 별도 결정이 필요한 충돌

- **AI DB:** v0.1은 Kafka projection을 `sporty_ai`에 둡니다. [확정 API](../contracts/api-spec-v1.0.md)는 AI가 Match의 공개 `GET /api/matches`를 Feign으로 호출하며 AI DB가 없는 것으로 명시합니다. 기존 projection 설계는 현재 HTTP API 구현 기준이 아닙니다.
- **탈퇴 HTTP 의미:** v0.1은 즉시 `204`를 기재하지만, 확정 API A3는 접수 `202 {status:"WITHDRAWING",sagaId}`입니다. 프런트는 결과 알림 및 내 정보의 상태를 처리해야 합니다.
- **원자적 발행:** v0.1 Outbox는 P2 제안입니다. Saga 및 알림에서 DB 커밋 뒤 이벤트 누락이 생기지 않도록 발행 방식과 복구 절차를 결정해야 합니다.
- **이름과 경로:** v0.1의 `identity-service`·접두어 없는 외부 `/api/**` 대신 확정 API의 `user-service`·서비스 접두어가 있는 Gateway 경로를 구현에 적용합니다.

이 문서는 최신 목표를 기록합니다. 실제 코드·테스트가 확인되기 전에는 구현 완료나 테스트 통과로 표시하지 않습니다.
