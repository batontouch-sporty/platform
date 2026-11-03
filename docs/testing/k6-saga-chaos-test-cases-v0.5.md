# Sporty v2 R10 v0.5 통합 테스트 명세

증거 파일은 Platform 저장소 밖의 로컬 보관소에 있다. 아래 `../e2e-evidence/20261103/` 경로는 Platform 저장소 루트 기준이며 GitHub에서 열 수 없다.

작성 기준: 2026-11-03. 대상은 기존 R10 핵심 11종이다. HTTP 202는 접수이며 성공 판정은 요청 상태, DB, 이벤트, 포인트 정산의 최종 상태로 한다. 이 문서는 기존 실행을 재기록한 명세이며 새 E2E 실행을 뜻하지 않는다.

| ID | 시나리오 | 필수 판정 조건 | 최종 결과 |
| --- | --- | --- | --- |
| TC-POINT-001 | 매치 생성·참가 보증금 | 각각 202 접수 후 CONFIRMED, 10점 단일 차감, DB·Kafka 일치 | PASS |
| TC-POINT-002 | 잔액 부족·참가 제한 | 부족 요청 FAILED/INSUFFICIENT_POINTS, 차감 없음; 정지·탈퇴 상태 거절, 정상 복귀 후 참가 | PASS |
| TC-POINT-003 | 참가 취소·중복 이벤트 | 반환 완료 및 단일 적립, 이벤트 재전달에도 중복 반환 없음 | PASS |
| TC-POINT-004 | 출석·노쇼 정산 | 미달·출석·노쇼별 반환 또는 보상, 정산 멱등성 | PASS |
| TC-SAGA-001 | 정상 회원 탈퇴 | 202 접수, 매치·참가·대기 정리, 타인 이력과 반환 보존, CLEANED/WITHDRAWN | PASS |
| TC-SAGA-002 | 탈퇴 거절 | 진행 중 매치 방장 요청 REJECTED/ACTIVE, 매치·참가 보존, 단일 알림 | PASS |
| TC-SAGA-003 | 타임아웃 후 늦은 CLEANED | TIMED_OUT/ACTIVE 보호와 함께 서비스 간 매치·회원 정합성 유지 | **FAIL** |
| TC-OBS-001 | Facility 중단·복구 | 중단 중 기존 매치 조회와 시설 스냅샷 유지, `up` 0→1, 복구 | PASS |
| TC-OBS-002 | Facility 지연·Trace | 지연 관측, Feign 지표·Zipkin span, 복구 후 정상 응답 | PASS |
| TC-OBS-003 | k6 부하·모니터링 | 100 VU 조회 60초, 참가 100건 최종 정산, Grafana·React 검증 | PASS |
| TC-OBS-004 | Notification Consumer Lag | Lag 0→5→0, 최종 참가·알림 단일성, API·DB 일치 | PASS |

**총계: PASS 10 / FAIL 1 / BLOCKED 0 / NOT RUN 0.** TC-SAGA-003은 회원 ACTIVE·Saga TIMED_OUT인데 Match와 방장 참가가 CANCELLED인 실제 정합성 결함 때문에 FAIL이다.

원본 실행과 보완 검증의 상세 조건 및 증거는 초기 실행 보고서 (`../e2e-evidence/20261103/r10-v05-final/execution-report.md`)와 BLOCKED 4종 보완 보고서 (`../e2e-evidence/20261103/r10-v05-blocked-followup/final-monitoring-report.md`)에 있다. 테스트 당시 Backend는 `c5c90c2`/PR #142 head `e33ca69`, Frontend 관리자 화면은 PR #42 병합 `c9e81b5`였다. 최신 main의 런타임 E2E를 재실행한 결과가 아니다.
