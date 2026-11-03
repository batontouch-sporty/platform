# Sporty v2 R10 v0.6 재시험 명세 · 핵심 11종

증거 파일은 Platform 저장소 밖의 로컬 보관소에 있다. 아래 `../e2e-evidence/20261103/` 경로는 Platform 저장소 루트 기준이며 GitHub에서 열 수 없다.

작성 기준: 2026-11-03, [backend PR #144](https://github.com/batontouch-sporty/backend/pull/144)·[config-repo PR #18](https://github.com/batontouch-sporty/config-repo/pull/18) 병합 후 **재시험 설계**. HTTP 202는 접수이며 최종 판정은 DB·이벤트·포인트 상태로 한다. v0.5 보고의 PASS 10/FAIL 1은 과거 결과이며 이 문서의 새 시험은 아직 실행하지 않았다.

| ID | 시나리오 | 필수 판정 조건 | v0.5 과거 / v0.6 신규 |
| --- | --- | --- | --- |
| TC-POINT-001 | 매치 생성·참가 보증금 | 각각 202 접수 후 CONFIRMED, 10점 단일 차감, DB·Kafka 일치 | PASS / Not Run |
| TC-POINT-002 | 잔액 부족·참가 제한 | 부족 요청 FAILED/INSUFFICIENT_POINTS, 차감 없음; 정지·탈퇴 상태 거절, 정상 복귀 후 참가 | PASS / Not Run |
| TC-POINT-003 | 참가 취소·중복 이벤트 | 반환 완료 및 단일 적립, 이벤트 재전달에도 중복 반환 없음 | PASS / Not Run |
| TC-POINT-004 | 출석·노쇼 정산 | 미달·출석·노쇼별 반환 또는 보상, 정산 멱등성 | PASS / Not Run |
| TC-SAGA-001 | 정상 회원 탈퇴 | 202 접수, 매치·참가·대기 정리, 타인 이력과 반환 보존, CLEANED/WITHDRAWN | PASS / Not Run |
| TC-SAGA-002 | 탈퇴 거절 | 진행 중 매치 방장 요청 REJECTED/ACTIVE, 매치·참가 보존, 단일 알림 | PASS / Not Run |
| TC-SAGA-003 | 정리 완료·결과 전달 지연 | 마감 전 Match 정리·Outbox 커밋, 결과 이벤트만 지연 → 재조회 CLEANED로 WITHDRAWN/CLEANED; 이후 이벤트는 정상 중복(late 경보 0). 다른 분기는 아래 표 | **FAIL / Not Run** |
| TC-OBS-001 | Facility 중단·복구 | 중단 중 기존 매치 조회와 시설 스냅샷 유지, `up` 0→1, 복구 | PASS / Not Run |
| TC-OBS-002 | Facility 지연·Trace | 지연 관측, Feign 지표·Zipkin span, 복구 후 정상 응답 | PASS / Not Run |
| TC-OBS-003 | k6 부하·모니터링 | 100 VU 조회 60초, 참가 100건 최종 정산, Grafana·React 검증 | PASS / Not Run |
| TC-OBS-004 | Notification Consumer Lag | Lag 0→5→0, 최종 참가·알림 단일성, API·DB 일치 | PASS / Not Run |

**과거 v0.5: PASS 10 / FAIL 1. 현재 v0.6: 11종 모두 Not Run.** PR #144 병합만으로 과거 FAIL을 PASS로 변경하지 않는다.

### TC-SAGA-003 분기별 재시험

| 분기 | 재현 조건 | 기대값 |
| --- | --- | --- |
| A. 정리 완료·전달 지연 | 마감 전에 Match 정리·결과 Outbox 커밋, Kafka 발행 또는 User 소비만 마감+유예 이후로 지연 | 내부 조회 CLEANED, 회원 WITHDRAWN·Saga CLEANED. 이후 동일 CLEANED 이벤트는 정상 중복이며 late 카운터·경보 미증가. Match·포인트 정책 일치 |
| B. 미처리 | Match가 마감 전에 요청을 처리하지 못함, 조회 NONE | ACTIVE/TIMED_OUT. 뒤늦은 원 요청은 DEADLINE_EXCEEDED, 매치·참가·포인트 무변경 |
| C. 거절 | 진행 중 매치 방장, Match REJECTED Outbox 커밋·결과 전달 지연 | ACTIVE/REJECTED, 매치·포인트 무변경 |
| D. 조회 실패 | 409·5xx·연결 오류·식별 불일치 등 | WITHDRAWING/PROCESSING 유지, 조회 실패 Counter·WARN, 복구 후 다음 주기 재확인 |

**실행 준비:** backend/config-repo 최신 main SHA, R10 DB, 탈퇴 Saga timeout/grace, config-service 재시작과 `userMatchWithdrawalClient` 설정 적용을 확인한다. A에서 Match 전체를 중단하면 정리 자체가 늦어져 다른 분기가 되므로 **결과 이벤트만 지연**시킨다. 별도 fixture·sagaId·requestEventId·userId로 분기마다 HTTP, user_db.withdrawal_saga, match_db.outbox_event, Kafka, 포인트, Counter 증거를 기록한다. 현재 환경에서 실제 실행하지 못한 분기는 Not Run/Blocked로 남긴다.

원본 실행과 보완 검증의 상세 조건 및 증거는 초기 실행 보고서 (`../e2e-evidence/20261103/r10-v05-final/execution-report.md`)와 BLOCKED 4종 보완 보고서 (`../e2e-evidence/20261103/r10-v05-blocked-followup/final-monitoring-report.md`)에 있다. 테스트 당시 Backend는 `c5c90c2`/PR #142 head `e33ca69`, Frontend 관리자 화면은 PR #42 병합 `c9e81b5`였다. 최신 main의 런타임 E2E를 재실행한 결과가 아니다. v0.6 재시험 결과와 증거는 별도 기록하며 과거 파일을 덮어쓰지 않는다.
