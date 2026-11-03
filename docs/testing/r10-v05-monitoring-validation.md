# Sporty v2 R10 v0.5 모니터링 검증 보고서

증거 파일은 Platform 저장소 밖의 로컬 보관소에 있다. 아래 `../e2e-evidence/20261103/` 경로는 Platform 저장소 루트 기준이며 GitHub에서 열 수 없다.

작성일: 2026-11-03 KST. 화면과 데이터는 기존 실행·보완 검증에서 확보한 것만 기록한다. 최신 main에서 새 브라우저 캡처나 E2E 실행은 하지 않았다. 원본: 보완 모니터링 보고서 (`../e2e-evidence/20261103/r10-v05-blocked-followup/final-monitoring-report.md`).

| 시나리오 | 관측 결과 | 증거 유형·위치 |
| --- | --- | --- |
| 정상 Baseline | 핵심 서비스 healthy, Gateway 200, 관리자 지표 조회 | 최종 상태 (`../e2e-evidence/20261103/r10-v05-final/monitoring/final-container-status.json`), Prometheus UP (`../e2e-evidence/20261103/r10-v05-final/monitoring/final-prometheus-up.json`) |
| Facility DOWN | 기존 A11 조회 200·스냅샷 유지, `up` 0 | A11 API (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/a11-during.json`), Prometheus (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/prometheus-down.json`) |
| Facility 지연 | 응답 지연, Feign 지표·Gateway/Match/Facility span | Zipkin Trace (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-002/zipkin-delay-trace.json`), Feign 데이터 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-002/sporty_feign_http_requests_seconds_max.json`) |
| k6 부하 | 100 VU·60초, 실패 0, 참가 100건 최종 정산 | 정산 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-003/verification.json`), Prometheus 범위 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-003/prometheus-derived-summary.json`), Grafana 서비스 개요 PNG (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-service-overview.png`) |
| Kafka Consumer Lag | Notification Lag 0→5→0, 복구 후 알림 중복 없음 | 전 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/baseline-lag.json`)·중 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/during-lag.json`)·후 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/after-lag.json`) Prometheus, Grafana Kafka PNG (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-kafka.png`) |
| Saga 성공·거절·타임아웃 | A28와 Prometheus 카운터 및 React 도메인 탭 교차 확인 | React 브라우저 API·탭 (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/react-browser-check.json`), Grafana 도메인 PNG (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-domain-ai.png`) |
| late CLEANED | 지연 발행 후 처리, late 카운터 1; TC-SAGA-003은 정합성 결함으로 FAIL | late 지표 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-SAGA-003/late-metric.json`), 최종 상태 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-SAGA-003/final.json`) |
| 서비스 복구 | Facility `up` 1, Gateway 200, 전용 스택 중지 및 볼륨 보존 | Facility 복구 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/prometheus-recovered.json`), 종료 환경 (`../e2e-evidence/20261103/r10-v05-blocked-followup/environment/final-state.json`) |

Grafana 실제 브라우저 PNG는 서비스 개요 (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-service-overview.png`), 통신 (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-service-communication.png`), Kafka (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-kafka.png`), 도메인 (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-domain-ai.png`), JVM (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/grafana-sporty-jvm-resources.png`) 5개다. React는 실제 브라우저에서 탭·필터와 Gateway Prometheus API 응답을 검증했으나 PNG는 없다. 각 TC별 전용 화면 11장은 확보되지 않았다. Facility 장애·지연 등은 위 API·Prometheus·Trace 증거로만 주장한다.

Grafana PromQL의 `sporty_withdrawal_saga_results_total`, `sporty_withdrawal_saga_late_results_total`, `sporty_feign_http_requests_seconds_*`, `kafka_consumergroup_lag`는 최신 Backend 지표 정의 및 기존 대시보드에서 유지된다. Frontend 관리자 API의 A28/A29와 Prometheus instant/range 경로도 최신 main에서 유지된다. 이는 정적 계약과 단위 테스트 검증이며 최신 main의 실제 화면 재검증은 아니다.
