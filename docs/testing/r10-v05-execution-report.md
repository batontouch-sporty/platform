# Sporty v2 R10 v0.5 최종 실행 보고서

증거 파일은 Platform 저장소 밖의 로컬 보관소에 있다. 아래 `../e2e-evidence/20261103/` 경로는 Platform 저장소 루트 기준이며 GitHub에서 열 수 없다.

작성일: 2026-11-03 KST. 범위는 기존 11종 결과와 보완 증거의 정합성 검토, 최신 main 동기화 후 최소 회귀 검증이다. 기존 원본 실행 보고서 (`../e2e-evidence/20261103/r10-v05-final/execution-report.md`)와 보완 검증 보고서 (`../e2e-evidence/20261103/r10-v05-blocked-followup/final-monitoring-report.md`)는 수정하지 않았다.

## 환경과 코드 기준

| 구분 | 기존 E2E 실행 기준 | 이번 최신 main 기준 |
| --- | --- | --- |
| Backend | 초기 `c5c90c2f4f81774677e00572a8b65d3b6dbba2cb`; 보완 런타임 PR #142 head `e33ca694f7da19ab1ab3dd6b33f1946b2cbb00ef` | `0fc66c35cab9fda0e2dbe0663b9ee5edb48756a3` |
| Frontend | 관리자 브라우저 PR #42 병합 `c9e81b58ac8abc6971a7140a1c135c54592ba5bd` | `fbdd38df7dcb0aa817c5b0a6efbdbaa2f33e7c49` |
| Config Repo | 기존 실행 시 SHA 미확인 | `8643203184e901c10d4bfae099ec7e1365d61413` |
| Platform | 기존 E2E 실행 시 SHA 미확인 | 이 저장소의 현재 `main`/`origin/main` `42e1d0a775ed7bbb12970e2e5f80ec0d3c88b5c3`; 기존 E2E 런타임 재검증 없음 |

기존 E2E는 격리 Compose `sporty-k6-v05`에서 실행됐다. 최종 기존 증거는 테스트·개발 컨테이너 0, DB·Alertmanager 볼륨 보존, Gateway 복구 시 HTTP 200을 기록한다. 이번 확인 시 `docker ps`는 비어 있어 Gateway Smoke와 새 런타임 통합 확인은 실행하지 않았다.

## 11종 최종 판정

| 분류 | 테스트 | 판정 | 실제 확인 |
| --- | --- | --- | --- |
| 포인트 | TC-POINT-001 | PASS | 생성·참가 202 후 확정, 보증금 단일 차감 |
| 포인트 | TC-POINT-002 | PASS | 잔액 부족·상태 제한 거절, 정상 복귀 |
| 포인트 | TC-POINT-003 | PASS | 참가 취소 반환, 중복 이벤트에도 중복 적립 없음 |
| 포인트 | TC-POINT-004 | PASS | 출석·노쇼 정산과 멱등성 |
| 탈퇴 | TC-SAGA-001 | PASS | 정상 정리, WITHDRAWN/CLEANED, 타인 이력·반환 보존 |
| 탈퇴 | TC-SAGA-002 | PASS | 진행 중 매치 방장 탈퇴 거절, ACTIVE 유지 |
| 탈퇴 | TC-SAGA-003 | **FAIL** | 늦은 CLEANED 후 회원·매치 간 정합성 간극 |
| 장애·관측 | TC-OBS-001 | PASS | Facility DOWN 중 기존 매치 조회, 스냅샷, `up` 0→1 |
| 장애·관측 | TC-OBS-002 | PASS | Facility 지연과 Feign·Zipkin Trace, 복구 |
| 장애·관측 | TC-OBS-003 | PASS | k6 100 VU, 정산, Prometheus·Grafana·React 확인 |
| 장애·관측 | TC-OBS-004 | PASS | Notification Lag 0→5→0, 알림 중복 없음 |

**PASS 10 / FAIL 1 / BLOCKED 0 / NOT RUN 0.** 원본의 BLOCKED 4종은 보완 검증 결과를 적용했다. 기존 PASS 7종은 재실행하지 않았다.

## 부하와 모니터링

TC-OBS-003 원본: 조회 100 VU·60초, 두 조회 실행의 요청 수 5,840/5,622와 HTTP 실패 0. 참가 요청 100건 접수, 신규 확정 9건, 정원 거절·반환 완료 91건, 방장 포함 DB 확정 10/10, 데이터·포인트 중복 없음. 최종 정산 JSON (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-003/verification.json`)과 k6 결과 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-003/join-results.json`)를 대조했다. 202 접수 수는 최종 확정 수가 아니다.

같은 부하 시각의 Prometheus 범위 데이터와 실제 Grafana 5개 대시보드 패널을 확인한 기존 보완 증거 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-003/prometheus-derived-summary.json`)가 있다. React 관리자 탭·시간·서비스 필터와 A28·A30·A31 호출은 브라우저 검증 JSON (`../e2e-evidence/20261103/r10-v05-blocked-followup/dashboard/react-browser-check.json`)에 있다. Kafka Notification Lag는 전 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/baseline-lag.json`)·중 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/during-lag.json`)·후 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-004/after-lag.json`) 증거가 0→5→0을 뒷받침한다.

Facility 장애는 기존 A11 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/a11-during.json`)과 DOWN (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/prometheus-down.json`)·복구 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-OBS-001/prometheus-recovered.json`)로 확인했다. 지연은 Trace (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-002/zipkin-delay-trace.json`)와 Feign 지표 (`../e2e-evidence/20261103/r10-v05-final/TC-OBS-002/sporty_feign_http_requests_seconds_max.json`)에 있다.

## TC-SAGA-003 결함

격리 fixture에서 Match 정리 후 공유 Outbox 발행만 지연했다. 실제 CLEANED가 기한 후 전달됐고 중복 처리 및 재탈퇴 방지는 동작했다. 그러나 최종 DB 상태 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-SAGA-003/final.json`)는 User `ACTIVE`, withdrawal_saga `TIMED_OUT`, Match `CANCELLED`, 방장 참가 `CANCELLED`이다. late 지표 (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-SAGA-003/late-metric.json`)와 처리 eventId (`../e2e-evidence/20261103/r10-v05-blocked-followup/TC-SAGA-003/processed-event.txt`)가 전달을 뒷받침한다. 재현 스크립트의 `passed: true`는 재현 조건 충족이며 TC의 합격 판정이 아니다.

영향은 탈퇴가 취소된 회원의 매치·참가 상태가 되돌아오지 않는 서비스 간 데이터 불일치다. Backend 후속 조치에서 타임아웃과 Match 정리 커밋·Outbox 발행 사이의 경쟁 상태, 보상 또는 운영자 복구 절차를 설계·검증해야 한다. 이번 작업은 Saga 코드를 변경하지 않았다. 위험도는 **Critical**로 분류한다.

## 이번 최소 회귀 및 영향 분석

| 항목 | 결과 | 판정 |
| --- | --- | --- |
| Backend PR #142, AI Mock, K8s, Config 암호화 | 최신 main에 병합 확인. k6 도구의 202·Polling·최종 정산 로직 유지 | 호환 변경 |
| Backend Saga·포인트 이벤트·메트릭 | 기존 실행 기준 이후 Saga·포인트 코드 변경 없음. 이벤트·PromQL 이름 정적 대조 | 변경 없음 |
| Frontend PR #42·#46 | 병합 확인. #46은 매치·포인트 UI 8개 파일; 관리자 및 공통 파일 변경 없음 | 호환 변경 |
| A28/A29/A30/A31 | 관리자 API 경로 및 Prometheus query/query_range 유지 | 변경 없음 |
| Config Repo #15·#16 | AI Mock, RabbitMQ, prod 암호화 정책 추가. local/dev의 `RABBITMQ_PASSWORD` 환경변수 필요; Config Server 키스토어 변수는 local/dev 기본 기동에 불필요 | 추가 검증 필요 |
| 기존 k6 미커밋 5개 | 최신 main과 동일 파일 모두 내용 차이. 원본 유지, 병합·덮어쓰기 없음 | 충돌 가능성 |

`python -m unittest discover -s monitoring/k6 -p test_fixture.py -v`: 최신 Backend main에서 9/9 PASS. `CI=true npm test -- --watch=false --runInBand --runTestsByPath ...`: 최신 Frontend main 관리자 관련 8 suite, 121/121 PASS. React `act(...)` 경고는 출력됐으나 실패는 없다. 전체 Backend 빌드·전체 Frontend 테스트·100 VU 및 11종 E2E 재실행은 범위 밖이다. 새 Config 환경에서의 실제 기동과 최신 main 조합의 런타임 계약은 미검증이다.

### 기존 k6 변경 분류

| 분류 | 확인 내용 |
| --- | --- |
| main에 반영됨 | 202 접수 후 요청 Polling, CONFIRMED·FAILED·CANCELLED 최종 구분, 반환·잔액 검증의 핵심 방향은 PR #142에 포함 |
| 개인 작업으로 보존 | 미커밋 `README.md`, `fixture.py`, `join.js`, `run.ps1`, `stack.ps1` 모두 최신 main과 내용이 다름. 소규모 VU 옵션, 격리 Compose override, 추가 검증 조건 등은 해당 작업 트리에만 있음 |
| 충돌 가능 | 위 5개 파일 모두 PR #142가 변경한 경로와 겹침. 특히 fixture·join·run의 실행 계약이 다르므로 자동 병합 전 수동 판단 필요 |
| 삭제하지 않고 보존 | 기존 작업 브랜치의 구 실행 설명과 전용 스택 설정. 이번 문서 작업에 필요하지 않아도 사용자 원본으로 유지 |

PR #142와 PR #42는 이미 main에 있으므로 재병합하지 않았다. 사용자 미커밋 파일은 수정하지 않았다.

## 복구와 최종 판단

기존 보완 검증은 Match Outbox 기본 설정 복원, Facility healthy, 반환 완료, Gateway HTTP 200 후 전용 스택 중지를 기록했다. 현재 컨테이너는 실행 중이지 않으며 기존 볼륨과 증거는 보존됐다. 최신 main 동기화와 지정 회귀 검증은 완료했으나, 최신 main에서 11종 E2E 합격을 주장할 수 없다. TC-SAGA-003이 FAIL이므로 R10 v0.5 전체 PASS 또는 결함 종결 판정은 불가하다.
