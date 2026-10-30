# Sporty v2 API 및 Kafka 계약 초안

> 출처: `Sporty_MSA_2조_API_명세서(1).xlsx` · v0.1 · 팀 합의 전 설계 초안. 1차 코드 정적 확인은 2차 구현·실행 검증을 뜻하지 않습니다.
> **최신 결정:** [고도화 범위와 문서 차이](../decisions/2026-10-30-scope-update.md)를 먼저 확인하세요. 이 변환본은 원본 보존을 위해 4개 서비스와 기존 이벤트 설계를 그대로 담습니다.


## API 목록

외부 공개 경로는 1차 Controller 기준 보존. 내부 /internal 경로는 Gateway에 노출하지 않음.

| API ID | 요구사항 | 서비스 | Method | 경로 | 인증 | 기능 | 요청 스키마/쿼리 | 응답 | 성공 HTTP | 오류 HTTP | 계약 단계 | 구현 상태 | 검증 TC | 근거 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| API-01 | USR-01 | identity-service | POST | /api/users | 공개 | 회원가입 | UserSignUpRequestDto: email,password,gender,nickname,district,sportTypes | 빈 본문 | 201 | 400,409 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-02 | USR-02 | identity-service | POST | /api/auth/login | 공개 | 로그인 | {email,password} | {userId,accessToken,refreshToken,tokenType,expiresIn} | 200 | 400,401 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-03 | USR-03 | identity-service | POST | /api/auth/logout | Bearer | 로그아웃 | Bearer Access Token | 없음 | 204 | 401 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-04 | USR-04 | identity-service | DELETE | /api/users/me | Bearer | 회원탈퇴 | {password} | 없음 | 204 | 400,401 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-05 | USR-05 | identity-service | POST | /api/auth/refresh | 공개 | 토큰 재발급 | {refreshToken} | {accessToken,...} (기존 DTO 확인) | 200 | 401 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-06 | USR-06 | identity-service | GET | /api/users/me | Bearer | 내 정보 | Header Authorization | UserInfoResponseDto | 200 | 401,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-07 | PR-01 | identity-service | PUT | /api/profiles/me | Bearer | 프로필 수정 | {nickname,district,sportTypes} | ProfileUpdateResponseDto | 200 | 400,401,409 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-08 | PR-02 | identity-service | GET | /api/profiles/{profileId} | Bearer (현재 SecurityConfig) | 프로필 상세 | profileId:Long | ProfileDetailResponseDto | 200 | 404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-09 | EM-01 | match-service | POST | /api/matches | Bearer | 매치 생성 | {serviceId,title,description,startAt,endAt,maxParticipant,skillLevel,sportType,genderGroup} | matchId:Long | 201 | 400,401,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-10 | EM-02 | match-service | GET | /api/matches | 공개 | 매치 검색 | Query: serviceId,titleKeyword,descriptionKeyword,startAt,endAt,maxParticipant,skillLevel,sportType,genderGroup,region,status,isFree | List<MatchResponseDto> | 200 | 400 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-11 | EM-03 | match-service | GET | /api/matches/{matchId} | 공개(선택 Bearer) | 매치 상세 | matchId:Long | MatchDetailResponseDto | 200 | 404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-12 | EM-04 | match-service | PUT | /api/matches/{matchId} | Bearer+OWNER | 매치 수정 | {title,description,startAt,endAt,maxParticipant,skillLevel,genderGroup} | MatchDetailResponseDto | 200 | 400,401,403,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-13 | EM-05 | match-service | DELETE | /api/matches/{matchId} | Bearer+OWNER | 매치 삭제 | matchId:Long | 없음 | 204 | 401,403,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-14 | EM-06 | match-service | POST | /api/matches/{matchId}/participants | Bearer | 매치 참여 | matchId:Long | {matchParticipantId,matchId,userId,role} | 201 | 400,401,404,409 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-15 | EM-07 | match-service | DELETE | /api/matches/{matchId}/participants/me | Bearer+PARTICIPANT | 매치 탈퇴 | matchId:Long | 없음 | 204 | 401,403,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-16 | EM-08 | match-service | GET | /api/matches/me | Bearer | 내 매치 목록 | Header Authorization | List<MyMatchResponseDto> | 200 | 401 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-17 | AI-01 | ai-service | POST | /api/ai/matches | Bearer | AI 매치 생성 초안 | {prompt} | {initialValues:{...}}; DB 저장 없음 | 200 | 400,401,502/503(제안) | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-18 | AI-02 | ai-service | POST | /api/ai/matches/search | 공개 | AI 매치 검색 | {prompt} | {conditions,criteria,matches} | 200 | 400,502/503(제안) | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-19 | AI-03 | ai-service | GET | /api/ai/matches/recommendations | Bearer | 맞춤 매치 추천 | Header Authorization | List<MatchResponseDto> (최대 3) | 200 | 401,503 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-20 | FC-01 | facility-service | GET | /api/services | 공개 | 체육시설 목록 | Query: region,serviceName,serviceType,status,startTime,endTime | List<ServiceResponseDto> | 200 | 400 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-21 | FC-02 | facility-service | GET | /api/services/{serviceId} | 공개 | 체육시설 상세 | serviceId:Long (DB PK) | ServiceDetailResponseDto | 200 | 400,404 | 기존 경로 유지 | 기존 1차 코드 확인 · 2차 분리 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | https://github.com/livelykitten/inspire_6th_mini_1_sporty |
| API-I01 | MSA-05 | facility-service | GET | /internal/services/{serviceId}/validation | 서비스 간 인증 | 매치 생성 전 시설 검증 | serviceId:Long | {serviceId,active,name,region,isFree} | 200 | 404,503 | 2차 신규 내부 API | 2차 신규 설계 · 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | 2차 설계안 |
| API-I02 | MSA-05 | identity-service | GET | /internal/users/{userId}/recommendation-profile | 서비스 간 인증 | 추천용 최소 프로필 조회 | userId:Long | {userId,active,gender,district,sportTypes} | 200 | 404,503 | 2차 신규 내부 API | 2차 신규 설계 · 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | 2차 설계안 |
| API-I03 | MSA-05 | match-service | GET | /internal/matches | 서비스 간 인증 | AI 검색 후보 조회 | Query: 기존 검색 조건 일부 | List<MatchResponseDto> | 200 | 400,503 | 2차 신규 내부 API | 2차 신규 설계 · 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | 2차 설계안 |
| API-O01 | MSA-10 | 공통 | GET | /actuator/health | 운영 정책에 따름 | Health/Readiness | 없음 | {status,...} | 200/503 | - | 2차 신규 운영 API | 2차 신규 설계 · 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | 2차 설계안 |
| API-O02 | MSA-10 | 공통 | GET | /actuator/prometheus | 내부망 한정 | Prometheus 메트릭 | 없음 | text/plain 메트릭 | 200 | 403 | 2차 신규 운영 API | 2차 신규 설계 · 미구현 | 테스트 매트릭스에서 요구 ID로 추적 | 2차 설계안 |


## DTO 필드

실제 1차 DTO 필드명은 코드 기준. 새로운 이벤트 Envelope는 2차 계약안으로 확정 전 검토 필요.

| API/이벤트 ID | DTO | JSON/쿼리 필드 | 타입 | 필수 | Enum/형식 | 검증·설명 | 출처 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| API-01 | UserSignUpRequestDto | email | String | Y |  | 이메일 형식 | 1차 코드 기준 |
| API-01 | UserSignUpRequestDto | password | String | Y |  | 8~20자 | 1차 코드 기준 |
| API-01 | UserSignUpRequestDto | gender | Gender | Y |  | MALE/FEMALE | 1차 코드 기준 |
| API-01 | UserSignUpRequestDto | nickname | String | Y |  | ≤50자 | 1차 코드 기준 |
| API-01 | UserSignUpRequestDto | district | District | Y |  | 서울 25개 자치구 enum | 1차 코드 기준 |
| API-01 | UserSignUpRequestDto | sportTypes | List<SportType> | Y |  | 비어 있어도 [] 입력, null 불가 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | serviceId | Long | Y | Facility DB PK | Facility DB PK | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | title | String | Y | ≤50 | ≤50 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | description | String | N | ≤500 | ≤500 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | startAt | LocalDateTime | Y | ISO8601 | ISO8601 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | endAt | LocalDateTime | Y | 시작보다 미래 | 시작보다 미래 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | maxParticipant | Integer | Y | ≥1 | ≥1 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | skillLevel | SkillLevel | Y | BEGINNER/INTERMEDIATE/ADVANCED | BEGINNER/INTERMEDIATE/ADVANCED | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | sportType | SportType | Y | 10개 종목 | 10개 종목 | 1차 코드 기준 |
| API-09 | MatchCreateRequestDto | genderGroup | GenderGroup | Y | MALE/FEMALE/MIXED | MALE/FEMALE/MIXED | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | serviceId | Long | N | 시설 PK | 시설 PK | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | titleKeyword | String | N | ≤50 | ≤50 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | descriptionKeyword | String | N | ≤500 | ≤500 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | startAt | LocalDateTime | N | ISO8601 | ISO8601 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | endAt | LocalDateTime | N | ISO8601 | ISO8601 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | maxParticipant | Integer | N | 양수 | 양수 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | skillLevel | SkillLevel | N | 세 단계 | 세 단계 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | sportType | SportType | N | 10개 종목 | 10개 종목 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | genderGroup | GenderGroup | N | MALE/FEMALE/MIXED | MALE/FEMALE/MIXED | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | region | String | N | 자치구 | 자치구 | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | status | MatchStatus | N | RECRUITING/CLOSED | RECRUITING/CLOSED | 1차 코드 기준 |
| API-10 | MatchSearchRequestDto | isFree | Boolean | N | true/false | true/false | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | matchId | Long | Y | PK | PK | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | title | String | Y | 매치명 | 매치명 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | startAt | LocalDateTime | Y | 시간 | 시간 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | endAt | LocalDateTime | Y | 시간 | 시간 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | currentParticipantCount | Integer | Y | 현재 인원 | 현재 인원 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | maxParticipant | Integer | Y | 정원 | 정원 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | status | MatchStatus | Y | 상태 | 상태 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | sportType | SportType | Y | 종목 | 종목 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | serviceId | Long | Y | 시설 PK | 시설 PK | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | serviceName | String | N | 시설 스냅샷 | 시설 스냅샷 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | region | String | N | 자치구 | 자치구 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | participants | List | Y | 개설자 및 참가자 | 개설자 및 참가자 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | isOwner | Boolean | Y | 로그인 기준 | 로그인 기준 | 1차 코드 기준 |
| API-11 | MatchDetailResponseDto | isParticipant | Boolean | Y | 로그인 기준 | 로그인 기준 | 1차 코드 기준 |
| API-17 | AiRequestDto | prompt | String | Y |  | 공백 입력 금지, 최대 500자 | 1차 코드 기준 |
| API-18 | AiRequestDto | prompt | String | Y |  | 공백 입력 금지, 최대 500자 | 1차 코드 기준 |
| API-18 | AiSearchResponseDto | conditions | List<AiConditionDto> | Y |  | 추출 조건 요약 | 1차 코드 기준 |
| API-18 | AiSearchResponseDto | criteria | AiSearchConditionDto | Y |  | 수정 가능한 검색 조건 | 1차 코드 기준 |
| API-18 | AiSearchResponseDto | matches | List<MatchResponseDto> | Y |  | 빈 배열 허용 | 1차 코드 기준 |
| API-20 | ServiceRequestDto | region | String | N |  | 자치구 | 1차 코드 기준 |
| API-20 | ServiceRequestDto | serviceName | String | N |  | 시설명 | 1차 코드 기준 |
| API-20 | ServiceRequestDto | serviceType | String | N |  | 시설/종목 구분 | 1차 코드 기준 |
| API-20 | ServiceRequestDto | status | String | N |  | 원본 예약 상태 | 1차 코드 기준 |
| API-20 | ServiceRequestDto | startTime | LocalTime | N |  | HH:mm | 1차 코드 기준 |
| API-20 | ServiceRequestDto | endTime | LocalTime | N |  | HH:mm | 1차 코드 기준 |
| EVT-01~04 | KafkaEnvelopeV1 | eventId | UUID | Y |  | 중복 처리 키 | 2차 신규 제안 |
| EVT-01~04 | KafkaEnvelopeV1 | eventType | String | Y |  | Event 목록 참조 | 2차 신규 제안 |
| EVT-01~04 | KafkaEnvelopeV1 | aggregateId | Long | Y |  | matchId | 2차 신규 제안 |
| EVT-01~04 | KafkaEnvelopeV1 | aggregateVersion | Long | Y |  | 순서 제어 | 2차 신규 제안 |
| EVT-01~04 | KafkaEnvelopeV1 | occurredAt | Instant | Y |  | UTC ISO-8601 | 2차 신규 제안 |
| EVT-01~04 | KafkaEnvelopeV1 | payload | Object | Y |  | 스냅샷 도메인 | 2차 신규 제안 |


## 예시 요청응답

JSON 예시는 개발 계약 논의용; 생략 기호(...)는 완전한 실행 JSON이 아니므로 DTO 표로 보완.

| 시나리오 | Method | URL/Topic | 요청 예시 | 응답 예시 | 주의·검증 | 참조 ID |
| --- | --- | --- | --- | --- | --- | --- |
| 매치 생성 | POST | /api/matches | {"serviceId":78,"title":"주말 풋살","description":"초급 환영","startAt":"2026-11-03T19:00:00","endAt":"2026-11-03T21:00:00","maxParticipant":10,"skillLevel":"BEGINNER","sportType":"FUTSAL","genderGroup":"MIXED"} | 201: 123 | 원본 Controller는 Long matchId를 응답. 실제 DB PK는 시설 service.id | API-09 |
| 매치 검색 | GET | /api/matches?sportType=FUTSAL&region=강남구&status=RECRUITING | Query only | 200: [{"matchId":123,"title":"주말 풋살","sportType":"FUTSAL","status":"RECRUITING",...}] | 본문 필드는 MatchResponseDto 참조. ...은 설명용 생략 표시 | API-10 |
| AI 생성 초안 | POST | /api/ai/matches | {"prompt":"이번 주 토요일 송파에서 초급 풋살 10명 모집"} | 200: {"initialValues":{...}} | 초안만 반환. POST /api/matches 별도 호출 전에 DB 저장 금지 | API-17 |
| AI 자연어 검색 | POST | /api/ai/matches/search | {"prompt":"이번 주말 강남에서 풋살 초보 매치 찾아줘"} | 200: {"conditions":[...],"criteria":{...},"matches":[]} | 조건 요약 + 사용자 수정 + 빈 배열 허용 | API-18 |
| 시설 상세 | GET | /api/services/78 | 없음 | 200: {"id":78,"serviceId":"SVCID-EXAMPLE","serviceName":"구립 체육관", "region":"강남구",...} | id=내부 DB PK(Long); serviceId=외부 원본 문자열 | API-21 |
| Feign 시설 검증 | GET | /internal/services/78/validation | 서비스간 인증 헤더 | 200: {"serviceId":78,"active":true,"name":"구립 체육관","region":"강남구","isFree":true} | 외부 Gateway에서 직접 호출 불가. 2차 새 설계 | API-I01 |
| Kafka 생성 이벤트 | Kafka | sporty.match.events.v1 | {"eventId":"8f62247a-XXXX","eventType":"MatchCreated","aggregateId":123,"aggregateVersion":1,"occurredAt":"2026-11-03T10:00:00Z","payload":{"matchId":123,"sportType":"FUTSAL","status":"RECRUITING"}} | Consumer: match_projection UPSERT + processed_event INSERT | eventId 필수; 재수신 동일 결과, 순서 뒤바뀜 무시. Envelope는 합의 전 초안 | EVT-01 |


## Kafka 이벤트

이벤트는 최소 하나의 비동기 데이터 동기화를 필수 시연하며, Consumer 멱등성·재처리 증빙을 확보합니다.

| 이벤트 ID | 이벤트 명 | Topic | Producer | Consumer | 메시지 Key | 발행 조건 | Payload 필드 | 중복/순서 처리 | 실패 처리 | 요구사항 | 상태 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EVT-01 | MatchCreated | sporty.match.events.v1 | match-service | ai-service | matchId | 매치+OWNER 커밋 후 | matchId,serviceId,sportType,region,genderGroup,status,startAt,endAt,maxParticipant,currentParticipantCount | eventId UNIQUE; matchId upsert; version 비교 | 실패 시 재시도; DLQ는 후속 범위 | MSA-06 | 신규 설계 · 미구현 |
| EVT-02 | MatchParticipantJoined | sporty.match.events.v1 | match-service | ai-service | matchId | 일반 참가자 등록 후 | matchId,currentParticipantCount,status | eventId UNIQUE; 최신 aggregateVersion만 적용 | 중복 수신 무시 | MSA-06 | 신규 설계 · 미구현 |
| EVT-03 | MatchParticipantLeft | sporty.match.events.v1 | match-service | ai-service | matchId | 탈퇴 후 | matchId,currentParticipantCount,status | eventId UNIQUE | 실패 재시도 | MSA-06 | 신규 설계 · 미구현 |
| EVT-04 | MatchDeleted | sporty.match.events.v1 | match-service | ai-service | matchId | 매치 삭제 후 | matchId,deletedAt | 중복 삭제 무해 | 실패 재시도 | MSA-06 | 신규 설계 · 미구현 |
| EVT-05 | UserWithdrawn | sporty.identity.events.v1 | identity-service | match-service | userId | 계정 WITHDRAWN 트랜잭션 완료 후 | userId,withdrawnAt | eventId UNIQUE, 취소/탈퇴 반복 안전 | 지연 시 eventual consistency; P1 범위 | USR-04 | 신규 설계 · 미구현 |


## 라우팅 인증

Gateway 단일 진입점 + downstream JWT 검증/내부 API 분리. 헤더 X-User-Id를 클라이언트로부터 신뢰하지 않음.

| 경로 | 라우팅 대상 | 노출 | 목적 | 보안 메모 |
| --- | --- | --- | --- | --- |
| /api/users/** | identity-service | Gateway | JWT 사용자 엔드포인트 | 인증 경로 제외 일부 공개 |
| /api/auth/** | identity-service | Gateway | 로그인/로그아웃/재발급 | 로그아웃 Bearer 필요 |
| /api/profiles/** | identity-service | Gateway | 프로필 수정·조회 | 현 SecurityConfig는 상세도 인증 필요 |
| /api/services/** | facility-service | Gateway | 시설 목록/상세 공개 | 외부 API의 원본 예약 데이터 수집은 별도 |
| /api/matches/** | match-service | Gateway | 매치 목록 공개, 변경 작업 인증 | /api/matches/me 는 공개 상세 라우팅 예외 |
| /api/ai/** | ai-service | Gateway | AI search는 공개, draft/recommend 로그인 | 요청 body/토큰 불필요 정보 로깅 금지 |
| /internal/** | 각 소유 서비스 | 비공개 | Feign 내부 API | Gateway 차단, 서비스 인증/내부망 한정 |
| /actuator/prometheus | 각 앱 | 운영망 | 메트릭 | 공개 Gateway 외부 노출 금지 |


## 오류 정책

1차 실제 컨트롤러에는 Map 검증 오류와 ErrorResponse 혼재. 2차 공통 스키마 적용은 FE 영향 검토 필요.

| HTTP | 대표 코드 | 발생 조건 | 보완 원칙 |
| --- | --- | --- | --- |
| 400 | INVALID_INPUT | 필수값, Enum, 날짜/시간, 최대 길이, AI 무효 prompt | 기존 예외 형식의 스키마는 서비스별 확인; FE 호환 우선 |
| 401 | UNAUTHORIZED | Bearer 없음/만료/Refresh 불일치 | 외부 인증 실패로 404 처리하지 않음 |
| 403 | FORBIDDEN | 다른 사용자 매치 수정/삭제; internal API 직접 접근 | 200으로 둔갑하지 않음 |
| 404 | NOT_FOUND | 매치/시설/프로필 없음 | Feign 실패 503과 구분 |
| 409 | CONFLICT | 이메일·닉네임·매치 중복 참가 | DB UNIQUE 위반도 제어 |
| 503 | UPSTREAM_UNAVAILABLE (제안) | 타 서비스 timeout / Circuit Breaker | 2차 오류 표준화 승인 전 제안 |
| 500 | INTERNAL_ERROR | 예상하지 못한 애플리케이션 오류 | 비밀값/스택 트레이스 사용자 노출 금지 |


## 차이 결정

일부 1차 산출물의 경로와 API 예시가 실제 코드와 달라 최신 코드를 우선합니다.

| 결정 ID | 주제 | 원본 차이 | 근거 | 대응 | 상태 |
| --- | --- | --- | --- | --- | --- |
| D-01 | 매치 목록 API | 1차 테스트 일부 /api/matches/search 표기 vs 코드 /api/matches | GitHub MatchController @GetMapping + 1차 요구사항 API 표 | 공개 API는 GET /api/matches 유지; /search 별도 추가하지 않음 | 확정 제안 |
| D-02 | PK 데이터 타입 | ERD 이미지 일부 INT vs 9/29 테이블 명세와 Entity Long/BIGINT | 테이블 명세(9/29), JPA Entity | BIGINT 기준. 원본 ERD는 설명용으로만 사용 | 확정 제안 |
| D-03 | 시설 예약 | 시설 예약 서비스 목록·외부 URL 제공 vs 실제 예약 처리 | 1차 발표자료·API·ServiceEntity | 직접 예약/결제 기능은 범위 밖. 외부 예약 링크 제공 | 확인 |
| D-04 | DB 분리 | 1차 단일 DB의 JPA FK가 서비스 경계 간 연결 | MatchEntity/MatchParticipantEntity | match.service_id,participant.user_id는 타 DB ID 참조만; cross-DB FK 금지 | 2차 제안 |
| D-05 | 정원/상태 | 원본 RECRUITING/CLOSED, 개설자 OWNER 자동 참가 | 테이블 명세·MatchService | 회원 이탈/정원 변경/동시 참여 시 원자 처리 유지 | 2차 제안 |
| D-06 | 차별화 기술 | 2차 10번 기술은 조별 1개 채택 | 2차 공식 안내 PDF 8p | 모니터링(Micrometer/Prometheus/Grafana) 우선 제안; 팀 확정 필요 | 승인 필요 |
| D-07 | 버전 호환성 | 1차 Spring Boot 3.5.4 | build.gradle + Spring Cloud 호환성 표 | Spring Cloud 2025.0.x 계열 BOM 사용, 부트 3.5.x 버전 조합 실제 빌드 검증 | 확인 필요 |
| D-08 | 데이터 샘플 | 공공 API 접근·키·원본 데이터는 환경 의존 | 1차 요구/시연 | 기존 DB 시드 및 Mock으로 필수 E2E 재현; 실제 API 키는 팀 준비 | 확인 필요 |
| D-09 | API 오류 형식 | 1차 컨트롤러마다 검증 오류 DTO 형태가 일부 다름 | MatchController, ErrorResponse | 2차 Gateway 전면 오류 표준화는 선택적; 기존 FE 호환 우선 | 승인 필요 |
| D-10 | 테스트 상태 | 1차 테스트 케이스 표에 Pass 기재 | 1차 테스트 문서 | 2차 신규 테스트는 전부 Not Run; 실제 재실행 후만 Pass | 확정 |


## 근거 및 용어

검증 기준: 1차 코드 정적 확인과 2차 신규 설계를 구분. 진행 완료 여부는 실제 실행 증빙으로 갱신.

| 자료 | 경로·URL | 활용·주의 | 기준일 |
| --- | --- | --- | --- |
| 1차 프로젝트 계획 | 2조_프로젝트_수행계획서.pdf | 원본 팀/주제/목표/제외범위 | 2026-09-16 |
| 1차 요구사항 | 2조_요구사항_명세서(1).pdf | USR/PR/EM/AI/FC 기능과 API 요구 | 2026-09-29 |
| 1차 DB 명세 | 2조_테이블_명세서.xlsx | 기존 7개 엔티티/컬럼(최신) | 2026-09-29 |
| 1차 ERD 이미지 | 2조_ERD.png | 참고 이미지, 일부 ID INT 표기 | 1차 |
| 1차 테스트 케이스 | 2조_테스트_케이스.pdf | 1차 TC; 2차 재실행 아님 | 1차 |
| 1차 발표자료 | 2조_발표자료.pptx | 1차 성과/기능/시스템 구조 | 2026-09-30 |
| 1차 화면설계 | 2조_화면설계도(1).pdf | 12페이지 UI 플로우/라우트 | 1차 |
| 1차 WBS | 2조_WBS.xlsm | 과거 41개 완료 업무, 2차 WBS와 별개 | 1차 |
| GitHub main | https://github.com/livelykitten/inspire_6th_mini_1_sporty/tree/main | 정적 코드 확인(실행 X), SHA 02533ba6ca253e2cbb6beb75c2f78fdf68a7ba8c | 2026-10-30 |
| 2차 공식 안내 | [CNS 6기]_미니PJT2 수강생 안내.pdf | MSA 필수 1~10 및 평가 기준 | 2026-10-30 |
| Spring Cloud 호환표 | https://spring.io/projects/spring-cloud/ | Boot 3.5.x ↔ Cloud 2025.0.x | 2026-10-30 확인 |
