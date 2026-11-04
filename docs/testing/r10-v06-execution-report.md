# Sporty v2 R10 v0.6 통합 E2E 최종 실행 보고서

> 사용자 제공 최종 보고서의 판정을 반영했습니다. 본문에 적힌 PNG·JSON·verdict 등 상대 증거 파일은 이번에 첨부되지 않았으므로 경로를 텍스트로 보존합니다. 이 저장소 정리 과정에서 시험을 다시 실행한 것은 아닙니다.

| 항목 | 결과 |
| --- | --- |
| 실행일 | 최초 2026-11-03, BLOCKED 2종 재시험 완료 2026-11-04 KST |
| 판정 | **PASS 11 · FAIL 0 · BLOCKED 0 · NOT RUN 0** |
| 코드 기준 | Backend `bacaa84518029c7c2656a2be64e4c2223bcc5e31`, Frontend `e01fdbfec10ddbbb09586dd55906a367d7d38d49`, Config `8695cafaab132caec94232cae2b9e03a58d746bb` (각 최신 main) |
| 시험 환경 | 별도 Compose 프로젝트 `sporty-k6-90`, Gateway `:18090`, Prometheus `:19090`, Grafana `:13001`; 개발 프로젝트 `sporty` 미기동, 개발 볼륨 보존 |
| 코드 변경 | Backend 업무 코드 및 Frontend 추적 파일 변경 없음. Commit·Push·PR 없음 |

## 1. 11종 판정

| 케이스 | 판정 | 핵심 실제 결과 | 케이스 증거 |
| --- | --- | --- | --- |
| TC-SAGA-001 | PASS | 방장 탈퇴 202→CLEANED/WITHDRAWN, 소유 매치 취소, 타 참가자 이력·환불 보존 | 세부 결과 (증거 경로: `./TC-SAGA-001/verdict.md`) |
| TC-SAGA-002 | PASS | 진행 중 방장 202→REJECTED/ACTIVE, 매치·포인트 불변, 거절 알림 1건 | 세부 결과 (증거 경로: `./TC-SAGA-002/verdict.md`) |
| TC-SAGA-003 | PASS | A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 | 재시험 결과 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/verdict.md`) |
| TC-POINT-001 | PASS | CREATE/JOIN 202→CONFIRMED, 각 50→40점·차감 1회, Kafka/DB 일치 | 세부 결과 (증거 경로: `./TC-POINT-001/verdict.md`) |
| TC-POINT-002 | PASS | 잔액 부족 FAILED, 정지 403, 비활성 400; 무차감·정상 계정 회귀 | 세부 결과 (증거 경로: `./TC-POINT-002/verdict.md`) |
| TC-POINT-003 | PASS | 기존 취소·성별 불일치/환불에 더해 차감 전 취소, 5분 만료·늦은 CHARGED, 동일·새 eventId 재전달까지 확인 | 재시험 결과 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/verdict.md`) |
| TC-POINT-004 | PASS | 출석 5회 보상, 노쇼 몰수·정지, 최소 인원 미달 반환, 중복 정산 불변 | 세부 결과 (증거 경로: `./TC-POINT-004/verdict.md`) |
| TC-OBS-001 | PASS | Facility DOWN 중 신규 A9 503, 기존 A11 200·스냅샷 불변, 1→0→1 복구 | 세부 결과 (증거 경로: `./TC-OBS-001/verdict.md`) |
| TC-OBS-002 | PASS | Facility 1.5초 지연: 168→1,902ms, Zipkin trace, 원복 뒤 확정 | 세부 결과 (증거 경로: `./TC-OBS-002/verdict.md`) |
| TC-OBS-003 | PASS | 100 VU·60초 5,517건·실패 0, 참가 100→확정 9/환불 91, DB 10/10 | 세부 결과 (증거 경로: `./TC-OBS-003/verdict.md`) |
| TC-OBS-004 | PASS | Notification DOWN 중 참가 5건 확정, Lag 0→5→0, 알림·재처리 중복 없음 | 세부 결과 (증거 경로: `./TC-OBS-004/verdict.md`) |

**판정 기준:** HTTP 202는 접수로만 취급했다. 각 PASS는 최종 요청 상태와 서비스별 DB, 포인트 원장, Outbox/Kafka 결과를 대조했다. 최초 9 PASS·2 BLOCKED 보고서 원본 (증거 경로: `./final-execution-report-before-retest.md`)과 케이스별 원본 증거를 보존한 채, 새 fixture의 재시험 증거로 2종만 갱신했다. 이전 v0.5 실행 결과는 이번 판정에 재사용하지 않았다.

## 2. HTTP·DB·Kafka·포인트 대조

- 정상 생성·참가의 요청은 HTTP 202/PENDING에서 최종 CONFIRMED로 전이했고 요청별 `DEPOSIT_CHARGED` -10은 1건이다. 거절 경로는 접수 전 400/403과 접수 후 FAILED를 구분했다.
- 탈퇴 CLEANED는 소유 매치를 CANCELLED로 바꾸고 탈퇴자의 참가·대기를 정리했다. 다른 회원의 확정 이력은 남았고 보증금 +10 반환은 1건; 탈퇴자의 보증금은 반환되지 않았다.
- 경쟁 부하에서는 정원 10에 방장 포함 확정 10명, 신규 9명, 거절·환불 91명이다. `fixture.py verify`에서 100개 요청·참가·Outbox·포인트 이력을 대조했다.
- 알림 장애 중 Match 확정은 진행됐고, 복구 뒤 수신자별 알림 10건 및 Kafka Lag 0을 확인했다. 같은 `match.joined.v1` eventId 재전달 후에도 중복이 없었다.
- 출석 정산 13개 Outbox의 outcome은 ATTENDED 11, NO_SHOW 1, UNDER_MIN_PARTICIPANTS 1이다. 포인트 원장은 차감 13, 반환 12, 출석 보상 2, 노쇼 몰수 1이다. 동일·새 eventId 재전달 뒤 특정 요청의 포인트·카운터·이력은 불변이다.
- TC-POINT-003 추가 재시험에서 차감 전 취소는 요청/참가 CANCELLED, 잔액 50, 0점 취소 원장 1건이다. 별도 5분 만료는 늦은 CHARGED 후 -10/+10 각 1건, 잔액 50, 환불 COMPLETED, 재확정 0건이며 재전달 뒤 불변이다.
- TC-SAGA-003 추가 재시험에서 A/C/D의 Match 결과 Outbox는 기한 전 커밋되고 발행은 기한 뒤까지 지연됐다. 내부 조회로 CLEANED·REJECTED를 확정한 뒤 늦은 Kafka 결과와 재전달이 도착해도 회원·Saga·매치·포인트·알림은 변하지 않았다. B는 Match 결과 NONE에서 TIMED_OUT/ACTIVE가 되고 늦은 원 요청은 DEADLINE_EXCEEDED로 거절됐다.

## 3. 실제 관리자 화면과 모니터링 원본

각 TC의 `dashboard/`에는 **실제 React 관리자 대시보드**의 서비스 개요, Feign·CB, Kafka, JVM·리소스, 도메인·AI 탭을 각 단계별 전체 화면 PNG로 저장했다. 화면은 전용 시험 Prometheus와 관리자 API를 사용했다. AI 서비스는 본 시험 의존성이 아니어서 의도적으로 기동하지 않았고 화면의 DOWN 표시는 결함으로 집계하지 않았다. 차감·환불의 회계 판정은 화면의 누적 Counter가 아니라 DB 원장을 기준으로 했다.

| 케이스 | 실제 화면 단계 | 대표 화면 |
| --- | --- | --- |
| SAGA-001 | 전·후, 10장 | 탈퇴 후 Saga/도메인 (증거 경로: `./TC-SAGA-001/dashboard/after-domain.png`) |
| SAGA-002 | 전·후, 10장 | 거절 후 Saga/도메인 (증거 경로: `./TC-SAGA-002/dashboard/after-domain.png`) |
| SAGA-003 | 기존 장애 실험 20장 + A/C/D·B 재시험 8단계 및 모니터링 복구 45장 | A/C/D 재조회 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/acd-after-recheck-domain.png`), B 타임아웃 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/b-timed-out-domain.png`), Lag 복구 후 Kafka (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/monitoring-restored-kafka.png`) |
| POINT-001 | 전·후, 10장 | 확정 후 Kafka (증거 경로: `./TC-POINT-001/dashboard/after-kafka.png`) |
| POINT-002 | 전·후, 10장 | 거절 후 도메인 (증거 경로: `./TC-POINT-002/dashboard/after-domain.png`) |
| POINT-003 | 기존 전·취소·성별 불일치 15장 + 만료 전·늦은 CHARGED 후·모니터링 복구 15장 | 만료 전 도메인 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/pending-before-timeout-domain.png`), 늦은 CHARGED 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/after-timeout-late-domain.png`), Lag 복구 후 Kafka (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/monitoring-restored-kafka.png`) |
| POINT-004 | 전·진행 중·후, 15장 | 정산 후 도메인 (증거 경로: `./TC-POINT-004/dashboard/after-domain.png`) |
| OBS-001 | 전·장애 중·복구 후, 15장 | Facility 장애 중 Feign·CB (증거 경로: `./TC-OBS-001/dashboard/during-feign.png`) |
| OBS-002 | 전·후, 10장 | 지연 후 Feign·CB (증거 경로: `./TC-OBS-002/dashboard/after-feign.png`) |
| OBS-003 | 전·조회 부하 중·참가 중·후·필터, 26장 | 조회 부하 중 서비스 개요 (증거 경로: `./TC-OBS-003/dashboard/during-list-overview.png`) |
| OBS-004 | 전·장애 중·복구 후, 15장 | Notification 장애 중 Kafka (증거 경로: `./TC-OBS-004/dashboard/during-kafka.png`) |

TC-OBS-003은 k6 조회 부하 시간 **22:56:35~22:57:38 KST**를 Prometheus 원본 시계열 (증거 경로: `./TC-OBS-003/prometheus-range.json`)과 Grafana 패널에 같은 범위로 적용했다. 실제 Grafana 캡처: 서비스 개요 (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-service-overview.png`), 서비스 통신 (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-service-communication.png`), Kafka (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-kafka.png`), JVM (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-jvm-resources.png`), 도메인·AI (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-domain-ai.png`). React의 현재 기간 화면은 부하 중 실시간 캡처이고, Grafana·Prometheus는 부하 시간으로 고정한 과거 범위다. 집계 시간·단위 차이는 동일 수치의 직접 등치로 해석하지 않았다. k6 P95 415.45ms는 측정값이며 사전 합의 성능 기준은 없다.

React의 기간 1시간·user-service 필터 화면 (증거 경로: `./TC-OBS-003/dashboard/filters-user-service-1h.png`)도 실제 UI에서 선택하고 재조회해 저장했다. 선택된 서비스 행 강조, 요청량·P95·CPU/Heap의 해당 서비스 표시를 확인했다.

재시험의 실제 React 캡처는 SAGA-003 45장 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/`)과 POINT-003 15장 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/`)이다. SAGA-003은 결과 발행 전·재조회 직후·늦은 발행 후 및 B의 Consumer 중단·타임아웃·복구 화면을 각 5개 탭에서 저장했다. 메모리 확보를 위해 시험 중 Kafka exporter가 중단돼 일부 실시간 화면의 Lag는 DOWN이었으며, 복구 후 각 케이스의 Kafka 탭을 추가로 캡처했다. Prometheus 원본 (증거 경로: `./retest-blocked-20261103/monitoring-restored-prometheus.json`)은 exporter UP·Lag 합계 0을 확인한다. 포인트·Saga의 정확한 건수와 최종 판정은 DB/원장/Prometheus 원본을 기준으로 했다.

## 4. 결함·위험·잔여 검증

| 등급 | 항목 | 상태 |
| --- | --- | --- |
| 시험 방식 한계 | TC-SAGA-003 D의 409·500·식별값 불일치는 User 내부 조회 전용 프록시로 격리 주입했다. 실제 Match 정리 트랜잭션 경합 자체에서 나온 409는 직접 재현하지 않았다. 실제 Match 연결 실패는 최초 실행에서 확인했다. | 기록 |
| 선택 검증 | TC-POINT-003의 유효하지 않은 Kafka 이벤트 DLT 실험은 선택 항목으로 수행하지 않았다. | 기록 |
| 관측 한계 | AI 서비스는 시험 범위 밖이다. React/Grafana는 지원되는 현재 지표를 표시하지만 포인트 원장의 정확 건수는 DB로만 판정한다. | 기록 |

11개 필수 케이스에서 재현 가능한 신규 결함은 확인되지 않았다. **Issue #15는 이 실행 범위의 P0 검증 조건을 충족해 종료 가능**으로 판단한다. 실제 Issue 상태 변경과 PR 생성·병합은 수행하지 않았다.

## 5. 안전·복구

시험 전 개발 Compose는 미기동이었고, 기존 사용자 데이터와 볼륨을 삭제하지 않았다. 최초 실행의 가용 물리 메모리는 약 1.7 GiB 이상이었다. 보완 재시험에서도 관측한 최저 약 0.7 GiB로 0.3~0.4 GiB 중단선에 닿지 않았다. A/C/D의 Outbox 행 잠금은 해제했고, B의 Match 탈퇴 Consumer·User의 내부 조회 URL·MariaDB `innodb_lock_wait_timeout=50`을 기본값으로 복구했다. 시험용 HTTP 프록시와 Frontend 서버는 종료했다. Facility·Notification·Match·User 등 핵심 컨테이너와 Kafka exporter의 복구 직후 상태를 기록 (증거 경로: `./retest-blocked-20261103/environment-restored-before-stop.json`)했다. 검증 완료 후 전용 테스트 Compose만 중지했으며 컨테이너 17개와 전용 볼륨 2개는 보존했다. 중지 뒤 가용 메모리는 **약 3.61 GiB**, 실행 중인 Docker 컨테이너는 0이다(중지 후 상태 (증거 경로: `./retest-blocked-20261103/environment-after-stop.json`)). 이전 v0.5 원본과 최초 v0.6 보고서·증거는 보존했다.
