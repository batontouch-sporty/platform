# Sporty_v2 API 계약 v1.0

> 출처: 팀 확정 `Sporty_v2 API 명세서 v1.0`, 작성일 2026-10-30, 작성자 이상혁. 이 문서는 구현에 필요한 경로·권한·주요 응답과 변경점을 Markdown으로 옮긴 요약본입니다. 상세 요청 필드와 API별 전체 오류 코드는 원본 PDF 부록 A1~A31, I1~I4를 기준으로 합니다. **계약 확정은 구현·통합 검증 완료를 뜻하지 않습니다.**

## 우선순위와 범위

- 이 문서는 [v0.1 API·Kafka 초안](api-contract-v0.1.md)의 **HTTP API 부분보다 우선**합니다. v0.1의 `identity-service`, 서비스 접두어 없는 외부 `/api/**`, AI 조회 모델용 내부 API 등은 이 계약과 충돌하면 적용하지 않습니다.
- 외부 31개(A1~A31), 내부 Feign 4개(I1~I4), 총 35개입니다. 대기열 A18·A19와 시설 후보 I4는 **P1**입니다. 관리자 화면은 선택 기능이지만 A28~A31 계약은 확정입니다.
- Kafka 이벤트의 토픽·페이로드 및 DB DDL은 이 API 문서의 확정 범위 밖입니다. 기존 v0.1 Kafka 표를 최신 합의로 해석하지 마세요.

## 공통 요청·응답

| 항목 | 계약 |
| --- | --- |
| 외부 라우팅 | React → Gateway `:8000` → `/{service-name}/api/**`; Gateway가 접두어를 제거한 `/api/**`를 해당 서비스로 전달 |
| 내부 호출 | `/internal/**`는 서비스 간 Feign 전용이며 Gateway에서 외부 접근 차단 |
| 인증 | `Authorization: Bearer {accessToken}`; Gateway가 JWT를 검증해 `X-User-Id` 전달. 클라이언트가 보낸 `X-User-Id`는 신뢰하지 않음 |
| 선택 인증 | 토큰이 없으면 비로그인으로 통과, 토큰이 있는데 잘못됐으면 401 |
| 관리자 | JWT 역할 `ADMIN`만 허용; 미인증 401 `UNAUTHORIZED`, 권한 없음 403 `FORBIDDEN` |
| 오류 | 서비스 오류 `{ "code": "...", "message": "..." }`; 입력 오류 400 `INVALID_INPUT`에 첫 번째 항목 오류 메시지. Prometheus 자체 400 응답은 표준 `{status,errorType,error}` 그대로 전달 |
| 시간 | 일시 `2026-11-08T19:00:00`, 시각 `09:00:00` (시설 검색 조건은 `09:00`도 허용), 시간대 접미사 없는 한국 시간 |
| 회원·매치 상태 | 회원 `ACTIVE`, `WITHDRAWING`, `WITHDRAWN`; 매치 `RECRUITING`, `CLOSED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED` |

> 아래 표의 경로는 브라우저가 Gateway에 보내는 **전체 경로**입니다. 서비스 내부에서는 서비스 접두어가 제거됩니다. 공개=로그인 불필요, 선택=토큰이 있으면 사용, 인증=로그인 필수, ADMIN=관리자 전용.

## 회원·인증·프로필 (`user-service`: 8081)

| ID | 메서드 | Gateway 경로 | 권한 | 성공 | 핵심 계약 |
| --- | --- | --- | --- | --- | --- |
| A1 | POST | `/user-service/api/users` | 공개 | 201 | `{email,password,gender,nickname,district,sportTypes}` → 본문 없음. 가입 역할은 USER |
| A2 | GET | `/user-service/api/users/me` | 인증 | 200 | `{email,gender,status,role,nickname,district,imageUrl,preferenceSports}` |
| A3 | DELETE | `/user-service/api/users/me` | 인증 | 202 | `{password}` → `{status:"WITHDRAWING",sagaId}`. 이미 진행 중이면 409 `WITHDRAWAL_IN_PROGRESS` |
| A4 | POST | `/user-service/api/auth/login` | 공개 | 200 | `{email,password}` → `{userId,role,accessToken,refreshToken,tokenType,expiresIn}`; `expiresIn`은 설정값에 따른 초 단위. `Cache-Control: no-store` |
| A5 | POST | `/user-service/api/auth/logout` | 인증 | 204 | Redis refresh token 삭제, 응답 본문 없음 |
| A6 | POST | `/user-service/api/auth/refresh` | 공개 | 200 | `{refreshToken}` → `{accessToken}` |
| A7 | PUT | `/user-service/api/profiles/me` | 인증 | 200 | `{nickname,district,sportTypes}` → `{nickname,district,preferenceSports}` |
| A8 | GET | `/user-service/api/profiles/{profileId}` | 인증 | 200 | 프로필 상세; 비로그인 조회 불가 |

탈퇴는 `ACTIVE → WITHDRAWING → WITHDRAWN` Saga입니다. 진행 중 모임의 방장이면 거절, 5분 타임아웃이면 ACTIVE로 복귀합니다. 결과는 알림으로 전달하며 WITHDRAWING 동안 로그인·참가는 불가합니다.

## 매치·대기열 (`match-service`: 8082)

| ID | 메서드 | Gateway 경로 | 권한 | 성공 | 핵심 계약 |
| --- | --- | --- | --- | --- | --- |
| A9 | POST | `/match-service/api/matches` | 인증 | 201 | 시설 ID 포함 생성 요청 → **매치 ID 숫자 하나**; 시설 검증 후 이름·장소·지역·무료 여부·예약 URL 복사 |
| A10 | GET | `/match-service/api/matches` | 공개 | 200 | 조건 검색 → 배열. `status` 없으면 모집중·마감·진행 중만 반환; 완료·취소는 명시해서 검색 |
| A11 | GET | `/match-service/api/matches/{matchId}` | 선택 | 200 | 매치·시설 복사본·참가자·`isOwner`·`isParticipant`; 비로그인일 때 두 플래그 false |
| A12 | PUT | `/match-service/api/matches/{matchId}` | 인증 | 200 | 방장 수정 → 상세 응답. 시작 후 수정 금지, 정원은 현재 인원 이상, 정원 변경 시 상태 재계산 |
| A13 | DELETE | `/match-service/api/matches/{matchId}` | 인증 | 204 | 방장만 모집중·마감 매치 삭제; 알림 없음 |
| A14 | POST | `/match-service/api/matches/{matchId}/participants` | 인증 | 201 | `{matchParticipantId,matchId,userId,role}`; 회원 상태·성별·정원 검사, 가입 이벤트 발행 |
| A15 | DELETE | `/match-service/api/matches/{matchId}/participants/me` | 인증 | 204 | 참가 취소; 자체 알림 없음, 상태 변경 시 이벤트 발행 |
| A16 | GET | `/match-service/api/matches/me` | 인증 | 200 | 내 매치 배열; Gateway의 회원 ID 사용 |
| A17 | PATCH | `/match-service/api/matches/{matchId}/cancel` | 인증 | 200 | 방장이 CANCELLED로 상태 변경·참가자에게 알림; 참가·대기 기록 보존 |
| A18 | POST | `/match-service/api/matches/{matchId}/waitlist` | 인증 | 201 | P1. CLOSED 매치에서 대기 등록, 방장 불가·성별 검사 |
| A19 | DELETE | `/match-service/api/matches/{matchId}/waitlist/me` | 인증 | 204 | P1. 내 대기 취소 |

검색 조건: `serviceId`, `titleKeyword`, `descriptionKeyword`, `startAt`, `endAt`, `maxParticipant`, `skillLevel`, `sportType`, `genderGroup`, `region`(자치구명), `status`, `isFree`. `reservationDeadlineAt`은 매치 목록·상세에서 제외하고 시설 상세에만 둡니다. 삭제(A13)와 취소(A17)는 서로 다른 동작입니다. 매치 DB는 다른 서비스 테이블에 외래 키를 걸지 않고 시설 ID와 스냅샷을 보유합니다.

## 시설 (`facility-service`: 8083)

| ID | 메서드 | Gateway 경로 | 권한 | 성공 | 핵심 계약 |
| --- | --- | --- | --- | --- | --- |
| A20 | GET | `/facility-service/api/services` | 공개 | 200 | `region,serviceName,serviceType,status,startTime,endTime` 조건 → 배열. 시작 시각이 종료보다 늦으면 400 `INVALID_SEARCH_CONDITION` |
| A21 | GET | `/facility-service/api/services/{serviceId}` | 공개 | 200 | `serviceId` 경로 값은 DB PK(Long); 상세 응답의 `id`는 DB PK, `serviceId` 문자열은 서울시 원본 SVCID. `reservationDeadlineAt` 포함 |

서울시 공공데이터는 매일 03:00 동기화하며, 외부 예약은 `url` 링크로 안내합니다.

## AI (`ai-service`: 8084)

| ID | 메서드 | Gateway 경로 | 권한 | 성공 | 핵심 계약 |
| --- | --- | --- | --- | --- | --- |
| A22 | POST | `/ai-service/api/ai/matches/search` | 공개 | 200 | `{prompt}` → `{conditions,criteria,matches,fallback}`. LLM 실패 시 조건 검색으로 대체하고 `fallback:true` |
| A23 | POST | `/ai-service/api/ai/matches` | 인증 | 200 | `{prompt}` → `{initialValues,facilityCandidates}`. 초안은 저장하지 않음; 시설 후보는 P1, P0에서는 빈 배열. LLM 실패 시 503 `AI_UNAVAILABLE` |
| A24 | GET | `/ai-service/api/ai/matches/recommendations` | 인증 | 200 | `{matches,fallback}` (최대 3개); LLM 실패 시 최신순 후보 반환·`fallback:true` |

AI의 회원 정보는 I1, 시설 후보는 I4(P1), 매치 후보는 `match-service`의 공개 `GET /api/matches`를 Feign으로 조회합니다. 별도의 AI 조회 모델 API는 없습니다.

## 알림 (`notification-service`: 8085)

| ID | 메서드 | Gateway 경로 | 권한 | 성공 | 핵심 계약 |
| --- | --- | --- | --- | --- | --- |
| A25 | GET | `/notification-service/api/notifications/me` | 인증 | 200 | 최신순 50건 배열, 페이징 없음; 항목 `{id,type,message,matchId,read,createdAt}` |
| A26 | PATCH | `/notification-service/api/notifications/{id}/read` | 인증 | 200 | `{id,read:true}`. 다른 회원 알림은 403 |
| A27 | GET | `/notification-service/api/notifications/me/unread-count` | 인증 | 200 | `{unreadCount}` |

알림 타입: `JOINED`, `STATUS_CHANGED`, `STARTING_SOON`(P1), `WAITLIST_PROMOTED`(P1), `WITHDRAWAL_REJECTED`. 같은 `eventId`는 한 번만 저장하고 실패 시 3회 재시도 후 DLT로 보냅니다.

## 관리자 화면 계약

| ID | 메서드 | Gateway 경로 | 성공 | 반환 데이터 |
| --- | --- | --- | --- | --- |
| A28 | GET | `/user-service/api/admin/stats` | 200 | `withdrawalSaga.{requested,succeeded,rejected,timedOut,inProgress}`, `users.{active,withdrawing,withdrawn}` |
| A29 | GET | `/match-service/api/admin/stats` | 200 | `matches.{total,byStatus.{RECRUITING,CLOSED,IN_PROGRESS,COMPLETED,CANCELLED}}`, `participants.total` |
| A30 | GET | `/prometheus/api/v1/query?query=...&time=...` | 200 | Prometheus 표준 즉시 조회 `status`, `data.{resultType:"vector",result:[{metric,value}]}`; `time` 생략 가능 |
| A31 | GET | `/prometheus/api/v1/query_range?query=...&start=...&end=...&step=...` | 200 | Prometheus 표준 범위 조회 `status`, `data.{resultType:"matrix",result:[{metric,values}]}` |

네 경로 모두 JWT `ADMIN` 전용입니다. A28·A29는 기간 필터 없는 누적 통계입니다. A30·A31에서 Gateway는 Prometheus의 **두 조회 경로만** 열고 다른 경로는 차단하며, PromQL 오류의 Prometheus 표준 400 본문을 그대로 전달합니다. Grafana 운영 대시보드와 관리자 React 화면의 구현 상태는 별도로 확인합니다.

## 내부 Feign API (Gateway 외부 차단)

| ID | 제공 서비스 | 메서드·내부 경로 | 성공 | 호출 목적 |
| --- | --- | --- | --- | --- |
| I1 | user | `GET /internal/users/{id}` | 200 `{id,gender,status,district,sportTypes}` | match 참가 검증, AI 개인 추천 |
| I2 | user | `GET /internal/users?ids=1,2,3` | 200 `[{id,profileId,nickname,imageUrl}]` | match 상세 참가자 표시. 없는 ID는 결과에서 제외 |
| I3 | facility | `GET /internal/facilities/{id}` | 200 `{id,name,startTime,endTime,active,url,locationName,region,isFree}` | match 생성·수정 검증·시설 정보 복사. 비활성 시설도 200 `active:false` |
| I4 | facility | `GET /internal/facilities?district=SONGPA&sport=BASKETBALL` | 200 시설 후보 배열 | P1, 활성 시설 최대 5건; AI 초안 시설 후보. `district`는 자치구 코드 |

내부 API 실패 정책: I1 실패 시 참가 거절 503, I2 실패 시 닉네임 `알 수 없음`, I3 실패 시 생성·수정 거절, I4 실패 시 후보 없이 초안 반환. 내부 호출의 접근 제어와 서비스 인증 방식은 인프라 구현에서 검증해야 합니다.

## v0.1에서 바뀐 구현 포인트

1. 프런트 API 호출을 서비스 접두어가 있는 Gateway 경로로 바꾸고, 401 refresh 재시도 및 `{code,message}` 오류 처리를 점검합니다.
2. 로그인·내 정보에 `role`, `status`를 반영하고 탈퇴 응답을 즉시 204에서 202 Saga 접수로 변경합니다.
3. 매치 상태 5종, 기본 목록 필터, 시설 복사본, 취소와 삭제 분리, 정원·성별·회원 상태 검사를 반영합니다.
4. AI 검색·추천의 `fallback` 객체 응답과 초안의 503을 화면에 반영합니다.
5. 관리자 통계(A28·A29)와 Prometheus 조회(A30·A31)는 Gateway ADMIN 검사를 통과한 경우에만 노출합니다.

원본 PDF에는 각 API의 전체 JSON 예시와 세부 오류 코드가 있습니다. 이 요약에 없는 항목은 원본 부록을 확인하고 변경 시 팀 결정 로그와 이 문서를 함께 갱신합니다.
