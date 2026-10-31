# Sporty v2 전체 테스트 케이스 명세서 v0.2

> LG CNS AM INSPIRE 6기 · 2조 바통터치 / MINI PROJECT 2
> 작성: 2026-10-31 · 상태: 설계 초안, 미실행 / 리뷰용
> 원본: 20쪽 PDF. 이 파일은 원본의 135개 TC와 핵심 7종 절차를 Markdown으로 옮긴 것입니다.

미니프로젝트 1의 TC 매트릭스 + API v1.0 전체 35개 + MSA 핵심 검증 7종.

| 전체 테스트 | API 커버리지 | 핵심 시연 | 우선순위 |
| --- | --- | --- | --- |
| 135개 | 35/35 (외부 A1~A31, 내부 I1~I4) | 7종 | P0 82 · P1 43 · P2 10 |

기준: Sporty v2 API 명세서 v1.0 (43쪽), MSA 구현계획 v2 (6쪽), 미니프로젝트 1 테스트 케이스 (13쪽).

## 01. 테스트 개요

| 구분 | 범위 | 수량 / 결과 기준 |
| --- | --- | --- |
| 검증 API | 외부 API A1~A31 + 내부 Feign I1~I4 | 35/35개 API 모두 최소 1개 이상의 직접 연계 TC |
| 케이스 상태 | Not Run / Pass / Fail / Blocked | 초기 상태 Not Run, Fail → 결함 ID 연결 |
| P0 / P1 / P2 | QA 실행 우선순위(팀 기능 개발 우선순위와 별도) | P0 82 / P1 43 / P2 10 |
| 핵심 7종 | Saga 3 / 장애·모니터링 4 | 마지막에 핵심 7종 절차 상세 수록 |
| 검증 경로 | React 또는 API 클라이언트 → Gateway (8000) | 외부 /<service-name>/api/**, 내부 /internal/** 차단 |
| 결과 증빙 | HTTP·DB·이벤트·로그·Grafana·Zipkin | 실제 결과/결함 ID/URL은 Excel 기록표 관리 |

### 실행 전 준비 기준

- USER-A/B/OWNER/ADMIN 인증 계정, 매치 상태별 fixture(RECRUITING/CLOSED/IN_PROGRESS/COMPLETED/CANCELLED), 활성·비활성 시설을 준비합니다.
- JWT·Refresh Token·Webhook과 실제 계정 비밀번호는 테스트 증빙에서 마스킹하고, 격리된 테스트 DB와 데이터를 사용합니다.
- Gateway, Eureka, Config, 5개 비즈니스 서비스, MariaDB 4개 DB, Redis, Kafka, Prometheus·Grafana·Zipkin의 실제 기동 상태를 확인합니다.
- 테스트별 사전/사후 데이터 스냅샷을 남깁니다. 장애 실험은 종료 후 반드시 컨테이너 및 설정을 원복합니다.
- 검증이 불가능한 경우 Blocked 및 차단 사유를 입력합니다. P1/P2 미구현 기능은 Pass로 기록하지 않습니다.

| 구분 | API 명세서 기준 | 검증 주의 |
| --- | --- | --- |
| 공통 오류 | { code, message } | Prometheus 원본 오류는 예외 |
| 회원 탈퇴 | A3 202 WITHDRAWING + sagaId | 비동기 완료/보상 검증 |
| 매치 취소 | A17 CANCELLED 상태·참가 기록 보존 | A13 DELETE는 기록 제거·알림 없음 |
| 선택 기능 | A18/A19는 API 문서 P1, 구현계획에서는 대기열 P2 | 구현 여부에 따라 Not Run/Blocked |
| 관리자 API | A28~A31 명세 있음, 구현계획 관리자 UI는 선택 ⑧ P2 | API 실제 노출 시 인증·인가 검증 필수 |
| 장애 경보 | 구현계획 Slack / 10.31 회의 Discord 초안 | 알림 채널 및 임계값 확인 후 판정 |

## 02. 회원 · 인증 · 프로필

24개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-USR-001 | P0 | 정상 회원가입 [API / A1] | 이메일·닉네임 미사용 | A1 POST 가입 → user/profile/sport_preference 조회 | email=qa1@example.com; MALE; MAPO; FUTSAL | 201 본문 없음; 회원·프로필·선호종목 저장, role=USER | Not Run | — |
| TC-USR-002 | P1 | 이메일 중복 가입 차단 [API / A1] | 기존 이메일 있음 | A1에 중복 이메일 전송 → DB 비교 | email=existing@example.com | 409 DUPLICATE_EMAIL; 회원 추가 생성 없음 | Not Run | — |
| TC-USR-003 | P1 | 닉네임 중복 가입 차단 [API / A1] | 기존 닉네임 있음 | A1에 다른 이메일·동일 닉네임 전송 | nickname=existingName | 409 DUPLICATE_NICKNAME; 회원·프로필 변경 없음 | Not Run | — |
| TC-USR-004 | P1 | 가입 입력 경계·role 위조 차단 [API / A1] | 새 사용자 | 공백 이메일·7자 비밀번호·미지원 종목 각각 요청; role=ADMIN 입력 시도 | password=1234567 /sportTypes=[BAD_CODE] / role=ADMIN | 유효성 위반 400 INVALID_INPUT; 임의 role로 ADMIN 계정 생성 불가 | Not Run | — |
| TC-USR-005 | P0 | 내 정보 조회 및 상태/역할 반환 [API / A2] | ACTIVE 회원 로그인 | A2 GET → 응답과 DB 비교 | Authorization=USER JWT | 200; email·nickname·district·status=ACTIVE·role=USER | Not Run | — |
| TC-USR-006 | P0 | 내 정보 비인증 접근 차단 [Security / A2] | 토큰 없음/만료 | A2 토큰 누락 및 만료 토큰 호출 | Authorization 없음 /expired | 401 UNAUTHORIZED; 개인정보 미노출 | Not Run | — |
| TC-USR-007 | P1 | 탈퇴 진행 상태 조회 [API / A2] | 회원 WITHDRAWING 사전 조건 | A2 GET → 상태 확인 | status=WITHDRAWING | 200; status=WITHDRAWING 노출(로그인 제한 등 실제 인증 정책과 양립 검토) | Not Run | — |
| TC-USR-008 | P0 | 탈퇴 요청 즉시 응답 [API / A3] | ACTIVE 회원·올바른 비밀번호 | A3 DELETE 요청 → 즉시 응답/초기 DB 확인 | password=correct | 202 {status:WITHDRAWING,sagaId}; 요청 이벤트 발행 | Not Run | — |
| TC-USR-009 | P1 | 탈퇴 비밀번호 불일치 [API / A3] | ACTIVE 회원 | A3 잘못된 비밀번호 → DB 확인 | password=wrong | 400 PASSWORD_MISMATCH; 상태 ACTIVE 유지·이벤트 없음 | Not Run | — |
| TC-USR-010 | P0 | 탈퇴 처리 중 중복 요청 차단 [API / A3] | WITHDRAWING 회원의 유효 인 증 경로 | A3 재요청 → Saga 기록 비교 | 동일 회원 2번째 요청 | 409 WITHDRAWAL_IN_PROGRESS; 추가 Saga 미생성 | Not Run | — |
| TC-AUTH-001 | P0 | 정상 로그인 및 권한 응답 [API / A4] | ACTIVE 사용자 | A4 POST → JWT 클레임·Redis 확인 | email=qa1@example.com; password=correct | 200; userId/role/tokenType/accessToken/refreshToken/expiresIn; no-store | Not Run | — |
| TC-AUTH-002 | P1 | 비밀번호/이메일 오류 로그인 [API / A4] | 존재하는 계정·없는 계정 | A4 각각 잘못된 로그인 요청 | wrongpw / unknown@example.com | 401 LOGIN_FAILED; 토큰 미발급 | Not Run | — |
| TC-AUTH-003 | P0 | 탈퇴 상태 회원 로그인 차단 [API / A4] | WITHDRAWING 또는 WITHDRAWN 회원 | A4 정상 자격증명으로 로그인 | status=WITHDRAWING/WITHDRAWN | 401 LOGIN_FAILED; Redis Token 추가 발급 없음 | Not Run | — |
| TC-AUTH-004 | P0 | 로그아웃 Refresh Token 삭제 [API / A5] | 로그인·Redis 토큰 저장 | A5 POST → 동일 Refresh Token으로 A6 호출 | Bearer valid; stored refresh | 204; Redis Refresh Token 제거, 이후 A6 401 INVALID_REFRESH_TOKEN | Not Run | — |
| TC-AUTH-005 | P1 | 로그아웃 인증 누락 [API / A5] | 로그인하지 않음 | A5 Authorization 없이 요청 | Authorization 없음 | 401 UNAUTHORIZED; 타 회원 토큰 영향 없음 | Not Run | — |
| TC-AUTH-006 | P0 | 정상 Access Token 재발급 [API / A6] | ACTIVE 사용자·유효 RefreshToken | A6 POST → 새 토큰 확인 | refreshToken=valid | 200 {accessToken}; Redis에 기존 Refresh Token 유지 | Not Run | — |
| TC-AUTH-007 | P1 | 만료·위조 Refresh Token 거절 [API / A6] | 만료/위조/Redis 불일치 토큰 | A6 각 토큰으로 요청 | refreshToken=expired/forged | 401 INVALID_REFRESH_TOKEN; 토큰 미발급 | Not Run | — |
| TC-AUTH-008 | P0 | 탈퇴 완료 토큰 재발급 차단 [API / A6] | WITHDRAWN 사용자, 이전 Refresh Token | A6 POST 후 상태 확인 | status=WITHDRAWN | 401 INVALID_REFRESH_TOKEN; 회원 권한 부활 없음 | Not Run | — |
| TC-PROFILE-001 | P0 | 정상 프로필 수정 [API / A7] | 로그인·프로필 있음 | A7 PUT → A2 GET·DB 확인 | nickname=새닉네임; district=MAPO; sportTypes=[FUTSAL] | 200; 닉네임·자치구 갱신, 선호 종목 전체 교체 | Not Run | — |
| TC-PROFILE-002 | P1 | 중복 닉네임 수정 거절 [API / A7] | 다른 회원이 닉네임 사용 | A7 중복 닉네임 제출 | nickname=taken | 409 DUPLICATE_NICKNAME; 기존값 유지 | Not Run | — |
| TC-PROFILE-003 | P1 | 잘못된 프로필 값 검사 [API / A7] | 로그인·프로필 있음 | A7 미지원 district 또는 51자 닉네임 요청 | district=INVALID / 51자 닉네임 | 400 INVALID_INPUT; DB 미변경 | Not Run | — |
| TC-PROFILE-004 | P0 | 타 회원 프로필 정상 조회 [API / A8] | 조회 대상 프로필 존재 | A8 GET → 반환 정보 확인 | profileId=3; valid USER JWT | 200; id·nickname·district·imageUrl·preferenceSports | Not Run | — |
| TC-PROFILE-005 | P1 | 존재하지 않는 프로필 [API / A8] | 로그인 회원 | A8 미존재 ID GET | profileId=999999 | 404 PROFILE_NOT_FOUND | Not Run | — |
| TC-PROFILE-006 | P0 | 프로필 비로그인 차단 [Security / A8] | 유효 프로필 있음 | A8 Authorization 없이 GET | Authorization 없음 | 401 UNAUTHORIZED; 프로필 비노출 | Not Run | — |

## 03. 운동 매칭 CRUD · 참가 · 대기열

47개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-MATCH-001 | P0 | 정상 매치 생성 및 OWNER 자동 참가 [API / A9] | ACTIVE 회원·활성 시설·운영시간 내 | A9 POST → A11/DB·I3 연동 확인 | serviceId=12; BASKETBALL; startAt=2026-11-08T19:00:00 | 201 본문에 matchId 숫자; OWNER 참여자 생성; 시설 스냅샷 복사 | Not Run | — |
| TC-MATCH-002 | P1 | 생성 입력값 오류 [API / A9] | ACTIVE 회원·시설 정상 | A9 빈 제목, 종료<시작, 정원=0 각각 요청 | title="" / endAt<startAt/ max=0 | 400 INVALID_INPUT; 매치·참여 관계 미생성 | Not Run | — |
| TC-MATCH-003 | P0 | 비인가 생성 차단 [API / A9] | 활성 시설 정상 | A9 JWT 누락·만료 각각 요청 | Authorization 없음 /expired | 401 UNAUTHORIZED; DB 불변 | Not Run | — |
| TC-MATCH-004 | P1 | 없는 시설/비활성 시설 생성 거절 [API / A9] | 없는 시설·inactive 시설 준비 | A9 serviceId 변경하여 각각 요청 | serviceId=999999 /inactive | 404 SERVICE_NOT_FOUND 또는 400 FACILITY_INACTIVE(초안); DB 불변 | Not Run | — |
| TC-MATCH-005 | P1 | 시설 운영시간 벗어난 생성 [API / A9] | 시설 F-01=09~22 | A9 startAt 23:00 요청 | startAt=23:00 | 400 FACILITY_HOURS_MISMATCH(초안); 신규 매치 없음 | Not Run | — |
| TC-MATCH-006 | P0 | 시설 Feign 실패 시 생성 보호 [Integration / A9·I3] | 시설 서비스 중단 | A9 정상 정보 전송 → DB 확인 | facility-service unavailable | 503 FACILITY_SERVICE_UNAVAILABLE(초안); 부분 생 성 없음 | Not Run | — |
| TC-MATCH-007 | P0 | 무조건 검색 기본 상태 [API / A10] | 상태별 매치 존재 | A10 status 없이 GET | status omitted | 200; RECRUITING/CLOSED/IN_PROGRESS만 조회 | Not Run | — |
| TC-MATCH-008 | P0 | 종목·숙련도·지역 복합 검색 [API / A10] | 서로 다른 조건의 매치 준비 | A10 복합 쿼리 → 모든 결과 검사 | sportType=FUTSAL; skillLevel=BEGINNER; region=송파구 | 200; 필터 모두 만족, facility 복사 지역 사용 | Not Run | — |
| TC-MATCH-009 | P1 | COMPLETED·CANCELLED 명 시 검색 [API / A10] | 완료·취소 매치 존재 | A10 status=COMPLETED 및 CANCELLED 각 각 조회 | status=COMPLETED/CANCELLED | 200; 지정 상태의 매치만 반환 | Not Run | — |
| TC-MATCH-010 | P1 | 검색 결과 없음 [API / A10] | 일치 매치 없음 | A10 존재하지 않는 제목 쿼리 | titleKeyword=없는검색어 | 200 [] | Not Run | — |
| TC-MATCH-011 | P1 | 잘못된 검색 범위 차단 [API / A10] | 검색 서비스 정상 | A10 종료<시작 / 정원<=0 | endAt<startAt /maxParticipant=0 | 400 INVALID_INPUT; 500 아님 | Not Run | — |
| TC-MATCH-012 | P0 | 비로그인 매치 상세 조회 [API / A11] | 매치·참가자 존재 | A11 토큰 없이 GET | matchId=existing | 200; isOwner=false,isParticipant=false; 시설 스냅샷 포 함 | Not Run | — |
| TC-MATCH-013 | P1 | 로그인에 따른 참가 상태 표시 [API / A11] | 매치 OWNER/일반 참가자/비참가 계정 | A11 계정별 GET 비교 | OWNER/participant/outsider JWT | 200; isOwner/isParticipant가 각 계정 관계와 일치 | Not Run | — |
| TC-MATCH-014 | P0 | 선택 인증의 잘못된 토큰 차단 [Security / A11] | 매치 존재 | A11 만료 토큰으로 GET | Authorization=expired | 401 UNAUTHORIZED; 익명으로 간주하지 않음 | Not Run | — |
| TC-MATCH-015 | P1 | 존재하지 않는 매치 상세 [API / A11] | 매치 ID 없음 | A11 GET 없는 ID | matchId=999999 | 404 MATCH_NOT_FOUND | Not Run | — |
| TC-MATCH-016 | P1 | 닉네임 Feign 실패 시 표시 [Integration / A11·I2] | 매치 참가자·User Service 중단 | A11 참가자 목록 조회 | I2 timeout | 200 상세; 참가자 닉네임 "알 수 없음" Fallback | Not Run | — |
| TC-MATCH-017 | P0 | 방장 매치 정상 수정 [API / A12] | RECRUITING·OWNER | A12 PUT 전체 필드 전송 → DB/A11 | title=수정; maxParticipant=12 | 200 상세 응답·DB 갱신; 수정 불가 종목·시설 유지 | Not Run | — |
| TC-MATCH-018 | P0 | 방장이 아닌 사용자 수정 차단 [API / A12] | PARTICIPANT가 OWNER 아닌 매치 | A12 PUT 참가자 JWT | PARTICIPANT JWT | 403 MATCH_MODIFY_FORBIDDEN; DB 불변 | Not Run | — |
| TC-MATCH-019 | P0 | 정원 변경 상태 재계산 [API / A12] | 현재 인원 5명, max=8 | A12 정원=5로 변경 → 다시 정원=8 | max=5 / max=8 | 200; CLOSED로 전환 후 RECRUITING 복귀 | Not Run | — |
| TC-MATCH-020 | P0 | 현재 참가자보다 낮은 정원 차단 [API / A12] | 현재 참가 5명 | A12 maxParticipant=4 제출 | maxParticipant=4 | 400 MATCH_CAPACITY_BELOW_CURRENT; 참가·정원 불변 | Not Run | — |
| TC-MATCH-021 | P1 | 시작 후/취소 후 수정 차단 [API / A12] | IN_PROGRESS·COMPLETED·CANCELLED 매치 | A12 각각 PUT | status=IN_PROGRESS/COMPLETED/CANCELLED | 400 MATCH_ALREADY_STARTED 또는 MATCH_MODIFY_NOT_ALLOWED(초안); DB 불변 | Not Run | — |
| TC-MATCH-022 | P0 | 방장 모집중 매치 삭제 [API / A13] | OWNER, RECRUITING 매치+참가자 | A13 DELETE → DB 조회 | matchId=existing | 204; matches·참가 관계 삭제; 알림 이벤트 없음 | Not Run | — |
| TC-MATCH-023 | P0 | 타인 매치 삭제 차단 [Security / A13] | 비OWNER 토큰 | A13 DELETE → DB 확인 | PARTICIPANT JWT | 403 MATCH_DELETE_FORBIDDEN; 데이터 유지 | Not Run | — |
| TC-MATCH-024 | P1 | 진행·완료·취소 매치 삭제 차단 [API / A13] | 각 상태 매치 존재 | A13 각각 DELETE | IN_PROGRESS/COMPLETED/CANCELLED | 400 MATCH_DELETE_NOT_ALLOWED; DB 불변 | Not Run | — |
| TC-MATCH-025 | P1 | 없는 매치 삭제 [API / A13] | OWNER 로그인 | A13 없는 ID DELETE | matchId=999999 | 404 MATCH_NOT_FOUND | Not Run | — |
| TC-JOIN-001 | P0 | 정상 참가와 알림 발행 [API / A14] | RECRUITING, 잔여석, ACTIVE 회원 | A14 POST → DB·Kafka 확인 | matchId=existing; userId=5 | 201 participant 응답·DB 저장; match.joined.v1 발행 | Not Run | — |
| TC-JOIN-002 | P0 | 중복 참가·방장 재참가 차단 [API / A14] | 이미 참가한 회원/OWNER | A14 같은 회원 또는 OWNER 재요청 | userId=joined/owner | 409 MATCH_ALREADY_JOINED; 중복 레코드 없음 | Not Run | — |
| TC-JOIN-003 | P0 | 정원/마감/시작 후 참가 차단 [API / A14] | CLOSED 또는 IN_PROGRESS 매치 | A14 각각 POST | status=CLOSED/IN_PROGRESS | 400 MATCH_RECRUITMENT_CLOSED 또는 MATCH_ALREADY_STARTED/MATCH_FULL; 인원 불변 | Not Run | — |
| TC-JOIN-004 | P0 | 성별 조건 불일치 참가 차단 [API / A14] | MALE 전용·FEMALE 사용자 | A14 POST → I1 결과 연계 | genderGroup=MALE; gender=FEMALE | 400 MATCH_GENDER_NOT_ALLOWED(초안); 참가 레코드 없음 | Not Run | — |
| TC-JOIN-005 | P0 | 탈퇴 처리 중 참가 거부 [API / A14] | user.status=WITHDRAWING | A14 POST → I1 상태 확인 | user.status=WITHDRAWING | 400 USER_NOT_ACTIVE(초안); 참가 레코드 없음 | Not Run | — |
| TC-JOIN-006 | P0 | User Service 장애 시 참가 거절 [Integration / A14·I1] | user-service 다운 | A14 POST → participant DB 확인 | I1 unavailable | 503 USER_SERVICE_UNAVAILABLE(초안); 기존 참가·정원 유지 | Not Run | — |
| TC-JOIN-007 | P0 | 동시 참가 정원 초과 방지 [Concurrency / A14] | 정원 10, 현재 1, 유효 사용자 100 명 | 동시 POST → 전체 성공 건수/DB count 확인 | 100 VU; max=10; current=1 | 성공 총원<=10, 중복/초과 없음; 상태 CLOSED | Not Run | — |
| TC-JOIN-008 | P0 | 일반 참가 정상 취소 [API / A15] | 참가자·시작 전 모임 | A15 DELETE → 참가 관계 조회 | participant JWT | 204; 본인 참가 기록 제거·타인 유지 | Not Run | — |
| TC-JOIN-009 | P0 | 마감 모임 인원 이탈 재모집 [API / A15] | CLOSED 매치·P1 대기열 없음 | A15 마지막 참가자 취소 → 상태 확인 | status=CLOSED | 204; CLOSED→RECRUITING; status-changed 발행 | Not Run | — |
| TC-JOIN-010 | P0 | 방장 참가 취소 차단 [API / A15] | OWNER 자동 참가 | A15 OWNER JWT로 DELETE | OWNER JWT | 403 MATCH_OWNER_CANNOT_LEAVE; 원본 유지 | Not Run | — |
| TC-JOIN-011 | P1 | 미참가 사용자 참가 취소 [API / A15] | 참가 기록 없는 일반 회원 | A15 DELETE → DB 확인 | nonparticipant JWT | 404 MATCH_PARTICIPANT_NOT_FOUND; 데이터 불변 | Not Run | — |
| TC-MATCH-026 | P0 | 내가 만든·참가한 매치만 조회 [API / A16] | OWNER/참여 매치 혼합 | A16 GET → 반환 role/DB 비교 | USER JWT | 200; 본인 관련 매치만 포함, startAt 역순 | Not Run | — |
| TC-MATCH-027 | P0 | 내 매치 목록 인증·데이터 격리 [Security / A16] | A/B 사용자 분리 | A16 토큰 누락 및 A/B 토큰 각각 실행 | unauthorized /userA/userB | 누락 401; 200 조회에 타인만 참가한 매치 없음 | Not Run | — |
| TC-MATCH-028 | P0 | 방장 모임 취소 및 참가자 알림 [API / A17] | RECRUITING·OWNER·참가자 존 재 | A17 PATCH → A11·알림함·DB 확인 | matchId=existing | 200 {matchId,status:CANCELLED}; status-changed 발행, 기록 유지 | Not Run | — |
| TC-MATCH-029 | P1 | 타인 취소·종료후 취소 차단 [API / A17] | 타인 JWT / IN_PROGRESS | A17 각각 PATCH | nonOWNER / IN_PROGRESS | 403 MATCH_CANCEL_FORBIDDEN(초안) 또는 400 MATCH_CANCEL_NOT_ALLOWED(초안); 원본 유지 | Not Run | — |
| TC-MATCH-030 | P0 | 삭제와 취소 부작용 차이 [Integration / A17·A13] | RECRUITING 매치 각 1건 | A13·A17 별도 호출 → 알림 및 DB 비교 | M-delete, M-cancel | 삭제=레코드 제거·알림 없음; 취소=CANCELLED·기록 유 지·알림 있음 | Not Run | — |
| TC-WAIT-001 | P2 | CLOSED 매치 대기 등록 [API / A18] | CLOSED·미참가 ACTIVE 회원 | A18 POST → position 기록 확인 | CLOSED matchId; userId | 201 {matchId,userId,position,registeredAt}; 대기 기록 | Not Run | — |
| TC-WAIT-002 | P2 | 방장·참가자·중복 대기 차단 [API / A18] | 방장/참가자/이미 대기 회원 | A18 각각 POST | OWNER/participant/waitlisted | 400/409; MATCH_OWNER_CANNOT_WAIT·MATCH_ALREADY_JOINED·WAITLIST_ALREADY_JOINED(초안) | Not Run | — |
| TC-WAIT-003 | P2 | RECRUITING 상태 대기 거부 [API / A18] | 정원 여유 있는 매치 | A18 POST | status=RECRUITING | 400 MATCH_NOT_FULL(초안); 대기 미등록 | Not Run | — |
| TC-WAIT-004 | P2 | 정상 대기 취소 [API / A19] | 대기 1건 존재 | A19 DELETE → DB 조회 | userId=waitlisted | 204; 대기 레코드 제거 | Not Run | — |
| TC-WAIT-005 | P2 | 없는 대기 취소 [API / A19] | 대기 기록 없음 | A19 DELETE | userId=notWaitlisted | 404 WAITLIST_NOT_FOUND(초안) | Not Run | — |
| TC-WAIT-006 | P2 | 참가 취소 후 대기자 자동 승급 [Integration / A15·A18] | CLOSED + 1번 대기자 등록 | A15 취소 → 승급 후 정원·이벤트 확인 | position=1 | CLOSED 유지, 1번 대기자 PARTICIPANT, waitlist-promoted 발행 | Not Run | — |

## 04. 체육시설 · AI 매칭

20개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-FAC-001 | P0 | 시설 목록 조건별 조회 [API / A20] | 공공데이터 동기화된 시설 DB | A20 GET region·type·status 필터 | region=송파구; serviceType=농구장 | 200; 조건 만족 시설만 반환, url·startTime 등 포함 | Not Run | — |
| TC-FAC-002 | P1 | 시설 검색 결과 없음 [API / A20] | 일치 시설 없음 | A20 희귀 서비스명 GET | serviceName=neverexists | 200 [] | Not Run | — |
| TC-FAC-003 | P0 | 시설 시간 조건 오류 [API / A20] | 서비스 기동 | A20 잘못된 시각/시작>종료 입력 | startTime=25:99 /22:00>09:00 | 400 INVALID_SEARCH_CONDITION(500 방지) | Not Run | — |
| TC-FAC-004 | P1 | 공공 Open API 장애 시 DB 조회 [Integration / A20] | 기존 DB 적재·외부 API 차단 모킹 | 동기화 실패 유발 → A20 GET | 서울시 API unavailable | 동기화 오류 로그; 조회는 200 및 기존 데이터 보존 | Not Run | — |
| TC-FAC-005 | P0 | 시설 상세 정상 조회 및 외부 URL [API / A21] | active 시설 | A21 GET → 세부 필드·url 확인 | serviceId=12 | 200; id(PK)·serviceId(SVCID) 구분 ·url·reservationDeadlineAt 포함 | Not Run | — |
| TC-FAC-006 | P1 | 없는·비활성 시설 상세 [API / A21] | missing/inactive 시설 | A21 GET 각각 | serviceId=999999/inactive | 404 SERVICE_NOT_FOUND; 비활성 상세 조회 불가 | Not Run | — |
| TC-FAC-007 | P1 | 잘못된 시설 ID 및 누락 필드 [API / A21] | 문자 ID/빈 필드 시설 | A21 GET abc 및 일부 빈 필드 시설 | serviceId=abc / blankfield | 400 INVALID_SERVICE_ID; 빈 문자열 필드 "정보없음" | Not Run | — |
| TC-AI-001 | P0 | 자연어 매치 검색 정상 [API / A22] | 관련 매치 존재 | A22 POST → conditions·criteria·matches 비 교 | prompt=이번 주말 강남에 서 풋살 초보 찾아줘 | 200 {conditions,matches,criteria,fallback:false}; 검색 조건 일치 | Not Run | — |
| TC-AI-002 | P1 | 자연어 검색 빈값·길이 초과 [API / A22] | AI 서비스 정상 | A22 빈 문자열/501자 prompt 각각 | prompt="" / 501자 | 400 INVALID_INPUT; LLM 불필요 호출 방지 | Not Run | — |
| TC-AI-003 | P1 | 조건 없는 질문·미지원 종목 [API / A22] | AI 서비스 정상 | A22 조건 없는/미지원 종목 입력 | prompt=아무거나 / 스쿼 시 | 400 AI_CONDITION_NOT_FOUND 또는 AI_UNSUPPORTED_SPORT | Not Run | — |
| TC-AI-004 | P0 | 검색 LLM 장애 시 조건 검색 대체 [Integration / A22] | match-service 정상·LLM 실패 모킹 | A22 유효 문장 요청 → fallback 확인 | LLM timeout; FUTSAL/MAPO | 200 fallback=true; 조건 기반 매치 검색 결과 반환 | Not Run | — |
| TC-AI-005 | P0 | 매치 생성 초안 정상·미저장 [API / A23] | 로그인·LLM 정상 | A23 POST → DB·initialValues 확인 | prompt=토요일 19시 송파 농구 10명 | 200 {initialValues,facilityCandidates}; 실제 match DB 미생성 | Not Run | — |
| TC-AI-006 | P1 | 불완전한 프롬프트 기본값 [API / A23] | 로그인·일부 조건 있는 프롬프트 | A23 종목만 입력 → 초안 확인 | prompt=축구 모집 | 200; genderGroup=MIXED, 미확정 조건은 계약대로 null/ 기본 | Not Run | — |
| TC-AI-007 | P0 | LLM 장애 시 초안 생성 거부 [Integration / A23] | 로그인·LLM timeout | A23 POST → 응답 확인 | LLM unavailable | 503 AI_UNAVAILABLE; 초안 데이터 미저장 | Not Run | — |
| TC-AI-008 | P1 | 초안 입력 오류·권한 오류 [API / A23] | 비로그인 또는 빈 프롬프트 | A23 빈 prompt(로그인) 및 JWT 없는 요청 | prompt="" / no JWT | 400 INVALID_INPUT / 401 UNAUTHORIZED; 불필요한 LLM 호출 없음 | Not Run | — |
| TC-AI-009 | P1 | P1 시설 후보 조회 [Integration / A23·I4] | 시설 후보 5건 이상 존재 | A23 요청 → I4 결과 활용 | district=SONGPA; sport=BASKETBALL | facilityCandidates 최대 5개; 실패 시 빈 배열로 초안 반환 | Not Run | — |
| TC-AI-010 | P0 | 회원 맞춤 추천 정상 [API / A24] | 회원 선호·모집 매치 존재 | A24 GET → 추천 규칙/응답 비교 | USER JWT; district=MAPO; FUTSAL | 200 {matches,fallback:false}; 최대 3개·내가 참가한 매치 제외 | Not Run | — |
| TC-AI-011 | P1 | 추천 후보 없음 [API / A24] | 추천 가능한 매치 없음 | A24 GET | USER with nocandidates | 200 {matches:[],fallback:false 또는 구현계약 맞춤}; 길 이 0 | Not Run | — |
| TC-AI-012 | P0 | 추천 LLM 실패 시 최신순 대체 [Integration / A24] | 회원/후보 존재·LLM 중단 | A24 GET → 최대 3개와 fallback 확인 | LLM timeout | 200 {matches:[...],fallback:true}; 최신순 후보(최대3) | Not Run | — |
| TC-AI-013 | P1 | 추천 비로그인/회원 없음 [API / A24] | 토큰 없음·회원 정보 누락 | A24 JWT 누락 또는 내부 회원 조회 404 | no JWT / internal user404 | 401 UNAUTHORIZED 또는 404 USER_NOT_FOUND/PROFILE_NOT_FOUND | Not Run | — |

## 05. 알림함 · 관리자 · 내부 Feign

25개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-NOTI-001 | P0 | 내 알림 목록 최신순·최대 50건 [API / A25] | 회원 알림 60건 | A25 GET → 개수·정렬 확인 | USER JWT; count=60 | 200 목록 최대 50건, createdAt 역순, 본인 알림만 | Not Run | — |
| TC-NOTI-002 | P0 | 알림 종류·연계 매치 표시 [API / A25] | JOINED/STATUS_CHANGED/REJECTED 알림 | A25 GET → type·matchId·read 확인 | noti fixtures | 200; type·message·matchId·read·createdAt 계약 준 수 | Not Run | — |
| TC-NOTI-003 | P0 | 타 사용자 알림 격리 [Security / A25] | USER-A/B 알림 각각 | A/B 토큰으로 A25 조회 | USER-A JWT | 200; USER-B 알림·식별정보 노출 없음 | Not Run | — |
| TC-NOTI-004 | P0 | 알림 정상 읽음 처리 [API / A26] | 본인 미읽음 알림 | A26 PATCH → A27 다시 조회 | notificationId=301 | 200 {id,read:true}; DB read=true, unreadCount 감소 | Not Run | — |
| TC-NOTI-005 | P0 | 타인 알림 읽음 차단 [Security / A26] | 다른 회원의 알림 ID | A26 B 토큰으로 A 소유 알림 요청 | otherUserNotificationId | 403 NOTIFICATION_FORBIDDEN(초안); 소유자 알림 무변 경 | Not Run | — |
| TC-NOTI-006 | P1 | 없는 알림 읽음 처리 [API / A26] | ID 없는 상태 | A26 PATCH missing ID | id=999999 | 404 NOTIFICATION_NOT_FOUND(초안) | Not Run | — |
| TC-NOTI-007 | P0 | 미읽음 개수 조회 [API / A27] | 미읽음 2건 저장 | A27 GET → DB count 비교 | USER JWT | 200 {unreadCount:2}; 본인만 집계 | Not Run | — |
| TC-NOTI-008 | P0 | 읽음 처리 전후 미읽음 일치 [API / A27] | 미읽음 알림 2건 | A27 → A26 → A27 | read one notification | unreadCount 2→1, 중복 읽음 추가 감소 없음 | Not Run | — |
| TC-NOTI-009 | P0 | 알림 관련 API 비로그인 차단 [Security / A25~A27] | JWT 없음/만료 | 각 API 토큰 없이 호출 | no JWT | 401 UNAUTHORIZED; 타인 알림·수량 미노출 | Not Run | — |
| TC-ADMIN-001 | P2 | 관리자 탈퇴 Saga 누적 통계 [API / A28] | ADMIN JWT·Saga 데이터 | A28 GET → Saga DB와 수치 대조 | role=ADMIN | 200; requested/succeeded/rejected/timedOut/inProgress 및 users 상태별 수 | Not Run | — |
| TC-ADMIN-002 | P0 | 일반 사용자 Saga 통계 접근 금지 [Security / A28] | USER JWT | A28 GET | role=USER | 403 FORBIDDEN | Not Run | — |
| TC-ADMIN-003 | P2 | 관리자 매치/참가 누적 통계 [API / A29] | ADMIN JWT·매치 데이터 | A29 GET → 상태별 합계 비교 | role=ADMIN | 200; matches.total/byStatus·participants.total 일치 | Not Run | — |
| TC-ADMIN-004 | P0 | 일반 사용자 매치 통계 접근 금지 [Security / A29] | USER JWT | A29 GET | role=USER | 403 FORBIDDEN | Not Run | — |
| TC-ADMIN-005 | P2 | Prometheus 즉시 지표 조회 [API / A30] | ADMIN JWT·Prometheus 정상 | A30 정상 PromQL GET | query=up | 200; Prometheus vector 표준 응답 패스스루 | Not Run | — |
| TC-ADMIN-006 | P0 | Prometheus 조회 권한·경로 제 한 [Security / A30] | USER 토큰/불허 경로 | A30 USER 및 /prometheus/api/v1/targets 호출 | role=USER / targets | 403 FORBIDDEN / 미허용 경로 외부 차단 | Not Run | — |
| TC-ADMIN-007 | P2 | Prometheus 범위 지표 조회 [API / A31] | ADMIN JWT·Prometheus 정상 | A31 query,start,end,step 전달 | query=up; 2026-11-04; step=15s | 200; matrix 타입 표준 응답 | Not Run | — |
| TC-ADMIN-008 | P1 | 잘못된 범위·PromQL 및 권한 [Security / A31] | ADMIN/USER JWT | A31 잘못된 range·USER 요청 | start>end / query=invalid / role=USER | Prometheus 오류 400 passthrough; USER는 403 | Not Run | — |
| TC-INTERNAL-001 | P0 | 회원 내부 단건 조회 [Integration / I1] | User Service 기동·회원 존재 | 서비스 내부에서 I1 호출 | /internal/users/5 | 200; id,gender,status,district,sportTypes | Not Run | — |
| TC-INTERNAL-002 | P1 | 회원 내부 조회 404 [Integration / I1] | 없는 회원 ID | I1 GET missing | id=999999 | 404 USER_NOT_FOUND | Not Run | — |
| TC-INTERNAL-003 | P0 | 회원 닉네임 일괄 조회·일부 없음 [Integration / I2] | 회원 1·5 존재, 999999 없음 | 서비스 내부 I2 ids=1,5,999999 | ids=1,5,999999 | 200; 존재 회원만 포함, profileId/nickname/imageUrl 일 치 | Not Run | — |
| TC-INTERNAL-004 | P0 | 회원 닉네임 Feign 장애 fallback [Integration / I2] | User Service 비가용 | 매치 A11 호출하여 참가자 닉네임 검사 | user-service unavailable | A11 정상 조회 유지, 닉네임 "알 수 없음" | Not Run | — |
| TC-INTERNAL-005 | P0 | 활성·비활성 시설 내부 조회 [Integration / I3] | 각 시설 존재 | 서비스 내부 I3 각각 GET | active=true / false | 둘 다 200; 비활성은 active:false(외부 A21과 차이) | Not Run | — |
| TC-INTERNAL-006 | P1 | 시설 없음 내부 조회 [Integration / I3] | missing 시설 | I3 GET missing | id=999999 | 404 SERVICE_NOT_FOUND | Not Run | — |
| TC-INTERNAL-007 | P1 | AI 시설 후보 필터·최대 5개 [API / I4] | 시설 6건 이상 | 서비스 내부 I4 district·sport GET | district=SONGPA; sport=BASKETBALL | 200; 활성 시설만, 최대5개, 일치 결과 | Not Run | — |
| TC-INTERNAL-008 | P0 | Gateway 외부 내부 API 접근 차 단 [Security / I1~I4] | Gateway 8000 외부 요청 | GET /internal/users/5 및 /internal/facilities/12 | public external client | 외부 라우트 차단; 내부 회원/시설 데이터 비노출 | Not Run | — |

## 06. 공통 보안 · Kafka · 상태 전이

12개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-SEC-001 | P0 | X-User-Id 위조 방지 [Security / A2·A14·공통] | 서로 다른 USER-A/B 토큰 | A14 USER-A JWT + X-User-Id=B 송신 → DBowner 확인 | X-User-Id: USER-B | Gateway가 헤더 제거·검증 JWT ID 주입, B로 참가 기록 생 성 안 됨 | Not Run | — |
| TC-SEC-002 | P0 | 선택/공개 API 잘못된 JWT 차단 [Security / A10·A11·공통] | 공개 매치 존재 | A10/A11 토큰 없음, 만료 토큰 각각 호출 | no JWT vs expired | 미제공 토큰 200 / 유효하지 않은 토큰 401 | Not Run | — |
| TC-SEC-003 | P0 | 오류 JSON 표준화 [Contract / 공통] | 각 서비스 오류 유도 가능 | A1/A9/A14/A20 각 오류 응답 검사 | invalid request | 일반 서비스 실패 {code,message}; Prometheus 오류만 표준 원문 전달 | Not Run | — |
| TC-SEC-004 | P0 | 서비스별 DB 소유권·교차 FK 분 리 [Architecture / 공통] | MariaDB 4개 schema, MSA 모 듈 | schema FK·DataSource 접근·Entity 참조 점 검 | user/match/facility/notification db | 서비스 DB 직접 접근 분리·교차 FK 없음; ai DB 없음 | Not Run | — |
| TC-KAFKA-001 | P0 | 참가 알림 Producer→Consumer [Integration / A14·A25] | OWNER+일반 참가자, Kafka 정 상 | A14 참가 후 notification 저장·조회 | match.joined.v1 | 참가자·방장 대상 알림 각 1회; 핵심 참가 트랜잭션 완료 | Not Run | — |
| TC-KAFKA-002 | P0 | 정원 마감·매치 취소 알림 [Integration / A14·A25] | 정원 1석/참가자 존재 | 마지막 참가자 POST 후 A17 PATCH | match.status-changed.v1 to=CLOSED/CANCELLED | 정원 마감 방장 알림; 취소 시 참가자 알림 | Not Run | — |
| TC-KAFKA-003 | P0 | eventId 중복 수신 멱등 처리 [Integration / A25] | 알림 이벤트·eventId 확인 | 동일 이벤트 두 번 주입 → DB count 확인 | eventId=fixed-id | event_id UNIQUE: 동일 대상 알림 중복 저장 없음 | Not Run | — |
| TC-KAFKA-004 | P0 | Consumer 실패 재시도·DLT [Chaos / A25] | Kafka/notification 활성·오류 유 도 | Consumer 처리 3회 실패 유도 → DLT 검사 | malformed/eventprocessing exception | 3회 재시도 후 DLT, 정상 이벤트 처리 영향 최소화 | Not Run | — |
| TC-KAFKA-005 | P1 | 일반 참가 취소 자체 알림 없음 [Contract / A15·A25] | 기존 참가자 | A15 DELETE → notification 신규 이벤트 검사 | participant leave | 참가 취소 자체 알림 없음; 상태 변경 시 status-changed는 발행 가능 | Not Run | — |
| TC-FLOW-001 | P0 | 시작·종료 스케줄러 상태 전이 [Integration / A10·A11] | startAt/endAt 경계 매치·스케줄 러 동작 | 시작/종료 시각 경과 후 상태 및 목록 조회 | RECRUITING,CLOSED; time boundary | IN_PROGRESS→COMPLETED 자동 전이, 기본 목록에서 COMPLETED 제외 | Not Run | — |
| TC-FLOW-002 | P0 | 시작된 매치 수정·추가 참가 차단 [Business / A12·A14] | IN_PROGRESS 매치 | A12 PUT/A14 POST 시도 | status=IN_PROGRESS | 각각 계약 코드 400; 원본 데이터 유지 | Not Run | — |
| TC-FLOW-003 | P1 | 시설 매일 03:00 동기화 [Integration / A20] | 서울시 API Mock, 시설 DB | 스케줄러 또는 실행시각 조정→상태 검사 | scheduled 03:00 | 동기화 성공 시 반영, 실패 시 원본 DB 유지 및 오류 기록 | Not Run | — |

## 07. 핵심 시연 TC 7종 요약

7개 케이스. API 원본 번호(A/I) 및 미니프로젝트 1 TC ID는 Excel 원본 대응란 참고.

| TC ID | 우선 | 시나리오/유형 | 사전조건 | 테스트 절차 | 테스트 데이터 | 예상 결과 | 상태 | 결함 ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-SAGA-001 | P0 | 정상 회원 탈퇴 및 분산 데이터 정 리 [Integration / Kafka / DB / A3] | U-01은 ACTIVE, 비밀번호를 알고 있으며 유효한 Access/RefreshToken을 보유한다.; U-01이 OWNER인 모집 중 매치 M-01(참가자 있음) 및 PARTICIPANT인 별 도 매치 M-02를 준비한다. 진행 중 매치의 OWNER는 아니다. | U-01의 유효 토큰으로 탈퇴 API에 비밀번호를 전 달; user_db의 사용자와 withdrawal_saga 및 요청 이벤트를 확인; Match Service가 요청을 소 비하도록 하고 M-01과 M-02 정리; 결과/복구 확 인 | U-01: ACTIVE /password=정상값 /M-01: RECRUITING, OWNER / M-02: RECRUITING, PARTICIPANT | HTTP 202; status=WITHDRAWING, sagaId 존재; WITHDRAWING 기록; 동일 sagaId를 지닌 요청 이벤트 발 행; M-01 CANCELLED; M-02에서 U-01 참가 관계정리; 정리 완료 이벤트; 최종 정합성 및 증빙 확인 | Not Run | — |
| TC-SAGA-002 | P0 | 진행 중 매치 방장 탈퇴 거절 및 보 상 [Integration / Kafka / DB / A3] | U-02는 ACTIVE 회원이며 M-03 의 OWNER이다. M-03은 IN_PROGRESS 상태로 실제 참가 기록이 존재한다.; User·Match·Notification·Kafka 서비스 정상 실 행; M-03 및 관련 참가/대기 레코드를 사전 조회한다. | M-03 상태·참가자·방장 ID를 DB 및 API로 저장; U-02가 정상 비밀번호로 탈퇴 요청; MatchService에서 해당 sagaId의 탈퇴 요청 처리; 결과 /복구 확인 | U-02 ACTIVE, M-03 IN_PROGRESS, role=OWNER, participantCount=N(사전 기록) | M-03 IN_PROGRESS, U-02 OWNER 기준점 확보; HTTP202; status=WITHDRAWING, sagaId 존재; 진행 중 OWNER 존재로 거절 이벤트 발행; 최종 정합성 및 증빙 확 인 | Not Run | — |
| TC-SAGA-003 | P0 | Match Service 장애 시 5분 타임 아웃 보상 [Chaos / Integration / DB /A3] | U-03 ACTIVE; 진행 중 매치 OWNER가 아니고 매치/참가 데이터가 존재하는 테스트 전용 사용자. ; User Service·Kafka·DB 정상 상태; Match Service만 안전하게 중단 가능하며 관리자 통계 사전 값 확보. | Match Service를 중단하고 실제 중단 상태 확인; U-03 회원 탈퇴 요청; 요청 이벤트 발행 및 미처 리 상태 확인; 결과/복구 확인 | U-03 ACTIVE; timeout=5 분(계획 기준); MatchService 중단 | Match 요청 Consumer 미동작; User·Kafka는 정상; HTTP 202; WITHDRAWING 및 sagaId 반환; WITHDRAWING 유지, cleaned/rejected 결과 미도착; 최 종 정합성 및 증빙 확인 | Not Run | — |
| TC-OBS-001 | P0 | Facility Service 중단·CB 차단· 복구 [Chaos / Feign / Monitoring /A9] | 시설 F-01 active=true, 운영시간 내 신규 매치 요청 데이터 및 기존 매치 M-04(시설 복사본 존재).; Facility·Match·Gateway·Prometheus·Grafana 기동, Feign·Resilience4j 계측 및 경보 규칙 확인. | 정상 상태에서 A9 매치 생성 및 A10/A11 조회; Facility Service 컨테이너 중단; A9를 정상 데이터로 충분히 반복 호출; 결과/복구 확인 | F-01=활성 시설, startAt/endAt=운영시간 내; 장애명령: dockercompose stop facility-service (서비스명 실제 확인) | 201 생성, 200 조회, baseline 수집; 시설 서비스 비가용·모 니터링 장애 변화; Feign 실패, 생성 거절; DB에 신규 매치 미반영; 최종 정합성 및 증빙 확인 | Not Run | — |
| TC-OBS-002 | P0 | Facility Service 응답 지연·추적· 복구 [Latency / Tracing /Monitoring / A9] | Facility Service 정상 기동, 메트 릭·Zipkin trace 수집 가능.; config-repo의 demo.delay-ms 및 busrefresh 기능 구현 여부를 먼저 확인한다. Cloud Bus는 P1 선택 범위. | 정상 상태에서 A9 요청 여러 건의 지표·Trace 확 보; Facility 응답에 demo.delay-ms 지연 설정 및 반영; A9 요청을 반복하여 호출 경로에 지연 발생; 결과/복구 확인 | demo.delay-ms=관측 가 능한 지연값(예: 1500ms, 테스트 제안); 원복값=기존 설정. 활성 시설 F-01. | 지연 주입 전 P95·Feign 시간·Trace baseline; 적용 값과 설정 반영 경로 기록; Bus 사용 시 busrefresh; Feign 지연 증가; 타임아웃 발생 시 계약대로 생성 실패; 최종 정합성 및 증빙 확인 | Not Run | — |
| TC-OBS-003 | P0 | k6 100 VU 조회·참가 부하와 정원 무결성 [Performance / Concurrency/ A10] | k6 실행 환경 및 Gateway·Match ·User·DB·Prometheus·Grafana 정상 상태.; 조회용 매치 다수, 참 가용 M-05(RECRUITING, 정원 C=10, OWNER 포함 1명) 및 서로 다른 ACTIVE 회원 100명/토큰 준비. | 사전 상태·시스템 지표와 정원/참가 레코드 기록; k6로 A10 조회 부하(100 VU) 수행; 서로 다른 토큰으로 A14 참가 동시 요청 수행; 결과/복구 확 인 | k6 VUs=100 (구현계획 고 정); M-05 maxParticipant=10, 초기 인원=1; unique test users≥100; 실행 시간은 k6 스크립트 기준 별도 기록 | 초기 인원 1, 매치 RECRUITING 및 baseline 기록; 응답 수· 실패율·P95·CPU·Heap 관측; 성공 201은 남은 정원 이내, 마감 요청은 계약상 거절; 최종 정합성 및 증빙 확인 | Not Run | — |
| TC-OBS-004 | P0 | Kafka Consumer 중단·Lag 증 가·알림 복구 [Kafka / Chaos / Monitoring /A14] | Kafka·Match·User 서비스 정상, notification-service를 안전하게 중지할 수 있음.; 참가 가능한 매치 M-06과 신규 ACTIVE 회원 U-101~U-105, 각 사용자 /OWNER의 알림 사전 건수를 기 록. | 정상 Kafka·알림 상태 및 Lag·알림 건수 기록; notification-service 중단; U-101~U-105가 A14로 M-06에 차례로 참가; 결과/복구 확인 | M-06 maxParticipant 충 분; U-101~U-105 5명 각 각 JOIN; distinct eventId5개 예상, 수신 대상은 참가 자+방장 | baseline Lag·알림 DB 및 Consumer group 확인; 알림 Consumer 중단; Match 서비스는 계속 정상; 각 정상 참가 201, DB 반영, match.joined.v1 발행; 최종 정합성 및 증빙 확인 | Not Run | — |

## 08. 핵심 7종 상세 검증

Saga 3종과 장애·모니터링 4종의 수행 순서, 기대 결과 및 증빙입니다.

### TC-SAGA-001 정상 회원 탈퇴 및 분산 데이터 정리 P0 / Not Run

**사전조건:** U-01은 ACTIVE, 비밀번호를 알고 있으며 유효한 Access/Refresh Token을 보유한다. / U-01이 OWNER인 모집 중 매치 M-01(참가자 있음) 및 PARTICIPANT인 별도 매치 M-02를 준비한다. 진행 중 매치의 OWNER는 아니다.
**테스트 데이터:** U-01: ACTIVE / password=정상값 / M-01: RECRUITING, OWNER / M-02: RECRUITING, PARTICIPANT
**연계 API · 이벤트:** A3 DELETE /user-service/api/users/me · A6 POST /user-service/api/auth/refresh · A28 GET /user-service/api/admin/stats \| user.withdrawal-requested.v1 → match.withdrawal-cleaned.v1; 방장 매치 취소 시 match.status-changed.v1

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | U-01의 유효 토큰으로 탈퇴 API에 비밀번호를 전달 | HTTP 202; status=WITHDRAWING, sagaId 존재 | HTTP JSON / request-id |
| 2 | user_db의 사용자와 withdrawal_saga 및 요청 이벤트를 확인 | WITHDRAWING 기록; 동일 sagaId를 지닌 요청 이벤트 발행 | User DB / Kafka |
| 3 | Match Service가 요청을 소비하도록 하고 M-01과 M-02 정리 | M-01 CANCELLED; M-02에서 U-01 참가 관계정리; 정리 완료 이벤트 | Match DB / 이벤트 |
| 4 | User Service가 cleaned 결과를 처리한 후 최종 상태 확인 | 사용자 WITHDRAWN; Saga 정상 완료 기록 | User DB / Saga 기록 |
| 5 | 기존 Refresh Token으로 토큰 재발급 요청 | HTTP 401 INVALID_REFRESH_TOKEN; 새 토큰 미발급 | HTTP / Redis |
| 6 | 취소 이벤트의 대상 알림·관리자 Saga 통계 확인 | 참가자 취소 알림 생성; succeeded 누적 값 일관성 | 알림 DB / A28 / Grafana |

**최종 판정·원복:** 202 Accepted는 완료가 아니라 접수 응답이다. 최종 상태가 WITHDRAWN인지 비동기로 확인한다. / 방장 M-01은 삭제가 아닌 CANCELLED로 처리한다. 취소된 모임의 기록 보존 정책은 A17 계약과 대조한다.  / 원복:  탈퇴는 비가역적이므로 매번 별도 테스트 회원·매치를 생성한다. 테스트 환경의 격리/데이터 재생성 절차만 사용.

### TC-SAGA-002 진행 중 매치 방장 탈퇴 거절 및 보상 P0 / Not Run

**사전조건:** U-02는 ACTIVE 회원이며 M-03의 OWNER이다. M-03은 IN_PROGRESS 상태로 실제 참가 기록이 존재한다. / User·Match·Notification·Kafka 서비스 정상 실행; M-03 및 관련 참가/대기 레코드를 사전 조회한다.
**테스트 데이터:** U-02 ACTIVE, M-03 IN_PROGRESS, role=OWNER, participantCount=N(사전 기록)
**연계 API · 이벤트:** A3 DELETE /user-service/api/users/me · A25 GET /notification-service/api/notifications/me · A28 GET /user-service/api/admin/stats \| user.withdrawal-requested.v1 → match.withdrawal-rejected.v1 → notification

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | M-03 상태·참가자·방장 ID를 DB 및 API로 저장 | M-03 IN_PROGRESS, U-02 OWNER 기준점 확보 | A11 / Match DB |
| 2 | U-02가 정상 비밀번호로 탈퇴 요청 | HTTP 202; status=WITHDRAWING, sagaId 존재 | A3 / HTTP |
| 3 | Match Service에서 해당 sagaId의 탈퇴 요청 처리 | 진행 중 OWNER 존재로 거절 이벤트 발행 | Kafka / Match 로그 |
| 4 | User Service의 보상 처리와 회원 상태 확인 | WITHDRAWING→ACTIVE, Saga 거절 기록 | User DB / Saga |
| 5 | M-03 및 참가 관계와 취소 이벤트 여부 검증 | 상태·정원·참가·방장 관계 변경 없음; CANCELLED 미전이 | Match DB / Kafka |
| 6 | U-02 알림함과 Saga 통계 확인 | WITHDRAWAL_REJECTED 알림 1건; rejected 값 일관성 | A25 / A28 / Grafana |

**최종 판정·원복:** 최초 202는 탈퇴 성공을 뜻하지 않으며 최종 사용자 상태는 ACTIVE이다. / Match Service는 정리 전에 거절하고 M-03과 관련 참가 내역을 변경하지 않는다.  / 원복:  사전 IN_PROGRESS 매치를 별도 테스트 데이터로 사용하고, 이벤트·알림 기록은 다음 테스트와 격리.

### TC-SAGA-003 Match Service 장애 시 5분 타임아웃 보상 P0 / Not Run

**사전조건:** U-03 ACTIVE; 진행 중 매치 OWNER가 아니고 매치/참가 데이터가 존재하는 테스트 전용 사용자. / User Service·Kafka·DB 정상 상태; Match Service만 안전하게 중단 가능하며 관리자 통계 사전 값 확보.
**테스트 데이터:** U-03 ACTIVE; timeout=5분(계획 기준); Match Service 중단
**연계 API · 이벤트:** A3 DELETE /user-service/api/users/me · A28 GET /user-service/api/admin/stats \| user.withdrawal-requested.v1; 타임아웃 시 cleaned/rejected 응답이 없는 상황

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | Match Service를 중단하고 실제 중단 상태 확인 | Match 요청 Consumer 미동작; User·Kafka는 정상 | Compose / 상태 |
| 2 | U-03 회원 탈퇴 요청 | HTTP 202; WITHDRAWING 및 sagaId 반환 | A3 / HTTP |
| 3 | 요청 이벤트 발행 및 미처리 상태 확인 | WITHDRAWING 유지, cleaned/rejected 결과 미도착 | Kafka / Saga DB |
| 4 | 5분 타임아웃 조건·스케줄러 실행 후 재조회 | 사용자 ACTIVE 복구; Saga timeout 종료 기록 | User DB / Scheduler 로그 |
| 5 | 원본 Match DB와 관리자 Saga 통계 확인 | Match 변경 없음; timedOut 통계 증가/일관성 | Match DB / A28 |
| 6 | Match Service 재기동, 이후 상태·이벤트 추적 | 서비스 정상 복구; 늦은 이벤트 발생 여부 기록 | Compose / Kafka / 로그 |

**최종 판정·원복:** 타임아웃은 5분 기준이며, 테스트상 허용 오차는 스케줄러 실행 주기를 확인해 기록한다. / User WITHDRAWING→ACTIVE 상태 복구와 withdrawal_saga 타임아웃 기록을 확인한다.  / 원복:  Match Service 반드시 재기동; User/Kafka/Match 일관성 확인 후 격리된 테스트 데이터를 재설정.

### TC-OBS-001 Facility Service 중단·CB 차단·복구 P0 / Not Run

**사전조건:** 시설 F-01 active=true, 운영시간 내 신규 매치 요청 데이터 및 기존 매치 M-04(시설 복사본 존재). / Facility·Match·Gateway·Prometheus·Grafana 기동, Feign·Resilience4j 계측 및 경보 규칙 확인.
**테스트 데이터:** F-01=활성 시설, startAt/endAt=운영시간 내; 장애명령: docker compose stop facility-service (서비스명 실제 확인)
**연계 API · 이벤트:** A9 POST /match-service/api/matches · A10 GET /match-service/api/matches · A11 GET /match-service/api/matches/{matchId} · I3 GET /internal/facilities/{id} · A30/A31 \| 필요 시 Alertmanager 운영 장애 알림 (Discord 초안 / Slack 최종 확인)

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | 정상 상태에서 A9 매치 생성 및 A10/A11 조회 | 201 생성, 200 조회, baseline 수집 | HTTP / Grafana |
| 2 | Facility Service 컨테이너 중단 | 시설 서비스 비가용·모니터링 장애 변화 | Compose / target |
| 3 | A9를 정상 데이터로 충분히 반복 호출 | Feign 실패, 생성 거절; DB에 신규 매치 미반영 | HTTP / Match DB |
| 4 | Feign·CB OPEN·운영 알림을 관측 | 실패 지표 증가, CB OPEN(설정된 기준 도달 시), 알림 관측 | Grafana / Alertmanager |
| 5 | 시설 장애 중 기존 M-04의 A10/A11 조회 | 시설 복사본 기반 기존 매치 정보 조회 유지 | A10/A11 / DB |
| 6 | Facility Service 재기동 후 재시도 | 헬스 복귀, CB HALF_OPEN→CLOSED, 신규 생성 성공 | HTTP / Grafana |

**최종 판정·원복:** 장애 중 매치 생성은 거절되며 부분 생성 데이터가 남지 않는다. A9의 503 FACILITY_SERVICE_UNAVAILABLE은 API 명세상 (초안) 코드다. CB OPEN은 임계값과 호출 횟수를 충족한 뒤 검증한다. 1회 실패 직후 OPEN을 가정하지 않는다. / 원복: docker compose start facility-service; CB 정상화 확인, 생성 성공으로 테스트 종료. 실패한 생성 데이터가 없음을 확인.

### TC-OBS-002 Facility Service 응답 지연·추적·복구 P0 / Not Run

**사전조건:** Facility Service 정상 기동, 메트릭·Zipkin trace 수집 가능. / config-repo의 demo.delay-ms 및 busrefresh 기능 구현 여부를 먼저 확인한다. Cloud Bus는 P1 선택 범위.
**테스트 데이터:** demo.delay-ms=관측 가능한 지연값(예: 1500ms, 테스트 제안); 원복값=기존 설정. 활성 시설 F-01.
**연계 API · 이벤트:** A9 POST /match-service/api/matches · I3 GET /internal/facilities/{id} · A30/A31 \| Alertmanager 응답 지연 경보; Config Bus(선택 P1) 경로는 구현된 경우에만

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | 정상 상태에서 A9 요청 여러 건의 지표·Trace 확보 | 지연 주입 전 P95·Feign 시간·Trace baseline | Grafana / Zipkin |
| 2 | Facility 응답에 demo.delay-ms 지연 설정 및 반영 | 적용 값과 설정 반영 경로 기록; Bus 사용 시 busrefresh | Config / 서비스 로그 |
| 3 | A9 요청을 반복하여 호출 경로에 지연 발생 | Feign 지연 증가; 타임아웃 발생 시 계약대로 생성 실패 | HTTP / Feign 지표 |
| 4 | Prometheus/Grafana의 P95·CB·알림 확인 | P95 상승, CB 상태 변화 관측; 경보 임계값 충족 시 알림 | Grafana / Alertmanager |
| 5 | Zipkin에서 Match→Facility Trace 분석 | 지연 Span이 Facility 호출 구간에 대응 | Zipkin Trace ID |
| 6 | 지연값 원복 후 재호출 | 지연 회복·정상 생성, CB CLOSED 등 안정화 확인 | HTTP / Grafana |

**최종 판정·원복:** 장애 대상은 User Service가 아니라 Facility Service다(구현계획 기준). / Bus 기반 설정 변경은 P1이다. 미구현 시 해당 단계를 Blocked로 기록하고, 대체 지연 주입을 썼다면 방식과 범위를 분리해 적는다.  / 원복:  demo.delay-ms를 원래 값으로 복구, 필요 시 구성 재반영/서비스 재시작. 테스트 종료 후 지연 미발생 확인.

### TC-OBS-003 k6 100 VU 조회·참가 부하와 정원 무결성 P0 / Not Run

**사전조건:** k6 실행 환경 및 Gateway·Match·User·DB·Prometheus·Grafana 정상 상태. / 조회용 매치 다수, 참가용 M-05(RECRUITING, 정원 C=10, OWNER 포함 1명) 및 서로 다른 ACTIVE 회원 100명/토큰 준비.
**테스트 데이터:** k6 VUs=100 (구현계획 고정); M-05 maxParticipant=10, 초기 인원=1; unique test users≥100; 실행 시간은 k6 스크립트 기준 별도 기록
**연계 API · 이벤트:** A10 GET /match-service/api/matches · A14 POST /match-service/api/matches/{matchId}/participants · A11 · A30/A31 \| match.joined.v1; 모집 마감 시 match.status-changed.v1

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | 사전 상태·시스템 지표와 정원/참가 레코드 기록 | 초기 인원 1, 매치 RECRUITING 및 baseline 기록 | DB / Grafana |
| 2 | k6로 A10 조회 부하(100 VU) 수행 | 응답 수·실패율·P95·CPU·Heap 관측 | k6 / Grafana |
| 3 | 서로 다른 토큰으로 A14 참가 동시 요청 수행 | 성공 201은 남은 정원 이내, 마감 요청은 계약상 거절 | k6 / HTTP |
| 4 | DB에서 현재 인원·유니크 참가자 검증 | numCurrentParticipant≤10, 중복/초과 참가 0건 | match_db / SQL |
| 5 | Kafka 및 서비스 지표를 함께 확인 | 정상 가입 이벤트 발생, 5xx·지연·리소스 사용량 관측 | Kafka / Grafana |
| 6 | 부하 종료 후 정상 요청·성능 복구 확인 | 서비스 지속 가용, 부하 종료 후 지표 안정화 | HTTP / k6 / Grafana |

**최종 판정·원복:** 100 VU는 동시 가상 사용자 수다. 단일 JWT 반복은 참가 경쟁 검증을 대신하지 않으므로 서로 다른 계정을 사용한다. / 정원 10명(OWNER 포함 초기 1명)이면 새 참가 성공은 최대 9명, 최종 인원 ≤10명이다.  / 원복:  테스트 전용 참가/매치/알림 데이터 재설정; 부하 종료 후 정상 트랜잭션 재확인.

### TC-OBS-004 Kafka Consumer 중단·Lag 증가·알림 복구 P0 / Not Run

**사전조건:** Kafka·Match·User 서비스 정상, notification-service를 안전하게 중지할 수 있음. / 참가 가능한 매치 M-06과 신규 ACTIVE 회원 U-101~U-105, 각 사용자/OWNER의 알림 사전 건수를 기록.
**테스트 데이터:** M-06 maxParticipant 충분; U-101~U-105 5명 각각 JOIN; distinct eventId 5개 예상, 수신 대상은 참가자+방장
**연계 API · 이벤트:** A14 POST /match-service/api/matches/{matchId}/participants · A25 GET /notification-service/api/notifications/me · A27 GET /notification-service/api/notifications/me/unread-count \| match.joined.v1 → notification 소비; 필요 시 match.status-changed.v1

| 단계 | 수행 절차 | 기대 결과 | 증빙 |
| --- | --- | --- | --- |
| 1 | 정상 Kafka·알림 상태 및 Lag·알림 건수 기록 | baseline Lag·알림 DB 및 Consumer group 확인 | Grafana / Kafka / DB |
| 2 | notification-service 중단 | 알림 Consumer 중단; Match 서비스는 계속 정상 | Compose / 상태 |
| 3 | U-101~U-105가 A14로 M-06에 차례로 참가 | 각 정상 참가 201, DB 반영, match.joined.v1 발행 | HTTP / Match DB / Kafka |
| 4 | Consumer Lag 변화를 확인 | 미소비 이벤트 누적으로 Lag 증가(외부 지표 소스) | Kafka exporter / broker |
| 5 | notification-service 재기동 및 이벤트 처리 확인 | Lag가 최종 0으로 수렴; 해당 참가자·방장 알림 생성 | Kafka / A25 / A27 |
| 6 | 동일 이벤트 재전달 또는 재처리 검증 | 같은 eventId 재처리로 중복 알림이 늘어나지 않음 | 알림 DB / 처리 로그 |
| 7 | 서비스 정상 상태와 장애·복구 시계열 보존 | 알림 누락·중복 없음, 재기동 후 헬스 정상 | Grafana / 스크린샷 |

**최종 판정·원복:** 알림 장애가 매치 참가 핵심 트랜잭션을 중단시키지 않아야 한다. / Lag는 중단된 notification-service의 자체 actuator만으로는 관측이 어려울 수 있어 Kafka exporter/브로커 기반 수집이 필요하다.  / 원복:  notification-service 재기동·Lag 수렴 확인, 시험 알림과 참가 레코드 격리 및 테스트 계정 정리.

## 09. 테스트 실행 및 결함 기록

| 항목 | 기록 규칙 | 증빙 / 후속 처리 |
| --- | --- | --- |
| Pass | 실제 실행 + HTTP / DB / Kafka / 지표 조건 검증 후 | 테스트 일시, 담당자, 응답·캡처 링크 |
| Fail | 기대 결과와 실제 결과가 다를 때 | 재현 절차·DB 전후·로그·GitHub Issue |
| Blocked | 미구현·인프라 장애·계약 미확정으로 실행 불가 | 차단 사유/선행 이슈 및 재시험 날짜 |
| Not Run | 아직 실행하지 않았거나 실행 기록 부족 | 일반 테스트 전부 기본값 |

### 구현·계약 확인 목록

- R7 DDL의 `matches.url` 및 `match_waitlist` 반영 여부 (2026-10-31 회의 검토 중).
- Saga 타임아웃 보상 뒤 늦게 도착한 CLEANED 결과의 최종 처리 정책 (미확정).
- A9/A12/A14/A17의 (초안) 에러 코드 최종 확정 및 구현 반영 여부.
- Alertmanager 경보 임계값·Slack/Discord 채널, Prometheus Target 사라짐 처리.
- Spring Cloud Bus는 P1. 미구현이면 TC-OBS-002의 busrefresh는 별도 Blocked로 기록.
- 35개 API의 실제 구현 상태를 확인하여 P1/P2·관리자·미구현 기능은 Fail로 오인하지 말 것.
- DB별 접근 권한과 서비스 간 직접 FK 부재는 스키마/설정으로 검증.

참고 문서: ① Sporty_v2 API 명세서 v1.0 (A1~A31/I1~I4) ② MSA 구현계획 v2 ③ 2조 1차 테스트 케이스 PDF ④ 2026-10-31 팀 회의록.

> 모든 케이스의 초기 상태는 Not Run입니다. 미실행은 Pass로 기록하지 않습니다.
