# Sporty v2 테스트 케이스

> 출처: `Sporty_MSA_2조_테스트_케이스(1).xlsx` · v0.1 · 팀 합의 전 설계 초안. 1차 코드 정적 확인은 2차 구현·실행 검증을 뜻하지 않습니다.
> **최신 결정:** [고도화 범위와 문서 차이](../decisions/2026-10-30-scope-update.md)를 먼저 확인하세요. 이 변환본은 원본 보존을 위해 4개 서비스와 기존 이벤트 설계를 그대로 담습니다.

> 실행 결과는 모두 원본의 `Not Run` 상태입니다. 새 고도화 기능의 테스트는 아직 이 표에 없습니다.


## 테스트 매트릭스

1차 문서의 Pass는 승계하지 않습니다. 실제 재실행 후 상태( Not Run / Pass / Fail / Blocked )와 증빙을 기록하세요.

| TC ID | 요구 ID | 우선 | 유형 | 담당 서비스 | 시나리오 | 사전조건 | 테스트 절차 | 입력/데이터 | 예상 결과 (HTTP/DB/이벤트) | 단계 | 실행 상태 | 실행 일시 | 실제 결과 | 결함 ID/URL | 증빙 링크 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-USR-01 | USR-01 | P0 | 정상 | identity-service | 정상 회원가입 | 미가입 이메일 | POST /api/users; DB 확인 | email unique, sportTypes=[FUTSAL] | 201; user+profile+sport_preference 생성 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-02 | USR-01 | P1 | 예외 | identity-service | 중복 이메일/닉네임 차단 | 기존 회원 존재 | 중복 회원가입 요청 | email 또는 nickname 중복 | 409; 기존 레코드 미변경 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-03 | USR-02 | P0 | 정상 | identity-service | JWT 로그인 | ACTIVE 회원 | POST /api/auth/login | 올바른 email,password | 200 + Access/Refresh; Redis TTL | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-04 | USR-02 | P1 | 보안 | identity-service | 틀린 비밀번호 로그인 거부 | ACTIVE 회원 | 잘못된 비밀번호 | password=invalid | 401; 토큰 발급 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-05 | USR-03 | P0 | 정상 | identity-service | 로그아웃 토큰 폐기 | 로그인 완료 | POST /api/auth/logout; 토큰 재발급 시도 | Bearer 유효 | 204; Refresh 폐기 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-06 | USR-04 | P0 | 보안 | identity-service | 회원탈퇴 상태 변경 | 로그인·올바른 암호 | DELETE /api/users/me; DB 확인 | {password} | 204; WITHDRAWN·withdrawn_at; 다시 로그인 불가 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-07 | USR-05 | P0 | 보안 | identity-service | Refresh 갱신/만료 | Refresh 존재 | POST /api/auth/refresh | 유효/만료 토큰 | 200/401 분리; 만료된 토큰 발급 안됨 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-08 | USR-06 | P0 | 보안 | identity-service | 내 정보와 개인정보 경계 | ACTIVE 회원 | GET /api/users/me | Bearer 유효/없음 | 200/401; 비밀번호·민감정보 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-PR-01 | PR-01 | P1 | 정상 | identity-service | 프로필 수정/중복 | 로그인 | PUT /api/profiles/me | nickname,district,sportTypes | 200; DB 반영; 중복 닉네임 409 | 2차 재검증 | Not Run |  |  |  |  |
| TC-PR-02 | PR-02 | P1 | 보안 | identity-service | 프로필 공개 범위 | 프로필 1개 | GET /api/profiles/{profileId} | 존재/없는 ID | 200/404; email/password 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-01 | EM-01 | P0 | 정상 | match-service | 매치 생성 및 OWNER 자동 등록 | 정상 시설 존재/로그인 | POST /api/matches; DB 확인 | serviceId,종목,시간,정원 | 201; match와 OWNER 참가자 1건 원자 저장 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-02 | EM-01 | P0 | 예외 | match-service | 없는 시설 ID 생성 차단 | 시설 ID 없음 | POST /api/matches; 양쪽 DB 확인 | serviceId=999999 | 404; match/participant 생성 0건 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-03 | EM-02 | P0 | 정상 | match-service | 종목/지역/숙련도 다중 AND 필터 | 다양한 매치 시드 | GET /api/matches | sportType=FUTSAL&region=강남구&skillLevel=BEGINNER | 200; 모든 조건 충족 매치만 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-04 | EM-02 | P1 | 예외 | match-service | 잘못된 날짜 범위 | 서버 정상 | GET /api/matches | startAt>endAt | 400; 유효한 오류 메시지 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-05 | EM-03 | P0 | 보안 | match-service | 매치 상세 로그인/비로그인 | 매치 존재 | GET /api/matches/{id} | Bearer 유효 또는 없음 | 200; 로그인 role flags 정확, 비로그인도 조회 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-06 | EM-04 | P0 | 보안 | match-service | 타인 수정 거부/정원 축소 | OWNER + 참가자 | PUT /api/matches/{id} | 비OWNER; 새 정원<참가수 | 403/400; 기존 정보 무변경 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-07 | EM-05 | P0 | 정상 | match-service | 매치 삭제 참가자 정리 | OWNER, 참가자 있음 | DELETE /api/matches/{id} | OWNER 토큰 | 204; match+participant 함께 정리 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-08 | EM-06 | P0 | 정상 | match-service | 정상 참여 및 중복 참가 | RECRUITING, 여유 | POST /participants 두 번 | 같은 userId | 처음 201, 두 번째 409, 인원 1명 증가 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-09 | EM-06 | P0 | 동시성 | match-service | 마지막 1자리 경쟁 | 남은 정원 1 | 서로 다른 사용자 2명 병렬 POST | 동시 실행 barrier | 성공 1건; 최종 참가자 ≤ max; 중복 0 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-10 | EM-07 | P0 | 보안 | match-service | 일반 참가 탈퇴 vs OWNER 차단 | OWNER+PARTICIPANT | DELETE /participants/me | 2가지 역할 | 일반 204, OWNER 403; 상태 일치 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-11 | EM-08 | P1 | 보안 | match-service | 내 매치 소유/참가만 조회 | 2명 서로 다른 참가 | GET /api/matches/me | 2명 각 계정 | 200; 내 목록만 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-01 | AI-01 | P0 | 정상 | ai-service | AI 생성 초안 저장 금지 | 로그인·AI mock | POST /api/ai/matches | "이번 주 토요일 송파 풋살 10명" | 200; initialValues, match DB 추가 0 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-02 | AI-01 | P1 | 예외 | ai-service | 빈 프롬프트/미지원 종목 | AI mock | POST /api/ai/matches | prompt="" / "스쿼시" | 400 안내; AI 호출/DB 저장 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-03 | AI-02 | P0 | 정상 | ai-service | AI 조건 추출 + 서버 재검색 | 검색 데이터 시드 | POST /api/ai/matches/search | "이번 주말 강남 초급 풋살" | 200; conditions+criteria+matches, 조건 일치 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-04 | AI-02 | P1 | 경계 | ai-service | AI 조건 불명확/결과 없음 | 검색 데이터 없음 | POST /api/ai/matches/search | "강동구에서 수영" | 200; matches=[]; 조건 요약 유지 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-05 | AI-03 | P1 | 정상 | ai-service | 맞춤 추천 최대 3건 | 프로필·매치 시드 | GET /api/ai/matches/recommendations | 회원 Bearer | 200; 후보 필터 일치, 최대 3 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-06 | AI-03 | P1 | 장애 | ai-service | AI 외부 장애 대체 | 대체 후보 존재 | 외부 AI timeout 주입 후 GET 추천 | AI 실패 mock | 5xx 노출 없이 서버 순위 사용(설계 목표) | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-01 | FC-01 | P0 | 정상 | facility-service | 시설 필터 검색 | 시설 데이터 시드 | GET /api/services | region=강남구&status=접수중 | 200; 조건 일치 목록 | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-02 | FC-01 | P0 | 장애 | facility-service | 공공데이터 수집 실패 때 기존 목록 | DB 기존 데이터 | 공공 API 실패 모의; GET /api/services | 외부 API 500 | 200 기존 목록; 기존 데이터 불변 | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-03 | FC-02 | P0 | 정상 | facility-service | 시설 상세 및 예약 URL | 시설 존재 | GET /api/services/{id} | DB PK id | 200; URL 등 반환, 내부 예약 처리 안함 | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-04 | FC-02 | P1 | 예외 | facility-service | 없는/잘못된 시설 ID | 서버 정상 | GET /api/services/{id} | abc, 999999 | 400/404; 5xx 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-01 | MSA-01 | P0 | 아키텍처 | 전체 | 4개 서비스 독립 기동 | Compose 준비 | 4개 앱 단독 실행 및 DB 접근 점검 | 각 DB 계정 | 각자 헬스 200; 다른 서비스 DB 직접 조회 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-02 | MSA-02 | P0 | 인프라 | Infra | Eureka 정상 등록/해제 | Eureka 동작 | 서비스 up/down; 대시보드 확인 | 4개 서비스 | UP 등록; 종료 시 상태 반영 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-03 | MSA-03 | P0 | 통합 | Infra | Gateway 전체 외부 API 라우팅 | 전체 서비스 기동 | 주요 6개 prefix 호출 | /api/users,/api/matches,/api/ai 등 | Gateway 1개 주소만으로 기능 동작 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-04 | MSA-03 | P0 | 보안 | Infra | 내부 API 외부 차단 | Gateway 실행 | Gateway 통해 /internal 호출 | GET /internal/matches | 403/404; 직접 서비스 내부망만 허용 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-05 | MSA-04 | P0 | 인프라 | Infra | Config 중앙 관리 | Config Repo/서버 존재 | local/dev profile 조회 후 재시작 | 서비스별 설정 | 중앙값 로드, 시크릿 노출 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-06 | MSA-05 | P0 | 통합 | match-service | Feign 매치→시설 검증 | 서비스 둘 다 UP | 기존 시설/없는 시설로 생성 | serviceId 1/999999 | 정상 201; 없는 시설 404; DB 직접 접근 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-07 | MSA-05 | P0 | 장애 | match-service | Feign 타임아웃 격리 | 시설 서비스 중단 | 매치 생성 호출 | Feign timeout 1s 예시 | 의도된 503 또는 설정된 Fallback; 무한 대기 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-08 | MSA-06 | P0 | 이벤트 | ai-service | 매치 생성 이벤트 → AI projection | Kafka/consumer 기동 | 매치 생성 후 projection 조회 | MatchCreated eventId | 이벤트 1건 처리, 검색 모델 반영 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-09 | MSA-06 | P0 | 멱등성 | ai-service | 동일 Kafka 이벤트 두 번 처리 | 동일 eventId 확보 | 같은 이벤트 두 번 발행 | eventId 동일 | projection 1회만 변경, processed_event 1건 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-10 | MSA-08 | P0 | 데이터 | DB | cross-db FK 없음 | 4개 DB 생성 | 정보스키마/DDL 확인 | match.service_id/participant.user_id | 다른 DB FK 0, DB 소유권 유지 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-11 | MSA-08 | P0 | 보안 | DB | DB 최소 권한 | DB 계정 4개 | 다른 DB SELECT 시도 | identity 계정으로 match DB | 접근 거부 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-12 | MSA-09 | P0 | 배포 | Infra | Compose 재현·볼륨 | 클린 PC 또는 clean Compose | docker compose up --build, 재시작 | 환경변수 예시 적용 | 모든 서비스 UP, 핵심 API 성공, 데이터 유지 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-13 | MSA-10 | P0 | 관측 | Infra | Prometheus/Grafana 모니터링 | 모니터링 스택 실행 | 검색 부하 및 강제 장애 | 5xx, latency sample | 서비스별 RPS/오류율/latency 그래프 캡처 | 2차 재검증 | Not Run |  |  |  |  |
| TC-INT-09 | USR-04 | P1 | 이벤트 | match-service | 회원 탈퇴 후 매치 정리 | UserWithdrawn 구독 | 탈퇴 후 재전달, match 조회 | UserWithdrawn 중복 | 참가 관계 정리, 재처리 부작용 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-E2E-01 | MSA-07 | P0 | E2E | 전체 | 시설→매치 개설→참여→AI 검색 | 모든 컨테이너 정상 | FE 실제 흐름 따라 4단계 시연 | 시설/매치 시드 | 각 단계 정상, DB/이벤트·화면 일치 | 2차 재검증 | Not Run |  |  |  |  |
| TC-E2E-02 | MSA-07 | P0 | E2E | 전체 | 로그인/마이페이지/매치 수정·삭제 | 2명 회원 시드 | 화면 로그인·매치 작업·마이페이지 | OWNER+PARTICIPANT | 새로고침 후 데이터 일치; 권한 구분 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-01 | NFR-02 | P1 | 성능 | QA·Infra | 일반 API 2s/AI 15s 목표 측정 | 부하 환경 고정 | k6/JMeter 테스트 | 동시사용자/반복 조건 기록 | p95 측정치와 목표 충족 여부 기록 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-02 | NFR-03 | P0 | 보안 | Infra | JWT 위조 및 비밀정보 노출 차단 | 서비스 운영 | 위조 토큰 호출, Repo 점검 | 서명 위조 토큰 | 401; 키/암호/프롬프트 로그 미노출 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-03 | NFR-05 | P1 | 문서 | QA·문서 | 요구-API-테스트 추적 | 산출물 최신 | ID/결과/PR 대조 | 문서 링크 | 기능 ID↔API↔TC 매핑, 누락 없거나 이슈 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-04 | NFR-06 | P1 | 장애 | 전체 | AI·공공 API 외부 장애 | Mock 서버 준비 | 에러/타임아웃 모의 | 503/timeout | 시설 캐시와 AI 대체 응답, 에러 로그 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-05 | NFR-07 | P1 | 관측 | Infra | correlationId로 흐름 추적 | logging 설정 | Gateway→Feign 호출 | X-Correlation-Id 샘플 | 개별 서비스 로그에서 동일 ID 추적 | 2차 재검증 | Not Run |  |  |  |  |
| TC-OPT-01 | ENH-01 | P2 | 선택 | Infra | Circuit Breaker 동작 | Resilience4j 적용 | 시설 서비스 강제 종료 | Feign GET | fallback 또는 503 응답 및 회복 | 2차 재검증 | Not Run |  |  |  |  |
| TC-OPT-02 | ENH-02 | P2 | 선택 | Infra | K8s 배포 동작 | K8s 클러스터 | apply manifests; rollout status | Deployment/ConfigMap/Service | Pods READY; Gateway 기능 호출 | 2차 재검증 | Not Run |  |  |  |  |
| TC-OPT-03 | ENH-03 | P2 | 선택 | QA | 부하 테스트 보고서 | k6 scripts | 검색/동시 매치 참가 테스트 | VU·duration 정의 | p95·에러율·정합성 결과 보고 | 2차 재검증 | Not Run |  |  |  |  |
| TC-OPT-04 | ENH-04 | P2 | 선택 | Infra | CI/CD 자동 배포 | Actions 구축 | main/develop 기준 파이프라인 실행 | 테스트·이미지 push | 성공 로그·태그·배포 이력 | 2차 재검증 | Not Run |  |  |  |  |
| TC-OPT-05 | ENH-05 | P2 | 선택 | BE | Outbox 장애 후 재발행 | Outbox 구현 | Kafka 정지→매치 생성→복구 | MatchCreated event | outbox 남음→재발행→processed_event 1회 | 2차 재검증 | Not Run |  |  |  |  |
| TC-USR-09 | USR-02 | P0 | 보안 | identity-service | WITHDRAWN 사용자 로그인 차단 | 탈퇴 사용자 생성 | 탈퇴 계정으로 로그인 | ACTIVE→WITHDRAWN | 401, Refresh 발급 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-PR-03 | PR-01 | P1 | 보안 | identity-service | 타인 프로필 수정 차단 | 서로 다른 계정 | 다른 사용자 정보 변조 요청 | JWT.userId≠target | 수정 불가, DB 보존 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-12 | EM-06 | P0 | 경계 | match-service | 정원 포화 상태 재참가 | 정원 도달 | POST /participants | current=max | 400; 참가자 변경 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-13 | EM-06 | P1 | 경계 | match-service | CLOSED 참가 차단 | 매치 CLOSED | POST /participants | status=CLOSED | 400; 미등록 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-14 | EM-06 | P1 | 경계 | match-service | 시작된 매치 참가 차단 | startAt<현재 | POST /participants | 과거 startAt | 400; 미등록 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-15 | EM-06 | P1 | 경계 | match-service | OWNER 재참가 차단 | OWNER로 자동 등록 | POST /participants | OWNER 토큰 | 409; 중복 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-16 | EM-01 | P0 | 장애 | match-service | Facility Feign 장애 시 롤백 | 시설 서비스 장애 | POST /api/matches | Feign timeout | 503; match/OWNER 기록 0건 | 2차 재검증 | Not Run |  |  |  |  |
| TC-EM-17 | EM-04 | P1 | 경계 | match-service | 정원 확장·수정 반영 | 매치/참가자 존재 | PUT 후 GET | max 5→8 | 200; 실 참가인원 보존 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-07 | AI-02 | P1 | 보안 | ai-service | 프롬프트 조작 텍스트 무시 | Mock AI | POST 자연어 검색 | 시스템 명령 삽입 텍스트 | 서버 필터 우회/내부 호출 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-08 | AI-03 | P1 | 경계 | ai-service | 추천 프로필 일부 누락 | 빈 선호 종목 | GET AI recommendations | sportTypes=[] | 200 []; 크래시 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-AI-09 | AI-01 | P1 | 경계 | ai-service | 자연어 500자 초과 | API 정상 | POST AI draft | 501 chars | 400, AI 호출 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-05 | FC-02 | P1 | 경계 | facility-service | 비활성 서비스 상세 | 서비스 active=false | GET 상세 | serviceId 비활성 | 404 혹은 명세화한 비활성 응답 | 2차 재검증 | Not Run |  |  |  |  |
| TC-FC-06 | FC-02 | P1 | 경계 | facility-service | 공공데이터 일부 값 누락 | nullable 원본 | GET 상세 | 좌표/연락처 null | 200; 필드 default 표기, NPE 없음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-14 | MSA-04 | P1 | 배포 | Infra | local/dev 설정 분리 | Config Server 두 프로필 | 서비스별 설정 비교 | local/dev | 서로 다른 설정값 로드 | 2차 재검증 | Not Run |  |  |  |  |
| TC-MSA-15 | MSA-06 | P0 | 멱등성 | ai-service | 역순 이벤트 버전 무시 | projection version 4 | version 3 수신 후 4 수신 | aggregateVersion=3,4 | v3가 v4 덮어쓰지 않음 | 2차 재검증 | Not Run |  |  |  |  |
| TC-E2E-03 | MSA-07 | P0 | E2E | 전체 | 회원-시설-매치-Gateway 통합 | 4서비스 UP | signup→login→facility→match→participant | 사용자 2명 | 각 DB 기록과 FE 화면 일치 | 2차 재검증 | Not Run |  |  |  |  |
| TC-QA-06 | NFR-07 | P1 | 보안 | Infra | 로그 토큰 마스킹 | Auth 요청 후 | 로그에서 Authorization 문자열 탐색 | Bearer secret | 로그에 원문 토큰 없음 | 2차 재검증 | Not Run |  |  |  |  |


## E2E 시나리오

Day 4~5 시연 흐름으로 전체 서비스/프론트/DB/Kafka를 한 번에 검증. 결과 링크 작성 필요.

| 시나리오 ID | 사용자 흐름 | 요구 기능 | 중요도 | 실행 순서 | 검증 포인트 | 상태 | 담당자 | 증빙 URL |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S01 | 시설 검색 → 매치 개설 → 참여 → AI 검색 | FC-01/02, EM-01/06, AI-02 | 모든 필수 | 시설을 고르고 매치를 개설한 뒤 다른 계정이 참여. AI 자연어로 검색하여 같은 매치를 확인. | 핵심 시연 | Not Run |  |  |
| S02 | 매치 정원 초과/동시 경쟁 | EM-06, NFR-04 | P0 | 남은 자리 1개에 2명이 동시 참여, 1명만 성공함을 DB로 증명 | 장애·예외 시연 | Not Run |  |  |
| S03 | Kafka 중복 이벤트 재전송 | MSA-06 | P0 | 동일 eventId를 2회 발행하여 projection이 단 한 번 갱신됨을 확인 | 이벤트 차별화 | Not Run |  |  |
| S04 | Facility Service 장애·복구 | MSA-05, NFR-06 | P0 | 시설 서비스 종료 시 매치 생성의 타임아웃 제어, 기존 목록 Fallback 범위 검증 | 회복력 | Not Run |  |  |
| S05 | Grafana 관측 | MSA-10 | P0 | 부하 요청·강제 5xx 후 메트릭 그래프·서비스 UP/DOWN 캡처 | 핵심 차별화 | Not Run |  |  |
| S06 | K8s / CI/CD (선택) | ENH-02/04 | P2 | 시간이 남으면 배포 또는 자동 파이프라인 1회 시연 | 선택 3점 | Not Run |  |  |


## 검증 기준

기능 점수는 테스트 수행 기록과 동작 시연으로 입증. 원본 1차 Pass는 신규 2차 테스트 Pass가 아님.

| 검증 영역 | 핵심 목표 | 대상 TC | 판정 / 주의 |
| --- | --- | --- | --- |
| P0 필수 1~10 | Eureka/Config/Gateway/Feign/Kafka/DB/Compose/관측 증빙 | TC-MSA-01~15 | 하나라도 실패 시 필수 Gate 미통과 |
| 보안/예외 | JWT·권한·중복 참·정원경쟁 | TC-USR-*, TC-EM-*, TC-QA-02 | 특히 정원 경쟁 실패는 배포 차단 |
| 외부 장애 | 공공데이터/AI/Feign Failover | TC-FC-02, TC-AI-06, TC-MSA-07 | 정상 경로를 테스트 DB fixture로 안정화 |
| 성능 | 1차 일반 API 2s·AI 15s 목표 | TC-QA-01, TC-OPT-03 | 테스트 환경·p95·지연 상황 로그 기록 |
| CI/배포 | 재현 가능한 Docker Compose 및 선택 K8s | TC-MSA-12, TC-OPT-02/04 | 문서/화면 캡처 필수 |


## 진행 집계

팀원들이 테스트_매트릭스의 상태만 업데이트하면 자동 집계. B행 수식은 사용자가 편집하지 않습니다.

> 원본 Excel의 자동 집계 수식은 Markdown에서 계산되지 않습니다. 아래 값은 수식 텍스트이며 테스트 실행 결과가 아닙니다.

| 지표 | 자동 계산 | 해석 |
| --- | --- | --- |
| 전체 케이스 | =COUNTA('테스트_매트릭스'!$A$5:$A$78) | TC 전체 수 |
| P0 | =COUNTIF('테스트_매트릭스'!$C$5:$C$78,"P0") | 필수 Gate |
| P1 | =COUNTIF('테스트_매트릭스'!$C$5:$C$78,"P1") | 중요 회귀 |
| P2 | =COUNTIF('테스트_매트릭스'!$C$5:$C$78,"P2") | 선택 |
| Pass | =COUNTIF('테스트_매트릭스'!$L$5:$L$78,"Pass") | 실행 후만 입력 |
| Fail | =COUNTIF('테스트_매트릭스'!$L$5:$L$78,"Fail") | 결함 ID 필수 |
| Blocked | =COUNTIF('테스트_매트릭스'!$L$5:$L$78,"Blocked") | 진행 장애 |
| Not Run | =COUNTIF('테스트_매트릭스'!$L$5:$L$78,"Not Run") | 초기 기본 상태 |
| 실행 완료율 | =IFERROR((B9+B10)/B5,0) | Pass+Fail/전체, Blocked 제외 |


## 결함 등록 가이드

Fail / Blocked는 실제 결과와 GitHub Issue URL을 남겨 회귀 테스트까지 추적합니다.

| 상태 | 의미 | 필수 입력 | 권장 기준 |
| --- | --- | --- | --- |
| Not Run | 실행하지 않음 | 담당/실행예정일 | 초기 상태 |
| Pass | 기대 HTTP·DB·화면·이벤트가 모두 일치 | 실행일/환경/증빙 URL | 스크린샷·로그·테스트명 |
| Fail | 기대와 실제 결과 불일치 | 실제결과, 결함 ID, 재현 절차 | P0면 배포 차단 |
| Blocked | 외부 API/권한/환경 문제로 실행 불가 | 블로커 원인/담당 | 재실행 일정 확정 |


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
