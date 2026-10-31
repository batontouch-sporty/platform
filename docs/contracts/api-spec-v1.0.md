# Sporty_v2 API 계약 v1.0

> 출처: 팀 확정 `Sporty_v2 API 명세서 v1.0`, 작성일 2026-10-30, 작성자 이상혁. 이 문서는 경로·권한·주요 응답 요약에 PDF 부록 A1~A31, I1~I4의 요청·응답·오류 상세를 덧붙인 Markdown 계약입니다. **계약 확정은 구현·통합 검증 완료를 뜻하지 않습니다.**

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

요약과 아래 상세에서 다루지 않은 예시 값·전체 JSON 배열은 원본 PDF 부록을 확인합니다. 계약을 바꿀 때는 팀 결정 로그와 이 문서를 함께 갱신합니다.

## 개발자용 상세: 외부 API (A1~A31)

이 절은 팀 확정 PDF v1.0 부록의 요청 필드, 응답 형식, 오류 코드를 옮긴 것입니다. `(초안)`은 원본 PDF가 구현 중 조정 가능하다고 표시한 코드입니다. 예시 숫자·날짜·문구는 고정값이 아닙니다. 공통 `UNAUTHORIZED`는 인증 필수/선택/ADMIN 경로에서 잘못된 토큰에 적용되며, 선택 인증 A11은 **토큰이 없으면 통과**합니다.

### A1~A8 회원·인증·프로필

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A1 회원가입 | `POST /user-service/api/users`; `{email,password,gender,nickname,district,sportTypes}`. 비밀번호 8~20자, 이메일·닉네임 50자 이하. `gender`는 `MALE/FEMALE`, `district`는 서울 자치구 코드, 선호 종목 미선택 시 `[]` | `201`, 본문 없음. 프로필·선호 종목 함께 생성, 역할 `USER` 고정(요청에서 `role` 받지 않음) | `400 INVALID_INPUT`, `409 DUPLICATE_EMAIL`, `409 DUPLICATE_NICKNAME` |
| A2 내 정보 | `GET /user-service/api/users/me`; 인증 | `200` `{email,gender,status,role,nickname,district,imageUrl,preferenceSports}` | `401 UNAUTHORIZED`, `404 USER_NOT_FOUND`, `404 PROFILE_NOT_FOUND` |
| A3 탈퇴 요청 | `DELETE /user-service/api/users/me`; `{password}`; 인증 | `202` `{status:"WITHDRAWING",sagaId}`. 접수 시 회원 `WITHDRAWING`, 요청 이벤트 발행. 결과는 Saga로 처리 | `400 PASSWORD_MISMATCH`(누락·불일치), `401 UNAUTHORIZED`, `404 USER_NOT_FOUND`, `409 WITHDRAWAL_IN_PROGRESS` |
| A4 로그인 | `POST /user-service/api/auth/login`; `{email,password}` | `200` `{userId,role,accessToken,refreshToken,tokenType,expiresIn}`. `expiresIn`은 설정된 access token 유효 시간(초), `Cache-Control: no-store`; access token에 역할 클레임 | `400 INVALID_INPUT`, `401 LOGIN_FAILED`(계정·암호 불일치 또는 비활성 회원) |
| A5 로그아웃 | `POST /user-service/api/auth/logout`; 인증 | `204`, 본문 없음. Redis refresh token 삭제, 이미 발급한 access token은 만료까지 유효 | `401 UNAUTHORIZED` |
| A6 토큰 재발급 | `POST /user-service/api/auth/refresh`; `{refreshToken}` | `200` `{accessToken}`. refresh token과 그 만료 시각은 유지 | `401 INVALID_REFRESH_TOKEN`(만료·위조·Redis 불일치·회원 없음·비활성 회원) |
| A7 내 프로필 수정 | `PUT /user-service/api/profiles/me`; `{nickname,district,sportTypes}`; 인증 | `200` `{nickname,district,preferenceSports}`. 선호 종목은 전체 교체, 미선택 시 `[]` | `400 INVALID_INPUT`, `401 UNAUTHORIZED`, `404 PROFILE_NOT_FOUND`, `409 DUPLICATE_NICKNAME` |
| A8 프로필 조회 | `GET /user-service/api/profiles/{profileId}`; `profileId: Long`은 회원 ID가 아닌 프로필 ID; 인증 | `200` `{id,nickname,district,imageUrl,preferenceSports}` | `401 UNAUTHORIZED`, `404 PROFILE_NOT_FOUND` |

**A3 상태 규칙:** match 정리 성공 시 회원 `WITHDRAWN` 및 refresh token 삭제. 진행 중(`IN_PROGRESS`) 모임의 방장이면 거절하여 `ACTIVE` 복구·알림. PDF v1.0에는 match 응답이 5분 안에 없으면 `ACTIVE`로 복구한다고 적혀 있습니다. `WITHDRAWING` 중에는 로그인·매치 참가를 허용하지 않습니다. Saga 이벤트 세부 필드와 타임아웃 유예 같은 후속 설계는 이 PDF의 확정 범위가 아닙니다.

### A9~A19 운동 매칭·대기열

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A9 생성 | `POST /match-service/api/matches`; `{serviceId,title,description,startAt,endAt,maxParticipant,skillLevel,sportType,genderGroup}`. 시설 PK, 제목 ≤50자, 설명 ≤500자, `endAt > startAt`, 정원 ≥1 | `201` 숫자 `matchId` 하나(객체 아님); 방장 자동 참가. I3으로 활성·운영시간 확인 후 시설 이름·장소·지역·무료 여부·URL 스냅샷 저장 | `400 INVALID_INPUT`, `401 UNAUTHORIZED`, `401 USER_WITHDRAWN`, `401 MATCH_USER_NOT_FOUND`, `404 SERVICE_NOT_FOUND`; `(초안)` `400 FACILITY_INACTIVE`, `400 FACILITY_HOURS_MISMATCH`, `503 FACILITY_SERVICE_UNAVAILABLE` |
| A10 목록·검색 | `GET /match-service/api/matches`; 모든 조건 선택: `serviceId,titleKeyword,descriptionKeyword,startAt,endAt,maxParticipant,skillLevel,sportType,genderGroup,region,status,isFree`. `region`은 자치구명, `maxParticipant`는 정원 상한 | `200` 매치 배열, 없으면 `[]`. `status` 미지정 시 `RECRUITING/CLOSED/IN_PROGRESS`만. 항목 예: `matchId,title,description,startAt,endAt,numCurrentParticipant,maxParticipant,distance,status,skillLevel,sportType,genderGroup,region,isFree`; `distance`는 P2 전까지 `null` | `400 INVALID_INPUT`(잘못된 시간 범위·정원 등) |
| A11 상세 | `GET /match-service/api/matches/{matchId}`; 선택 인증 | `200` 매치·시설 스냅샷·참가자(`profileId,nickname,imageUrl,role`)·`isOwner/isParticipant`. 비로그인 두 플래그 `false`; 취소·완료 매치도 조회 가능 | 잘못된 토큰 `401 UNAUTHORIZED`, `404 MATCH_NOT_FOUND` |
| A12 수정 | `PUT /match-service/api/matches/{matchId}`; `{title,description,startAt,endAt,maxParticipant,skillLevel,genderGroup}` 전체 교체. `sportType/serviceId` 수정 불가 | `200` A11과 같은 상세. 시작 후 수정 금지, 정원은 현재 참가 인원 이상. 정원 변경 시 `RECRUITING ↔ CLOSED` 재계산, 시설 스냅샷 갱신 | `400 INVALID_INPUT`, `401 UNAUTHORIZED`, `403 MATCH_MODIFY_FORBIDDEN`, `404 MATCH_NOT_FOUND`, `400 MATCH_CAPACITY_BELOW_CURRENT`, `400 MATCH_ALREADY_STARTED`; `(초안)` `400 MATCH_MODIFY_NOT_ALLOWED`, `400 FACILITY_HOURS_MISMATCH`, `503 FACILITY_SERVICE_UNAVAILABLE` |
| A13 삭제 | `DELETE /match-service/api/matches/{matchId}`; 방장, 모집중·마감 매치 | `204`, 본문 없음. 참가 기록과 매치 삭제, 알림 없음 | `401 UNAUTHORIZED`, `403 MATCH_DELETE_FORBIDDEN`, `404 MATCH_NOT_FOUND`, `400 MATCH_DELETE_NOT_ALLOWED`(`IN_PROGRESS/COMPLETED/CANCELLED`) |
| A14 참가 | `POST /match-service/api/matches/{matchId}/participants`; 본문 없음 | `201` `{matchParticipantId,matchId,userId,role:"PARTICIPANT"}`. I1로 회원 상태·성별 확인, 비관적 잠금으로 정원 검사. `match.joined.v1`, 마감 시 `match.status-changed.v1` 발행 | `401 UNAUTHORIZED`, `401 MATCH_USER_NOT_FOUND`, `400 MATCH_RECRUITMENT_CLOSED`, `400 MATCH_ALREADY_STARTED`, `400 MATCH_FULL`, `404 MATCH_NOT_FOUND`, `409 MATCH_ALREADY_JOINED`; `(초안)` `400 MATCH_GENDER_NOT_ALLOWED`, `400 USER_NOT_ACTIVE`, `503 USER_SERVICE_UNAVAILABLE` |
| A15 참가 취소 | `DELETE /match-service/api/matches/{matchId}/participants/me`; 본문 없음 | `204`. 시작 후에도 참가 취소 가능. 시작 전 마감 매치에 빈자리가 생기면 모집중으로 전환. 상태 변경 시 이벤트, 취소 자체 알림은 없음; 대기자 승급은 P1 | `401 UNAUTHORIZED`, `403 MATCH_OWNER_CANNOT_LEAVE`, `404 MATCH_NOT_FOUND`, `404 MATCH_PARTICIPANT_NOT_FOUND` |
| A16 내 매치 | `GET /match-service/api/matches/me`; 인증 | `200` 내가 만든·참가한 매치 배열(없으면 `[]`), 시작 시각 내림차순. 항목에 `matchId,title,startAt,endAt,numCurrentParticipant,maxParticipant,status,sportType,region,facilityName,isFree,role`. Gateway의 `X-User-Id` 사용 | `401 UNAUTHORIZED` |
| A17 취소 | `PATCH /match-service/api/matches/{matchId}/cancel`; 방장, 모집중·마감 매치 | `200` `{matchId,status:"CANCELLED"}`. `match.status-changed.v1` 발행, 참가자 알림. 참가·대기 기록 보존 | `401 UNAUTHORIZED`, `404 MATCH_NOT_FOUND`; `(초안)` `403 MATCH_CANCEL_FORBIDDEN`, `400 MATCH_CANCEL_NOT_ALLOWED` |
| A18 대기 등록 **P1** | `POST /match-service/api/matches/{matchId}/waitlist`; 마감(`CLOSED`) 매치만, 방장·기존 참가자 불가, 성별 검사 | `201` `{matchId,userId,position,registeredAt}`. 빈자리가 생기면 등록순 첫 대기자 승급·이벤트 | `401 UNAUTHORIZED`, `404 MATCH_NOT_FOUND`, `409 MATCH_ALREADY_JOINED`, `400 MATCH_OWNER_CANNOT_WAIT`; `(초안)` `409 WAITLIST_ALREADY_JOINED`, `400 MATCH_NOT_FULL`, `400 MATCH_GENDER_NOT_ALLOWED`, `503 USER_SERVICE_UNAVAILABLE` |
| A19 대기 취소 **P1** | `DELETE /match-service/api/matches/{matchId}/waitlist/me` | `204`, 본문 없음 | `401 UNAUTHORIZED`, `404 MATCH_NOT_FOUND`; `(초안)` `404 WAITLIST_NOT_FOUND` |

**목록과 상세의 시설 필드:** 시설 스냅샷을 사용합니다. `reservationDeadlineAt`은 A10·A11에 넣지 않고 A21 시설 상세에만 제공합니다. A13의 삭제와 A17의 상태 취소는 다른 작업입니다.

### A20~A21 시설

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A20 시설 목록 | `GET /facility-service/api/services`; 선택 조건 `region,serviceName,serviceType,status,startTime,endTime`. 시간은 `HH:mm`, `region`은 자치구명 | `200` 배열(없으면 `[]`). 항목 `serviceId`(DB PK), `serviceName,serviceType,region,locationName,contact,status,startTime,endTime,isFree,url,reservationDeadlineAt` | `400 INVALID_SEARCH_CONDITION`(시간 형식 오류 또는 시작 시각 > 종료 시각) |
| A21 시설 상세 | `GET /facility-service/api/services/{serviceId}`; 경로의 `serviceId: Long`은 DB PK | `200` `{id,serviceId,status,serviceName,paymentMethod,locationName,serviceType,region,contact,latitude,longitude,startTime,endTime,url,reservationDeadlineAt}`. `id`는 DB PK, 본문의 문자열 `serviceId`는 서울시 원본 SVCID. 활성 서비스만 조회 | `400 INVALID_SERVICE_ID`, `404 SERVICE_NOT_FOUND`(없음·비활성) |

서울시 공공 API 장애 시에도 DB에 이미 저장한 시설을 조회합니다. 예약은 응답의 `url`로 외부 사이트에 연결합니다. A21의 빈 문자열은 `정보없음`, `paymentMethod`는 `무료/유료/정보없음`입니다.

### A22~A24 AI

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A22 자연어 검색 | `POST /ai-service/api/ai/matches/search`; `{prompt}` 1~500자, 공개 | `200` `{conditions:[{label,value}],matches,criteria,fallback}`. `matches`는 매치 목록 형식, `criteria`는 검색 수정 폼 초기값. LLM 실패·시간초과 때 조건 검색으로 대체하고 `fallback:true` | `400 INVALID_INPUT`, `400 AI_CONDITION_NOT_FOUND`, `400 AI_UNSUPPORTED_SPORT` |
| A23 매치 초안 | `POST /ai-service/api/ai/matches`; `{prompt}` 1~500자, 인증 | `200` `{initialValues:{sportType,region,startAt,endAt,maxParticipant,skillLevel,genderGroup,title,description},facilityCandidates:[]}`. P0에서 후보 `[]`; P1에서 I4로 활성 후보 최대 5개. DB 저장 없음, 폼 확인 후 A9 호출. 종료 시각 없으면 시작+2시간, 성별 구성 없으면 `MIXED`, 제목 50자·설명 500자 제한 | `400 INVALID_INPUT`, `400 AI_DRAFT_INSUFFICIENT`, `400 AI_UNSUPPORTED_SPORT`, `401 UNAUTHORIZED`, `503 AI_UNAVAILABLE`(LLM 실패·시간초과, 직접 입력 안내) |
| A24 맞춤 추천 | `GET /ai-service/api/ai/matches/recommendations`; 인증 | `200` `{matches,fallback}`. 후보 최대 20개에서 LLM이 순서 선택, 최대 3개 반환. 실패 시 최신순 최대 3개와 `fallback:true`, 후보 없으면 `[]` | `401 UNAUTHORIZED`, `404 USER_NOT_FOUND/PROFILE_NOT_FOUND`, `500 AI_RECOMMEND_FAILED`(대체 결과도 실패) |

A22·A24의 매치 후보는 `match-service`의 공개 `GET /api/matches`를 Feign으로 조회합니다. A24는 I1에서 자치구·선호 종목·성별을 받고, 모집중·시작 전·본인 미참가 매치만 후보로 사용합니다. AI 지표 예시는 `ai.request(type=search|draft|recommend, outcome=...)`이며 실제 계측 여부는 구현에서 확인합니다.

### A25~A27 알림

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A25 내 알림 | `GET /notification-service/api/notifications/me`; 인증 | `200` 최신순 최대 50건 배열(페이징 없음). 항목 `{id,type,message,matchId,read,createdAt}`. `JOINED`, `STATUS_CHANGED`, `WITHDRAWAL_REJECTED`; `STARTING_SOON`·`WAITLIST_PROMOTED`는 P1 | `401 UNAUTHORIZED` |
| A26 읽음 | `PATCH /notification-service/api/notifications/{id}/read`; 인증 | `200` `{id,read:true}` | `401 UNAUTHORIZED`; `(초안)` `404 NOTIFICATION_NOT_FOUND`, `403 NOTIFICATION_FORBIDDEN` |
| A27 안 읽은 수 | `GET /notification-service/api/notifications/me/unread-count`; 인증 | `200` `{unreadCount}` | `401 UNAUTHORIZED` |

같은 `eventId` 알림은 한 번만 저장하고, 처리 실패는 3회 재시도 후 DLT로 보냅니다. 이는 PDF의 알림 처리 설명이며 구체 Kafka 토픽·페이로드 계약을 대체하지 않습니다.

### A28~A31 관리자

| ID | 요청·파라미터 | 성공 응답·동작 | API별 오류 |
| --- | --- | --- | --- |
| A28 탈퇴 통계 | `GET /user-service/api/admin/stats`; ADMIN | `200` `{withdrawalSaga:{requested,succeeded,rejected,timedOut,inProgress},users:{active,withdrawing,withdrawn}}`. `withdrawal_saga` 출처, 기간 없는 누적 수치 | `401 UNAUTHORIZED`, `403 FORBIDDEN` |
| A29 매치 통계 | `GET /match-service/api/admin/stats`; ADMIN | `200` `{matches:{total,byStatus:{RECRUITING,CLOSED,IN_PROGRESS,COMPLETED,CANCELLED}},participants:{total}}`. 기간 없는 누적 수치 | `401 UNAUTHORIZED`, `403 FORBIDDEN` |
| A30 즉시 조회 | `GET /prometheus/api/v1/query`; 필수 `query`(PromQL), 선택 `time`(RFC3339 또는 Unix 초). ADMIN | Prometheus 원문 `200` `{status:"success",data:{resultType:"vector",result:[{metric,value:[timestamp,"value"]}]}}` | `401 UNAUTHORIZED`, `403 FORBIDDEN`, Prometheus 표준 `400 {status:"error",errorType,error}` |
| A31 범위 조회 | `GET /prometheus/api/v1/query_range`; `query,start,end,step`(예: `15s`, `1m`). ADMIN | Prometheus 원문 `200` `{status:"success",data:{resultType:"matrix",result:[{metric,values:[[timestamp,"value"],…]}]}}` | `401 UNAUTHORIZED`, `403 FORBIDDEN`, Prometheus 표준 `400`(PromQL·범위 오류) |

Gateway는 A30·A31 두 Prometheus 조회 경로만 열며, 인증 헤더의 JWT 역할 `ADMIN`을 검사합니다. 예시 PromQL의 실제 지표 존재와 수집 상태는 별도 운영 검증 대상입니다.

## 개발자용 상세: 내부 Feign API (I1~I4)

| ID | 내부 경로·파라미터 | 성공 응답·사용처 | 오류·호출자 처리 |
| --- | --- | --- | --- |
| I1 회원 단건 | user-service `GET /internal/users/{id}`; `id: Long` | `200` `{id,gender,status,district,sportTypes}`. match 참가 전 검사, AI 추천 정보 | `404 USER_NOT_FOUND`; match는 회원 확인 불가 시 참가를 `503`으로 거절 |
| I2 회원 일괄 | user-service `GET /internal/users?ids=1,2,3`; 쉼표 구분 회원 ID | `200` `[{id,profileId,nickname,imageUrl}]`; 없는 ID 제외, 비어 있으면 `[]` | 호출 실패 시 매치 상세에서 닉네임 `알 수 없음`으로 대체 |
| I3 시설 단건 | facility-service `GET /internal/facilities/{id}`; 시설 DB PK | `200` `{id,name,startTime,endTime,active,url,locationName,region,isFree}`. 비활성 시설도 `active:false`로 `200`; match는 생성·수정 시 시설 정보 복사 | `404 SERVICE_NOT_FOUND`; 호출 실패 시 매치 생성·수정 거절. 상세는 저장된 스냅샷 사용 |
| I4 시설 후보 **P1** | facility-service `GET /internal/facilities?district=SONGPA&sport=BASKETBALL`; 자치구·종목 코드 | `200` 활성 시설 후보 최대 5개 `[{id,name,locationName,region,startTime,endTime,isFree,url}]`; 없으면 `[]` | 호출 실패 시 AI 초안을 후보 없이 반환 |

`/internal/**`은 Gateway 외부 접근 차단 대상입니다. 내부 API의 구체적인 서비스 간 인증·네트워크 통제는 인프라 구현에서 별도로 검증합니다.

## 원본과 후속 설계의 경계

- **이 문서의 기준:** 팀 제공 `batontouch_API_명세서.pdf`, 표지 `Sporty_v2 API 명세서 v1.0`, 2026-10-30, 총 43쪽. 기존 요약과 위 상세는 이 PDF를 기준으로 기록했습니다.
- **후속 합의는 별도 관리:** R7 DDL, 회원탈퇴 Saga의 30초 유예·이벤트 식별자, Kafka 토픽·페이로드 및 실제 구현 상태는 이 PDF에 모두 실려 있지 않습니다. 해당 계약·결정 문서가 확정되면 관련 API 설명과 함께 갱신해야 합니다.
- **PDF 내부 주의점:** A4의 `expiresIn: 3600`은 예시이며 설정값을 확인해야 합니다. A11은 선택 인증이므로 토큰 부재 401이라는 일반 오류 문구보다 '토큰 없으면 공개 조회' 규칙이 우선합니다. PDF A3의 5분 설명과 후속 Saga 유예 설계는 구분해 기록합니다.
