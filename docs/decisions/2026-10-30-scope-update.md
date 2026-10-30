# Sporty v2 고도화 범위와 v0.1 문서 차이

**기준일:** 2026-10-30  
**상태:** 사용자와 팀이 이후 정한 프로젝트 방향. 세부 API·이벤트·테이블 계약과 실행 결과는 미확정·미검증.

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
2. [API·이벤트](../contracts/api-contract-v0.1.md): `/api/notifications` 목록/읽음/미읽음 수, 탈퇴 응답·상태 조회, 알림·Saga 이벤트의 `eventId`, 수신자, 실패 처리를 합의합니다. v0.1의 `EVT-01~05`는 확정된 알림/Saga 계약이 아닙니다.
3. [테이블](../data/table-spec-v0.1.md): `notification_db`, `withdrawal_saga`, 소비 이벤트 이력을 설계합니다. AI projection/`sporty_ai` 처리 여부를 먼저 결정합니다.
4. [테스트](../testing/test-cases-v0.1.md): 알림 중복·DLT, Saga 성공·거절·타임아웃·지연 이벤트, 장애 전후 Grafana 지표와 복구를 TC로 추가합니다. 실행 전 `Not Run` 유지.
5. 수행계획서의 4서비스 일정·역할/아키텍처 그림을 5서비스 기준으로 다시 승인하고, 변경된 API·DB·이벤트·TC ID를 연결합니다.

## 별도 결정이 필요한 충돌

- **AI DB:** v0.1은 Kafka projection을 `sporty_ai`에 둡니다. 최신 계획의 `ai-service`는 DB가 없습니다. 추천 후보를 Match Feign 조회로 대체할지, 조회 모델을 유지하며 데이터 소유권을 바꿀지 팀 합의가 필요합니다.
- **탈퇴 HTTP 의미:** v0.1 `DELETE /api/users/me`는 즉시 `204`를 기재합니다. 비동기 Saga가 완료되기 전 성공을 반환하는지, 접수 `202`와 상태 조회를 제공할지 FE와 합의해야 합니다.
- **원자적 발행:** v0.1 Outbox는 P2 제안입니다. Saga 및 알림에서 DB 커밋 뒤 이벤트 누락이 생기지 않도록 발행 방식과 복구 절차를 결정해야 합니다.
- **이름과 경로:** v0.1 `identity-service`와 최신 `user-service`가 혼재합니다. 서비스 설정, Feign 명칭, DB 접속, 문서 용어를 동기화해야 합니다.

이 문서는 최신 목표를 기록합니다. 실제 코드·테스트가 확인되기 전에는 구현 완료나 테스트 통과로 표시하지 않습니다.
