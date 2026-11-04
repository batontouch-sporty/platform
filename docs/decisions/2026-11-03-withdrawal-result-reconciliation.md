# 2026-11-03 탈퇴 Saga 마감 시 결과 재조회

**상태:** [backend PR #144](https://github.com/batontouch-sporty/backend/pull/144), [config-repo PR #18](https://github.com/batontouch-sporty/config-repo/pull/18) 병합. 최신 재시험 판정은 [R10 v0.6 최종 실행 보고서](../testing/r10-v06-execution-report.md)를 따른다.

## 배경과 결정

기존 TC-SAGA-003에서 Match가 마감 전에 정리·Outbox 저장을 마쳤지만 결과 이벤트 전달이 늦어 User가 `TIMED_OUT/ACTIVE`로 복구됐다. 매치는 이미 취소되어 두 서비스 상태가 어긋났다. User는 **마감+유예(기본 5분+30초)** 후 회원을 복구하기 전에 Match의 커밋된 결과를 내부 API로 재조회한다.

| Match 조회 | 회원 / withdrawal_saga | 후속 처리 |
| --- | --- | --- |
| CLEANED | WITHDRAWN / CLEANED | 기존 완료·Refresh Token 무효화; 이후 같은 Kafka CLEANED는 정상 중복, late 경보 미발생 |
| REJECTED | ACTIVE / REJECTED | 기존 거절·보상 |
| NONE | ACTIVE / TIMED_OUT | Match는 이후 같은 요청 정리를 DEADLINE_EXCEEDED로 거절 |
| 조회 실패·응답 불일치 | WITHDRAWING / PROCESSING 유지 | WARN·`sporty_withdrawal_saga_result_check_failures_total` 기록, 다음 주기 재조회 |

## 내부 API·데이터 경계

- user-service → match-service: `GET /internal/withdrawals/{sagaId}?userId={userId}&requestEventId={requestEventId}&deadlineAt={ISO-8601 offset}`.
- 200 응답: `{sagaId,requestEventId,userId,result}` (`result`는 CLEANED·REJECTED·NONE). User는 모든 식별 값을 자기 Saga·claim_token과 비교한 뒤에만 반영한다.
- Match는 탈퇴 정리와 **같은 회원 잠금**을 획득한 뒤 READ_COMMITTED 트랜잭션에서 기존 `match_db.outbox_event` 결과 행을 조회한다. 마감 전 결과 없음 409, 잘못된 deadlineAt 400, 잠금 대기 초과·DB 오류 5xx이며 User는 모두 처리 중 상태를 보존한다.
- Feign 클라이언트 `userMatchWithdrawalClient`: 연결 1000ms, 읽기 5000ms 기본값. 설정은 config-repo의 `user-service.yml`에 있으며 로컬에서 최신 설정 적용 시 config-service를 재시작한다.
- **R10 DDL 변경 없음. Kafka 토픽·이벤트 본문 변경 없음.** 기존 `user_db.withdrawal_saga`와 `match_db.outbox_event`를 사용하고, 조회 실패 Counter만 추가한다. 내부 경로는 Gateway에서 외부 차단한다.

## 검증과 남은 제약

사용자 제공 [R10 v0.6 최종 실행 보고서](../testing/r10-v06-execution-report.md)에서 TC-SAGA-003의 CLEANED·REJECTED 결과 전달 지연, NONE 타임아웃, 조회 실패 뒤 복구 및 늦은 Kafka 중복 무영향을 PASS로 기록했습니다. 이 결과를 통합 테스트 케이스의 ST-SAGA-03~05에 반영했습니다.

409·500·식별 불일치는 User 조회 전용 프록시로 격리 주입했으며 실제 Match 정리 트랜잭션 경합에서 발생하는 409 자체는 직접 재현하지 않았습니다. 보고서의 원 PNG·JSON·verdict 파일은 이번 첨부에 포함되지 않았습니다. 서버 간 시계 차이와 Match 장기 장애로 WITHDRAWING에 머물 수 있는 제약은 유지합니다.
