# Sporty v2 테스트 케이스

> 작성자: 안지산  
> v1.1 · 2026-11-04 · 최종 Excel의 전체 243개 케이스와 11종 재시험 결과를 Markdown으로 변환했습니다. 제공된 실행 결과를 반영했으며 이 문서 작성 과정에서 시험을 재실행하지 않았습니다.

## 기준 및 결과

- 기본 케이스 기준: backend `96357e5` / frontend `8b6bc9e`.
- 11종 재시험 기준: backend `bacaa84518029c7c2656a2be64e4c2223bcc5e31` / frontend `e01fdbfec10ddbbb09586dd55906a367d7d38d49` / config `8695cafaab132caec94232cae2b9e03a58d746bb`.
- 원 11종은 PASS 11건이며, 분기별로 구분된 시스템 테스트 13개 행에 반영했습니다.
- P = 통과, F = 실패, B = 차단. 미실행은 통과로 간주하지 않습니다.

| 수준 | 케이스 | P | F | B | 미실행 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 단위 테스트(UT) | 66 | 62 | 0 | 4 | 0 |
| 통합 테스트(IT) | 99 | 0 | 0 | 0 | 99 |
| 시스템 테스트(ST) | 39 | 22 | 0 | 2 | 15 |
| 인수 테스트(AT) | 39 | 3 | 0 | 0 | 36 |
| **합계** | **243** | **87** | **0** | **6** | **150** |

## 단위 테스트(UT)

### UT-AI-01 — AI 매치 초안 API

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-01 |
| 서비스 | ai-service |
| 테스트 클래스 | AiDraftApiTest |
| 검증 대상 | AI 매치 초안 API |
| 구분 | 1차 |
| 요구사항 ID | AI-01·FC-04 |
| 입력값(테스트 데이터) | 자연어 문장(종목·자치구·요일·시각·인원), LLM·Feign 스텁 |
| 기대 결과(대표 검증 내용) | 초안 200·종료시각·성별 기본값, 시설 후보 채움/조회 실패 시 빈 배열, LLM 실패 503 AI_UNAVAILABLE, 정보 부족 400 AI_DRAFT_INSUFFICIENT, 미지원 종목 400 AI_UNSUPPORTED_SPORT |
| 실행 수 | 14 |
| 통과 | 14 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-02 — ai 공통 에러 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-02 |
| 서비스 | ai-service |
| 테스트 클래스 | AiErrorResponseTest |
| 검증 대상 | ai 공통 에러 응답 |
| 구분 | 신규 |
| 요구사항 ID | NFR-06 |
| 입력값(테스트 데이터) | 처리 안 된 예외 유발 요청, 4xx·404·405 요청 |
| 기대 결과(대표 검증 내용) | 500 {code,message}·내부 메시지 숨김, 기존 4xx·404·405 상태 유지 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-03 — AI Mock 모드 초안

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-03 |
| 서비스 | ai-service |
| 테스트 클래스 | AiMockModeApiTest |
| 검증 대상 | AI Mock 모드 초안 |
| 구분 | 신규 |
| 요구사항 ID | AI-04 |
| 입력값(테스트 데이터) | Mock 모드 켬, 초안 문장/정보 없는 문장 |
| 기대 결과(대표 검증 내용) | 응답 형식 동일, 정보 없으면 400 AI_DRAFT_INSUFFICIENT |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-04 — 맞춤 추천·대체 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-04 |
| 서비스 | ai-service |
| 테스트 클래스 | AiRecommendApiTest |
| 검증 대상 | 맞춤 추천·대체 응답 |
| 구분 | 신규 |
| 요구사항 ID | AI-03·AI-04 |
| 입력값(테스트 데이터) | X-User-Id, 후보 매치·LLM 응답/실패 스텁 |
| 기대 결과(대표 검증 내용) | LLM 순서 추천·부족분 후보로 채움, LLM 실패·잘못된 ID는 최신순 fallback, 회원 없음 404 USER_NOT_FOUND, 목록 실패 500 AI_RECOMMEND_FAILED, 헤더 없음 401 |
| 실행 수 | 9 |
| 통과 | 9 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-05 — 자연어 검색·대체 검색

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-05 |
| 서비스 | ai-service |
| 테스트 클래스 | AiSearchApiTest |
| 검증 대상 | 자연어 검색·대체 검색 |
| 구분 | 신규 |
| 요구사항 ID | AI-02·AI-04 |
| 입력값(테스트 데이터) | 검색 문장, LLM 실패 스텁 |
| 기대 결과(대표 검증 내용) | LLM 조건 검색, 실패 시 문장 속 종목·자치구로 대체, 조건 없음 400 AI_CONDITION_NOT_FOUND, match 실패 503 AI_UNAVAILABLE, 지표 rejected/error 구분 |
| 실행 수 | 9 |
| 통과 | 9 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-06 — LLM Mock 스위치

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-06 |
| 서비스 | ai-service |
| 테스트 클래스 | ChatMockSwitchTest |
| 검증 대상 | LLM Mock 스위치 |
| 구분 | 신규 |
| 요구사항 ID | AI-04 |
| 입력값(테스트 데이터) | mock 설정 on/off |
| 기대 결과(대표 검증 내용) | 켜면 ChatClient 미호출, 끄면 호출 |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-07 — Mock LLM 규칙

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-07 |
| 서비스 | ai-service |
| 테스트 클래스 | MockLlmTest |
| 검증 대상 | Mock LLM 규칙 |
| 구분 | 신규 |
| 요구사항 ID | AI-04 |
| 입력값(테스트 데이터) | 초안·검색·추천 문장 예시 |
| 기대 결과(대표 검증 내용) | 종목·자치구·요일·시각·인원 추출, "이번 주말"=토~일, 조건 없음 안내 문장 |
| 실행 수 | 14 |
| 통과 | 14 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-08 — OpenAI 키 기본값

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-08 |
| 서비스 | ai-service |
| 테스트 클래스 | OpenAiKeyDefaultsTest |
| 검증 대상 | OpenAI 키 기본값 |
| 구분 | 신규 |
| 요구사항 ID | NFR-07 |
| 입력값(테스트 데이터) | 빈 키/있는 키 |
| 기대 결과(대표 검증 내용) | 빈 값이면 더미 키로 기동, 값 있으면 유지 |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-AI-09 — AI 호출 지표

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-AI-09 |
| 서비스 | ai-service |
| 테스트 클래스 | AiMetricsTest |
| 검증 대상 | AI 호출 지표 |
| 구분 | 신규 |
| 요구사항 ID | AI-04·MON-1 |
| 입력값(테스트 데이터) | 4xx·5xx·예상 못 한 예외 |
| 기대 결과(대표 검증 내용) | 4xx는 rejected, 5xx·예외는 error로 기록 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-CFG-01 — 암호화 키 없음

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-CFG-01 |
| 서비스 | config-service |
| 테스트 클래스 | EncryptionDisabledTest |
| 검증 대상 | 암호화 키 없음 |
| 구분 | 신규 |
| 요구사항 ID | ②·NFR-05 |
| 입력값(테스트 데이터) | 키스토어 없음 |
| 기대 결과(대표 검증 내용) | 키 없어도 Config Server 기동, /encrypt는 실패 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-CFG-02 — 키스토어 암복호화

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-CFG-02 |
| 서비스 | config-service |
| 테스트 클래스 | KeyStoreEncryptionTest |
| 검증 대상 | 키스토어 암복호화 |
| 구분 | 신규 |
| 요구사항 ID | ②·NFR-05 |
| 입력값(테스트 데이터) | 테스트 키스토어, 평문/{cipher} 값 |
| 기대 결과(대표 검증 내용) | encrypt→decrypt 왕복 일치, {cipher} 값은 복호화해 제공 |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-FC-01 — 시설 목록·상세·내부 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-FC-01 |
| 서비스 | facility-service |
| 테스트 클래스 | FacilityApiTest |
| 검증 대상 | 시설 목록·상세·내부 조회 |
| 구분 | 1차 |
| 요구사항 ID | FC-01·FC-02·FC-04 |
| 입력값(테스트 데이터) | 자치구·시간 조건, 숫자 아닌 ID, 비활성 시설 |
| 기대 결과(대표 검증 내용) | 활성 시설만·자치구 필터, 시간 역전/형식 오류 400 INVALID_SEARCH_CONDITION, 비활성 상세 404, 숫자 아닌 ID 400 INVALID_SERVICE_ID, 내부 조회는 비활성도 200 active=false |
| 실행 수 | 18 |
| 통과 | 18 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-FC-02 — facility 공통 에러 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-FC-02 |
| 서비스 | facility-service |
| 테스트 클래스 | FacilityErrorResponseTest |
| 검증 대상 | facility 공통 에러 응답 |
| 구분 | 신규 |
| 요구사항 ID | NFR-06 |
| 입력값(테스트 데이터) | 예외 유발 요청 |
| 기대 결과(대표 검증 내용) | 500 {code,message}, 4xx·404·405 유지 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-FC-03 — 공공데이터 수집

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-FC-03 |
| 서비스 | facility-service |
| 테스트 클래스 | SeoulFacilityApiClientTest |
| 검증 대상 | 공공데이터 수집 |
| 구분 | 1차 |
| 요구사항 ID | FC-03 |
| 입력값(테스트 데이터) | 전체/일부 건수 응답 스텁 |
| 기대 결과(대표 검증 내용) | 전체 건수 수신 시 통과, 일부만 받으면 동기화 중단(기존 목록 보존) |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-GW-01 — Gateway 경로 분류

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-GW-01 |
| 서비스 | gateway-service |
| 테스트 클래스 | AuthorizationHeaderFilterTest |
| 검증 대상 | Gateway 경로 분류 |
| 구분 | 신규 |
| 요구사항 ID | GW-02·GW-03·GW-04 |
| 입력값(테스트 데이터) | 경로·메서드 조합(파라미터 82건) |
| 기대 결과(대표 검증 내용) | 토큰 무시·검증·공개·비공개·ADMIN 경로 분류, ".." 포함 경로 판별 |
| 실행 수 | 82 |
| 통과 | 82 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-GW-02 — JWT 필터 통합

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-GW-02 |
| 서비스 | gateway-service |
| 테스트 클래스 | AuthorizationHeaderIntegrationTest |
| 검증 대상 | JWT 필터 통합 |
| 구분 | 신규 |
| 요구사항 ID | GW-02·GW-03·NFR-05 |
| 입력값(테스트 데이터) | 유효/만료/위조/비Bearer 토큰, 위조 X-User-Id 헤더 |
| 기대 결과(대표 검증 내용) | 위조 헤더 제거·유효 토큰 값으로 덮어씀, 비공개 경로 무토큰 401, 위조·만료 401, USER의 관리자 경로 403 |
| 실행 수 | 28 |
| 통과 | 28 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-GW-03 — 내부·actuator 경로 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-GW-03 |
| 서비스 | gateway-service |
| 테스트 클래스 | InternalPathBlockFilterTest |
| 검증 대상 | 내부·actuator 경로 차단 |
| 구분 | 신규 |
| 요구사항 ID | GW-04 |
| 입력값(테스트 데이터) | internal 포함 경로, actuator 경로(파라미터 45건) |
| 기대 결과(대표 검증 내용) | internal 포함 403, 공개 health 외 actuator 403, 나머지 통과 |
| 실행 수 | 45 |
| 통과 | 45 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-01 — match 공통 에러 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-01 |
| 서비스 | match-service |
| 테스트 클래스 | MatchErrorResponseTest |
| 검증 대상 | match 공통 에러 응답 |
| 구분 | 신규 |
| 요구사항 ID | NFR-06 |
| 입력값(테스트 데이터) | 예외 유발 요청 |
| 기대 결과(대표 검증 내용) | 500 {code,message}·내부 메시지 숨김, 기존 코드 유지 |
| 실행 수 | 4 |
| 통과 | 4 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-02 — 매치 생성·검색·상세

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-02 |
| 서비스 | match-service |
| 테스트 클래스 | MatchCrudTest |
| 검증 대상 | 매치 생성·검색·상세 |
| 구분 | 변경 |
| 요구사항 ID | EM-01·EM-02·EM-03·EM-04 |
| 입력값(테스트 데이터) | 생성 body(정원 2), 검색 필터, 잘못된 입력·무인증 |
| 기대 결과(대표 검증 내용) | 생성 시 시설 스냅샷 복사·OWNER 등록, 정원 2 RECRUITING, 400 INVALID_INPUT·401, 검색 필터·기본 상태, 상세는 시설 재조회 없이 스냅샷 |
| 실행 수 | 20 |
| 통과 | 20 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-03 — 보증금 실제 브로커

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-03 |
| 서비스 | match-service |
| 테스트 클래스 | DepositKafkaBrokerTest |
| 검증 대상 | 보증금 실제 브로커 |
| 구분 | 신규 |
| 요구사항 ID | PT-02·NFR-04 |
| 입력값(테스트 데이터) | 실제 Kafka 브로커(CI 미제공) |
| 기대 결과(대표 검증 내용) | Outbox 차감 결과·반환·잘못된 이벤트 DLT |
| 실행 수 | 1 |
| 통과 | 0 |
| 실패 | 0 |
| 건너뜀 | 1 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) · 실제 서비스/브로커가 있어야 도는 테스트라 CI에서 전부 건너뜀 |

### UT-MT-04 — 보증금 Saga

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-04 |
| 서비스 | match-service |
| 테스트 클래스 | DepositSagaTest |
| 검증 대상 | 보증금 Saga |
| 구분 | 신규 |
| 요구사항 ID | PT-02·EM-06·EM-10·WL-02 |
| 입력값(테스트 데이터) | 생성·참가 요청, deposit-charged/rejected 이벤트, 타임아웃 |
| 기대 결과(대표 검증 내용) | 생성 202·PENDING 숨김→OWNER 확정, 참가 202 후 joined, 거절 FAILED, 마지막 자리 무초과, 타임아웃 뒤 늦은 성공 재확정 없음, 매치 취소 전원 반환, 중복 eventId 무변경, 승급 시 차감 |
| 실행 수 | 35 |
| 통과 | 35 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-05 — 참여 정지 검사

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-05 |
| 서비스 | match-service |
| 테스트 클래스 | ParticipationSuspensionTest |
| 검증 대상 | 참여 정지 검사 |
| 구분 | 신규 |
| 요구사항 ID | PT-04 |
| 입력값(테스트 데이터) | I1 suspendedUntil 미래/과거 |
| 기대 결과(대표 검증 내용) | 정지 중 신규 활동 차단, 지난 정지는 허용 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-06 — 매치 상태 규칙

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-06 |
| 서비스 | match-service |
| 테스트 클래스 | MatchEntityStatusTest |
| 검증 대상 | 매치 상태 규칙 |
| 구분 | 신규 |
| 요구사항 ID | EM-09·EM-04·EM-05·MSA-7 |
| 입력값(테스트 데이터) | 상태별 엔터티 조작 |
| 기대 결과(대표 검증 내용) | 취소·완료 매치 재개 불가, 시작 후 수정 거절, 부분 갱신 없음, 정원 1 생성 불가 |
| 실행 수 | 7 |
| 통과 | 7 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-07 — facility 실서비스 계약

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-07 |
| 서비스 | match-service |
| 테스트 클래스 | LiveFacilityContractTest |
| 검증 대상 | facility 실서비스 계약 |
| 구분 | 신규 |
| 요구사항 ID | FC-04·⑤ |
| 입력값(테스트 데이터) | 실제 facility-service(CI 미기동) |
| 기대 결과(대표 검증 내용) | 스냅샷 필드 역직렬화, 비활성 거절, 없는 시설과 장애 구분, 운영시간 밖 거절, 중지 시 503 |
| 실행 수 | 5 |
| 통과 | 0 |
| 실패 | 0 |
| 건너뜀 | 5 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) · 실제 서비스/브로커가 있어야 도는 테스트라 CI에서 전부 건너뜀 |

### UT-MT-08 — user 실서비스 계약

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-08 |
| 서비스 | match-service |
| 테스트 클래스 | LiveMemberContractTest |
| 검증 대상 | user 실서비스 계약 |
| 구분 | 신규 |
| 요구사항 ID | USR-08 |
| 입력값(테스트 데이터) | 실제 user-service(CI 미기동) |
| 기대 결과(대표 검증 내용) | 성별·상태 수신, 탈퇴 중/완료 회원 참가 불가, 성별 제한, 404가 CB를 열지 않음 |
| 실행 수 | 6 |
| 통과 | 0 |
| 실패 | 0 |
| 건너뜀 | 6 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) · 실제 서비스/브로커가 있어야 도는 테스트라 CI에서 전부 건너뜀 |

### UT-MT-09 — Feign 회원·시설 확인

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-09 |
| 서비스 | match-service |
| 테스트 클래스 | MatchRemoteChecksTest |
| 검증 대상 | Feign 회원·시설 확인 |
| 구분 | 신규 |
| 요구사항 ID | USR-08·FC-04·⑤·NFR-02 |
| 입력값(테스트 데이터) | WireMock 회원·시설 응답, 오류·지연 |
| 기대 결과(대표 검증 내용) | Feign Micrometer 타이머 생성, 회원·시설 스냅샷 검증, 오류 코드 매핑·CB |
| 실행 수 | 25 |
| 통과 | 25 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-10 — 상태 전이 스케줄러

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-10 |
| 서비스 | match-service |
| 테스트 클래스 | MatchLifecycleSchedulerTest |
| 검증 대상 | 상태 전이 스케줄러 |
| 구분 | 신규 |
| 요구사항 ID | EM-09 |
| 입력값(테스트 데이터) | 첫 페이지 처리 실패 |
| 기대 결과(대표 검증 내용) | 한 페이지 실패가 다음 매치 처리를 막지 않음 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-11 — 상태 전이·출석·정산 요청

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-11 |
| 서비스 | match-service |
| 테스트 클래스 | MatchLifecycleTest |
| 검증 대상 | 상태 전이·출석·정산 요청 |
| 구분 | 신규 |
| 요구사항 ID | EM-09·EM-11·PT-03 |
| 입력값(테스트 데이터) | 시작/종료 시각 경과 매치, 출석 PATCH |
| 기대 결과(대표 검증 내용) | IN_PROGRESS·COMPLETED 전이와 status-changed, 확정 참가자별 정산 요청, 2명 미만 UNDER_MIN_PARTICIPANTS, 반복·동시 실행 1회, 보증금 비활성 시 정산 생략, 방장만·시간 내 출석 수정 |
| 실행 수 | 11 |
| 통과 | 11 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-12 — eventId 순서

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-12 |
| 서비스 | match-service |
| 테스트 클래스 | OrderedEventIdTest |
| 검증 대상 | eventId 순서 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| 입력값(테스트 데이터) | 같은 밀리초 생성 ID |
| 기대 결과(대표 검증 내용) | 생성 순서대로 정렬 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-13 — 참가 이벤트 Outbox

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-13 |
| 서비스 | match-service |
| 테스트 클래스 | ParticipationEventsTest |
| 검증 대상 | 참가 이벤트 Outbox |
| 구분 | 신규 |
| 요구사항 ID | NT-01·NFR-04 |
| 입력값(테스트 데이터) | 정원 마감 참가, 일반 참가·취소, Outbox 실패 |
| 기대 결과(대표 검증 내용) | joined+CLOSED 계약 저장, 불필요한 상태 이벤트 없음, Outbox 실패 시 업무 변경 롤백 |
| 실행 수 | 5 |
| 통과 | 5 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-14 — 참가 Saga 설정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-14 |
| 서비스 | match-service |
| 테스트 클래스 | ParticipationSagaConfigurationTest |
| 검증 대상 | 참가 Saga 설정 |
| 구분 | 신규 |
| 요구사항 ID | PT-02 |
| 입력값(테스트 데이터) | Saga 활성 설정 |
| 기대 결과(대표 검증 내용) | 잠금 Bean 충돌 없음 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-15 — 참가·참가 취소 규칙

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-15 |
| 서비스 | match-service |
| 테스트 클래스 | ParticipationTest |
| 검증 대상 | 참가·참가 취소 규칙 |
| 구분 | 변경 |
| 요구사항 ID | EM-06·EM-07 |
| 입력값(테스트 데이터) | 정원·OWNER·중복·시작/마감 매치 |
| 기대 결과(대표 검증 내용) | 정원 도달 CLOSED·취소 시 재개, OWNER·중복 참가 불가, OWNER 취소 불가, 시작·마감 매치 참가 거절 |
| 실행 수 | 13 |
| 통과 | 13 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-16 — 시작 하루 전 이벤트

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-16 |
| 서비스 | match-service |
| 테스트 클래스 | StartingSoonTest |
| 검증 대상 | 시작 하루 전 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | EM-12 |
| 입력값(테스트 데이터) | 24시간 이내 시작 매치 |
| 기대 결과(대표 검증 내용) | 매치당 1회 발행, 취소·시작 매치 제외, 대상은 방장·확정 참가자(대기자 제외) |
| 실행 수 | 12 |
| 통과 | 12 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-17 — DB 경계

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-17 |
| 서비스 | match-service |
| 테스트 클래스 | MatchPersistenceTest |
| 검증 대상 | DB 경계 |
| 구분 | 신규 |
| 요구사항 ID | MSA-8 |
| 입력값(테스트 데이터) | 다른 서비스 ID 컬럼, 대기열 FK |
| 기대 결과(대표 검증 내용) | user·facility ID는 값만 저장(물리 FK 없음), 대기열은 로컬 FK |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-18 — 모임·참가 통계 API

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-18 |
| 서비스 | match-service |
| 테스트 클래스 | MatchStatsTest |
| 검증 대상 | 모임·참가 통계 API |
| 구분 | 신규 |
| 요구사항 ID | AD-01 |
| 입력값(테스트 데이터) | ADMIN/USER/무인증 요청 |
| 기대 결과(대표 검증 내용) | 빈 통계 0, 상태별·참가 집계(대기열 제외), USER 403·무인증 401 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-19 — 대기열·자동 승급

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-19 |
| 서비스 | match-service |
| 테스트 클래스 | WaitlistTest |
| 검증 대상 | 대기열·자동 승급 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·WL-02 |
| 입력값(테스트 데이터) | 정원 찬 매치 대기 등록/취소 |
| 기대 결과(대표 검증 내용) | 201·순번, OWNER·참가자·중복·미마감 거절, 성별·비활성 거절, FIFO 1명 승급·waitlist-promoted |
| 실행 수 | 15 |
| 통과 | 15 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-20 — 회원 잠금

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-20 |
| 서비스 | match-service |
| 테스트 클래스 | MemberLocksTest |
| 검증 대상 | 회원 잠금 |
| 구분 | 신규 |
| 요구사항 ID | NFR-03 |
| 입력값(테스트 데이터) | 잠금 함수 결과 0/NULL/DB 오류 |
| 기대 결과(대표 검증 내용) | 0만 잠금 시간 초과로 보고, DB 오류 원인 유지 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-21 — 탈퇴 DLT 실제 브로커

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-21 |
| 서비스 | match-service |
| 테스트 클래스 | WithdrawalDltBrokerTest |
| 검증 대상 | 탈퇴 DLT 실제 브로커 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| 입력값(테스트 데이터) | 실제 Kafka 브로커(CI 미제공) |
| 기대 결과(대표 검증 내용) | 원본 파티션 7 → 단일 파티션 DLT 발행 |
| 실행 수 | 1 |
| 통과 | 0 |
| 실패 | 0 |
| 건너뜀 | 1 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) · 실제 서비스/브로커가 있어야 도는 테스트라 CI에서 전부 건너뜀 |

### UT-MT-22 — 탈퇴 Saga health 설정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-22 |
| 서비스 | match-service |
| 테스트 클래스 | WithdrawalHealthConfigurationTest |
| 검증 대상 | 탈퇴 Saga health 설정 |
| 구분 | 신규 |
| 요구사항 ID | NFR-03 |
| 입력값(테스트 데이터) | Saga on/off |
| 기대 결과(대표 검증 내용) | 비활성에도 DB health 포함 |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-23 — 탈퇴 Kafka 설정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-23 |
| 서비스 | match-service |
| 테스트 클래스 | WithdrawalKafkaConfigurationTest |
| 검증 대상 | 탈퇴 Kafka 설정 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| 입력값(테스트 데이터) | 원본 파티션 > DLT 파티션 |
| 기대 결과(대표 검증 내용) | DLT 파티션 수 불일치 허용 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-24 — match 탈퇴 Outbox 릴레이

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-24 |
| 서비스 | match-service |
| 테스트 클래스 | WithdrawalOutboxRelayTest |
| 검증 대상 | match 탈퇴 Outbox 릴레이 |
| 구분 | 신규 |
| 요구사항 ID | NFR-03·NFR-04 |
| 입력값(테스트 데이터) | 발행 성공/실패/타임아웃 |
| 기대 결과(대표 검증 내용) | ack 후 발행 표시, 실패 행 미발행·다음 회원 계속, 타임아웃 시 다음 주기 재시도 |
| 실행 수 | 9 |
| 통과 | 9 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-MT-25 — 탈퇴 정리 처리

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-MT-25 |
| 서비스 | match-service |
| 테스트 클래스 | WithdrawalProcessorTest |
| 검증 대상 | 탈퇴 정리 처리 |
| 구분 | 신규 |
| 요구사항 ID | EM-13·NFR-03 |
| 입력값(테스트 데이터) | 탈퇴 요청 이벤트(방장/참가/대기/진행 중 방장) |
| 기대 결과(대표 검증 내용) | 자기 테이블만 정리, 진행 중 방장 거절(무변경), 만료 요청 거절, 마감 초과 시 롤백, 중복 요청 결과 1건 |
| 실행 수 | 19 |
| 통과 | 19 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-01 — 알림 이벤트 소비

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-01 |
| 서비스 | notification-service |
| 테스트 클래스 | MatchEventConsumerTest |
| 검증 대상 | 알림 이벤트 소비 |
| 구분 | 신규 |
| 요구사항 ID | NT-01·NT-02·NFR-04 |
| 입력값(테스트 데이터) | joined·탈퇴·승급·하루 전 이벤트, 깨진 메시지 |
| 기대 결과(대표 검증 내용) | 같은 이벤트 1회 저장, 깨진 메시지 DLT, 실패 3회 재시도 후 DLT |
| 실행 수 | 6 |
| 통과 | 6 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-02 — 알림함 API

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-02 |
| 서비스 | notification-service |
| 테스트 클래스 | NotificationApiTest |
| 검증 대상 | 알림함 API |
| 구분 | 신규 |
| 요구사항 ID | NT-03 |
| 입력값(테스트 데이터) | X-User-Id, 내/타인 알림 ID |
| 기대 결과(대표 검증 내용) | 내 알림 최신순 최대 50건, 읽음 처리 readAt 유지, 타인 알림 거절, 잘못된 ID 처리, 헤더 없음 401 |
| 실행 수 | 8 |
| 통과 | 8 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-03 — notification 공통 에러 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-03 |
| 서비스 | notification-service |
| 테스트 클래스 | NotificationErrorResponseTest |
| 검증 대상 | notification 공통 에러 응답 |
| 구분 | 신규 |
| 요구사항 ID | NFR-06 |
| 입력값(테스트 데이터) | 예외 유발 요청 |
| 기대 결과(대표 검증 내용) | 500 {code,message}, 404·405 유지 |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-04 — 알림 대상 결정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-04 |
| 서비스 | notification-service |
| 테스트 클래스 | NotificationEventServiceTest |
| 검증 대상 | 알림 대상 결정 |
| 구분 | 신규 |
| 요구사항 ID | NT-01 |
| 입력값(테스트 데이터) | joined·취소·마감 이벤트 |
| 기대 결과(대표 검증 내용) | 참가자·방장 알림, 방장 참가 1회, 같은 eventId 1회, 취소 사유 표시(코드형 사유 숨김), 마감은 방장만 |
| 실행 수 | 18 |
| 통과 | 18 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-05 — 알림 처리 지표

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-05 |
| 서비스 | notification-service |
| 테스트 클래스 | NotificationProcessingMetricsTest |
| 검증 대상 | 알림 처리 지표 |
| 구분 | 신규 |
| 요구사항 ID | MON-1 |
| 입력값(테스트 데이터) | 신규·중복·동시 이벤트 |
| 기대 결과(대표 검증 내용) | 커밋 후 1회 집계, 중복·롤백 미집계, 5개 토픽 구분 |
| 실행 수 | 10 |
| 통과 | 10 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-06 — 하루 전 알림 저장

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-06 |
| 서비스 | notification-service |
| 테스트 클래스 | StartingSoonNotificationTest |
| 검증 대상 | 하루 전 알림 저장 |
| 구분 | 신규 |
| 요구사항 ID | NT-02 |
| 입력값(테스트 데이터) | starting-soon 이벤트(시간대 포함) |
| 기대 결과(대표 검증 내용) | 내일/오늘/날짜 문구, 서울 시간 변환, 회원·매치당 1회, 취소 매치 제외 |
| 실행 수 | 16 |
| 통과 | 16 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-NT-07 — DLT 발행 처리

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-NT-07 |
| 서비스 | notification-service |
| 테스트 클래스 | KafkaErrorHandlerConfigTest |
| 검증 대상 | DLT 발행 처리 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| 입력값(테스트 데이터) | DLT 전송 ack/실패/지연 |
| 기대 결과(대표 검증 내용) | 브로커 ack 후에만 집계, 원본 경로·payload 유지, 재발행 없음 |
| 실행 수 | 5 |
| 통과 | 5 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-01 — 회원가입·포인트 조회 API

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-01 |
| 서비스 | user-service |
| 테스트 클래스 | UserApiTest |
| 검증 대상 | 회원가입·포인트 조회 API |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-05 |
| 입력값(테스트 데이터) | 가입 body, 중복 이메일·닉네임, 잘못된 JSON |
| 기대 결과(대표 검증 내용) | 암호화 저장·프로필·선호 종목·role USER, 중복 409 DUPLICATE_EMAIL/DUPLICATE_NICKNAME, 400 INVALID_INPUT, 포인트·이력 조회·페이징 검증 |
| 실행 수 | 16 |
| 통과 | 16 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-02 — 관리자 초기 계정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-02 |
| 서비스 | user-service |
| 테스트 클래스 | AdminAccountTest |
| 검증 대상 | 관리자 초기 계정 |
| 구분 | 신규 |
| 요구사항 ID | USR-07 |
| 입력값(테스트 데이터) | 관리자 이메일·비밀번호 설정값 |
| 기대 결과(대표 검증 내용) | 기동 시 1회 생성·재실행 중복 없음, 값 누락·잘못된 값은 생성 안 함, 기존 회원 승격 없음 |
| 실행 수 | 7 |
| 통과 | 7 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-03 — 탈퇴 Saga 통계 API

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-03 |
| 서비스 | user-service |
| 테스트 클래스 | AdminStatsApiTest |
| 검증 대상 | 탈퇴 Saga 통계 API |
| 구분 | 신규 |
| 요구사항 ID | AD-02 |
| 입력값(테스트 데이터) | ADMIN/USER/무인증 |
| 기대 결과(대표 검증 내용) | 상태별 Saga·회원 집계, USER 403·무인증 401 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-04 — 토큰 재발급

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-04 |
| 서비스 | user-service |
| 테스트 클래스 | TokenRefreshTest |
| 검증 대상 | 토큰 재발급 |
| 구분 | 1차 |
| 요구사항 ID | USR-05 |
| 입력값(테스트 데이터) | 유효/만료/위조/Access/교체된 Refresh, 비활성 회원 |
| 기대 결과(대표 검증 내용) | Redis 일치 시 재발급·role 유지, 그 외 401 INVALID_REFRESH_TOKEN, 탈퇴 중·탈퇴 회원 거절 |
| 실행 수 | 15 |
| 통과 | 15 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-05 — 보증금 소비 재시도

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-05 |
| 서비스 | user-service |
| 테스트 클래스 | DepositEventConsumerRetryTest |
| 검증 대상 | 보증금 소비 재시도 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| 입력값(테스트 데이터) | 일시적 IllegalState |
| 기대 결과(대표 검증 내용) | 재시도 가능 상태로 남김 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-06 — 보증금 이벤트 처리

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-06 |
| 서비스 | user-service |
| 테스트 클래스 | DepositEventConsumerTest |
| 검증 대상 | 보증금 이벤트 처리 |
| 구분 | 신규 |
| 요구사항 ID | PT-02·PT-06 |
| 입력값(테스트 데이터) | charge/refund/attendance 이벤트 |
| 기대 결과(대표 검증 내용) | 차감 성공 deposit-charged, 잔액 부족 INSUFFICIENT_POINTS·정지 PARTICIPATION_SUSPENDED 거절, 탈퇴 회원 거절·늦은 반환 0점, 노쇼 몰수 후 반환 0점 |
| 실행 수 | 15 |
| 통과 | 15 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-07 — 보증금 Kafka

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-07 |
| 서비스 | user-service |
| 테스트 클래스 | DepositKafkaTest |
| 검증 대상 | 보증금 Kafka |
| 구분 | 신규 |
| 요구사항 ID | PT-02·NFR-04 |
| 입력값(테스트 데이터) | 차감 요청, 필수 필드 없는 이벤트 |
| 기대 결과(대표 검증 내용) | 차감 처리 후 charged 발행, 필수 필드 누락은 DLT |
| 실행 수 | 2 |
| 통과 | 2 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-08 — 정산 롤백

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-08 |
| 서비스 | user-service |
| 테스트 클래스 | DepositRollbackTest |
| 검증 대상 | 정산 롤백 |
| 구분 | 신규 |
| 요구사항 ID | PT-06 |
| 입력값(테스트 데이터) | 직렬화 실패 주입 |
| 기대 결과(대표 검증 내용) | 정산 롤백, 재시도 시 1회만 발행 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-09 — 정지 해제 보정

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-09 |
| 서비스 | user-service |
| 테스트 클래스 | PointExpiryCatchUpTest |
| 검증 대상 | 정지 해제 보정 |
| 구분 | 신규 |
| 요구사항 ID | PT-04 |
| 입력값(테스트 데이터) | 놓친 해제 시각 |
| 기대 결과(대표 검증 내용) | 기동 시 해제 보정·30점 복구, 잔액·이력·I1 조회가 먼저 반영, 유효 정지는 유지 |
| 실행 수 | 5 |
| 통과 | 5 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-10 — 정지 해제 스케줄러

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-10 |
| 서비스 | user-service |
| 테스트 클래스 | PointExpirySchedulerTest |
| 검증 대상 | 정지 해제 스케줄러 |
| 구분 | 신규 |
| 요구사항 ID | PT-04 |
| 입력값(테스트 데이터) | 잠긴 회원 1명 |
| 기대 결과(대표 검증 내용) | 다른 회원 해제 계속 |
| 실행 수 | 1 |
| 통과 | 1 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-11 — 포인트 정산 규칙

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-11 |
| 서비스 | user-service |
| 테스트 클래스 | PointSettlementTest |
| 검증 대상 | 포인트 정산 규칙 |
| 구분 | 신규 |
| 요구사항 ID | PT-03·PT-04·PT-06 |
| 입력값(테스트 데이터) | eventId가 다른 재전달, 5회 출석, 0점 노쇼, 동시 차감 |
| 기대 결과(대표 검증 내용) | 차감·반환 1회, 5회마다 10점(상한 100), 0점 노쇼 정지 1회·해제 30점, 마지막 10점 동시 차감 1회, 선취소 후 차감 차단 |
| 실행 수 | 8 |
| 통과 | 8 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-12 — 가입·수정 중복 경쟁

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-12 |
| 서비스 | user-service |
| 테스트 클래스 | DuplicateRaceTest |
| 검증 대상 | 가입·수정 중복 경쟁 |
| 구분 | 1차 |
| 요구사항 ID | USR-01·PR-01 |
| 입력값(테스트 데이터) | 검사 후 선점된 이메일·닉네임 |
| 기대 결과(대표 검증 내용) | 500이 아닌 409 DUPLICATE_EMAIL/NICKNAME, 사용자 롤백 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-13 — 내부 회원 조회 I1·I2

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-13 |
| 서비스 | user-service |
| 테스트 클래스 | InternalUserApiTest |
| 검증 대상 | 내부 회원 조회 I1·I2 |
| 구분 | 신규 |
| 요구사항 ID | USR-08 |
| 입력값(테스트 데이터) | 회원 ID, CSV ID 목록 |
| 기대 결과(대표 검증 내용) | 성별·상태·자치구·종목·suspendedUntil(KST), 탈퇴 상태도 200, 없는 ID 404 USER_NOT_FOUND, 숫자 아님 400, 닉네임 일괄 조회 |
| 실행 수 | 11 |
| 통과 | 11 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-14 — user 탈퇴 Outbox 릴레이

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-14 |
| 서비스 | user-service |
| 테스트 클래스 | WithdrawalOutboxRelayTest |
| 검증 대상 | user 탈퇴 Outbox 릴레이 |
| 구분 | 신규 |
| 요구사항 ID | NFR-03·NFR-04 |
| 입력값(테스트 데이터) | 발행 대기 행 |
| 기대 결과(대표 검증 내용) | userId 키로 발행·ack 후 표시, 실패 행 대기 유지 |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-15 — 탈퇴 Saga Kafka

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-15 |
| 서비스 | user-service |
| 테스트 클래스 | WithdrawalSagaKafkaTest |
| 검증 대상 | 탈퇴 Saga Kafka |
| 구분 | 신규 |
| 요구사항 ID | USR-04·NFR-03 |
| 입력값(테스트 데이터) | 요청·CLEANED·REJECTED·깨진 결과 |
| 기대 결과(대표 검증 내용) | CLEANED→WITHDRAWN, REJECTED→ACTIVE 복구, 깨진 결과 DLT |
| 실행 수 | 3 |
| 통과 | 3 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-US-16 — 탈퇴 Saga 상태

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-US-16 |
| 서비스 | user-service |
| 테스트 클래스 | WithdrawalSagaTest |
| 검증 대상 | 탈퇴 Saga 상태 |
| 구분 | 변경 |
| 요구사항 ID | USR-04·NFR-03 |
| 입력값(테스트 데이터) | 비밀번호 일치/불일치, 결과 이벤트 |
| 기대 결과(대표 검증 내용) | Saga·요청 이벤트 한 트랜잭션 저장, 진행 중 재요청 409, 비밀번호 오류 무변경, 같은 결과 1회 적용 |
| 실행 수 | 19 |
| 통과 | 19 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | CI run 41666137412 (backend 96357e5) |

### UT-FE-01 — React 화면·API 호출 단위

| 항목 | 내용 |
| --- | --- |
| TC ID | UT-FE-01 |
| 서비스 | frontend |
| 테스트 클래스 | Jest 43 suites |
| 검증 대상 | React 화면·API 호출 단위 |
| 구분 | 변경 |
| 요구사항 ID | UI-01·UI-02·UI-03·UI-04·UI-05·AD-04 |
| 입력값(테스트 데이터) | Jest + Testing Library, API 모킹 |
| 기대 결과(대표 검증 내용) | 화면 렌더링·Gateway 경로 호출·상태 표시 단위 검증 (suite 43개) |
| 실행 수 | 550 |
| 통과 | 550 |
| 실패 | 0 |
| 건너뜀 | 0 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 실행자 | GitHub Actions CI |
| 근거·비고 | frontend CI run 41633124978 (frontend 8b6bc9e) "Tests: 550 passed" |

## 통합 테스트(IT)

### IT-USR-01 — 회원가입과 초기 포인트

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-01 |
| 영역 | 회원 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01 |
| API·대상 | POST /user-service/api/users |
| 유형 | 정상 |
| 테스트 항목 | 회원가입과 초기 포인트 |
| 사전 조건 | 미가입 이메일 |
| 입력값(테스트 데이터) | {email:new01@test.io, password:Test1234!, nickname:새회원01, gender:MALE, district:GANGNAM, sportTypes:[FUTSAL]} |
| 테스트 절차 | 1) Gateway로 가입 호출 2) GET /users/me/points 3) DB user·profile·preference·point_history 확인 |
| 기대 결과 | 201 · user+profile+선호 종목 생성, role USER / 포인트 50점, 이력 1건 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-01 |

### IT-USR-02 — 중복 이메일·닉네임

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-02 |
| 영역 | 회원 |
| 구분 | 1차 |
| 요구사항 ID | USR-01 |
| API·대상 | POST /user-service/api/users |
| 유형 | 예외 |
| 테스트 항목 | 중복 이메일·닉네임 |
| 사전 조건 | IT-USR-01 가입 완료 |
| 입력값(테스트 데이터) | 같은 email 또는 같은 nickname |
| 테스트 절차 | 1) 중복 email로 가입 2) 중복 nickname으로 가입 |
| 기대 결과 | 409 DUPLICATE_EMAIL / 409 DUPLICATE_NICKNAME · 기존 레코드 불변 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-01·UT-US-12 (CI P) |
| 비고(원 ID 등) | 원 ID TC-USR-02 |

### IT-USR-03 — JWT 로그인

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-03 |
| 영역 | 인증 |
| 구분 | 1차 |
| 요구사항 ID | USR-02 |
| API·대상 | POST /user-service/api/auth/login |
| 유형 | 정상 |
| 테스트 항목 | JWT 로그인 |
| 사전 조건 | ACTIVE 회원 |
| 입력값(테스트 데이터) | {email, password} 올바른 값 |
| 테스트 절차 | 1) 로그인 2) Redis Refresh TTL 확인 |
| 기대 결과 | 200 · accessToken·refreshToken 발급, Access에 role 포함, Redis Refresh 저장 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-03 |

### IT-USR-04 — 틀린 비밀번호

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-04 |
| 영역 | 인증 |
| 구분 | 1차 |
| 요구사항 ID | USR-02 |
| API·대상 | POST /user-service/api/auth/login |
| 유형 | 예외 |
| 테스트 항목 | 틀린 비밀번호 |
| 사전 조건 | ACTIVE 회원 |
| 입력값(테스트 데이터) | password=Wrong999! |
| 테스트 절차 | 1) 틀린 비밀번호로 로그인 |
| 기대 결과 | 401 · 토큰 발급 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-04 |

### IT-USR-05 — 탈퇴 중·탈퇴 회원 로그인 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-05 |
| 영역 | 인증 |
| 구분 | 변경 |
| 요구사항 ID | USR-02·USR-04 |
| API·대상 | POST /user-service/api/auth/login |
| 유형 | 예외 |
| 테스트 항목 | 탈퇴 중·탈퇴 회원 로그인 차단 |
| 사전 조건 | status WITHDRAWING 또는 WITHDRAWN 회원 |
| 입력값(테스트 데이터) | 해당 회원 email/password |
| 테스트 절차 | 1) 로그인 시도 |
| 기대 결과 | 401 · Refresh 발급 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-09 |

### IT-USR-06 — 로그아웃 토큰 폐기

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-06 |
| 영역 | 인증 |
| 구분 | 1차 |
| 요구사항 ID | USR-03 |
| API·대상 | POST /user-service/api/auth/logout |
| 유형 | 정상 |
| 테스트 항목 | 로그아웃 토큰 폐기 |
| 사전 조건 | 로그인 완료 |
| 입력값(테스트 데이터) | Bearer 유효 Access |
| 테스트 절차 | 1) 로그아웃 2) 같은 Refresh로 재발급 |
| 기대 결과 | 204 / 재발급 401 · Redis Refresh 삭제 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-05 |

### IT-USR-07 — Refresh 갱신·만료

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-07 |
| 영역 | 인증 |
| 구분 | 1차 |
| 요구사항 ID | USR-05 |
| API·대상 | POST /user-service/api/auth/refresh |
| 유형 | 정상·예외 |
| 테스트 항목 | Refresh 갱신·만료 |
| 사전 조건 | Refresh 보유 |
| 입력값(테스트 데이터) | 유효 Refresh / 만료 Refresh / Access 토큰 |
| 테스트 절차 | 1) 유효 Refresh 재발급 2) 만료·Access 토큰으로 재발급 |
| 기대 결과 | 200 새 토큰 / 401 INVALID_REFRESH_TOKEN |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-04 (CI P) |
| 비고(원 ID 등) | 원 ID TC-USR-07 |

### IT-USR-08 — 내 정보·개인정보 경계

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-08 |
| 영역 | 회원 |
| 구분 | 1차 |
| 요구사항 ID | USR-06 |
| API·대상 | GET /user-service/api/users/me |
| 유형 | 정상·예외 |
| 테스트 항목 | 내 정보·개인정보 경계 |
| 사전 조건 | ACTIVE 회원 |
| 입력값(테스트 데이터) | Bearer 유효 / 없음 |
| 테스트 절차 | 1) 토큰으로 조회 2) 토큰 없이 조회 |
| 기대 결과 | 200 · password 없음 / 401 UNAUTHORIZED |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-USR-08 |

### IT-USR-09 — 프로필 수정·닉네임 중복

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-09 |
| 영역 | 프로필 |
| 구분 | 1차 |
| 요구사항 ID | PR-01 |
| API·대상 | PUT /user-service/api/profiles/me |
| 유형 | 정상·예외 |
| 테스트 항목 | 프로필 수정·닉네임 중복 |
| 사전 조건 | 로그인 |
| 입력값(테스트 데이터) | {nickname, district, sportTypes} |
| 테스트 절차 | 1) 수정 2) 다른 회원 닉네임으로 수정 |
| 기대 결과 | 200 · DB 반영 / 409 DUPLICATE_NICKNAME |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-PR-01 |

### IT-USR-10 — 타인 프로필 수정 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-10 |
| 영역 | 프로필 |
| 구분 | 1차 |
| 요구사항 ID | PR-01 |
| API·대상 | PUT /user-service/api/profiles/me |
| 유형 | 예외 |
| 테스트 항목 | 타인 프로필 수정 차단 |
| 사전 조건 | 회원 A·B |
| 입력값(테스트 데이터) | A 토큰 + B를 가리키는 body/헤더 위조 |
| 테스트 절차 | 1) A 토큰으로 B 정보 변경 시도 |
| 기대 결과 | B 정보 불변 (수정 대상은 Gateway가 넘긴 X-User-Id 본인만) |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-PR-03 |

### IT-USR-11 — 프로필 조회 공개 범위

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-11 |
| 영역 | 프로필 |
| 구분 | 1차 |
| 요구사항 ID | PR-02 |
| API·대상 | GET /user-service/api/profiles/{profileId} |
| 유형 | 정상·예외 |
| 테스트 항목 | 프로필 조회 공개 범위 |
| 사전 조건 | 프로필 1개 |
| 입력값(테스트 데이터) | 존재 ID / 999999 |
| 테스트 절차 | 1) 조회 2) 없는 ID 조회 |
| 기대 결과 | 200 · email·password 없음 / 404 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-PR-02 |

### IT-USR-12 — 탈퇴 요청 접수

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-12 |
| 영역 | 회원 |
| 구분 | 변경 |
| 요구사항 ID | USR-04 |
| API·대상 | DELETE /user-service/api/users/me |
| 유형 | 정상·예외 |
| 테스트 항목 | 탈퇴 요청 접수 |
| 사전 조건 | ACTIVE 회원 |
| 입력값(테스트 데이터) | {password} 올바른 값 / 틀린 값 |
| 테스트 절차 | 1) 틀린 비밀번호로 요청 2) 올바른 비밀번호로 요청 |
| 기대 결과 | 틀린 값: 거절·상태 ACTIVE 유지 / 202 {status:"WITHDRAWING", sagaId} · withdrawal_saga PROCESSING |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-16 (CI P) |
| 비고(원 ID 등) | 원 ID TC-USR-06. Saga 최종 결과는 ST-SAGA |

### IT-USR-13 — 탈퇴 진행 중 재요청

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-USR-13 |
| 영역 | 회원 |
| 구분 | 신규 |
| 요구사항 ID | USR-04 |
| API·대상 | DELETE /user-service/api/users/me |
| 유형 | 예외 |
| 테스트 항목 | 탈퇴 진행 중 재요청 |
| 사전 조건 | WITHDRAWING 회원 |
| 입력값(테스트 데이터) | {password} |
| 테스트 절차 | 1) 탈퇴 요청 직후 한 번 더 요청 |
| 기대 결과 | 409 WITHDRAWAL_IN_PROGRESS · Saga 1건 유지 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-16 (CI P) |

### IT-PT-01 — 내 포인트 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-PT-01 |
| 영역 | 포인트 |
| 구분 | 신규 |
| 요구사항 ID | PT-01·PT-05 |
| API·대상 | GET /user-service/api/users/me/points |
| 유형 | 정상·예외 |
| 테스트 항목 | 내 포인트 조회 |
| 사전 조건 | 가입 직후 회원 |
| 입력값(테스트 데이터) | Bearer 유효 / 없음 |
| 테스트 절차 | 1) 조회 2) 토큰 없이 조회 |
| 기대 결과 | 200 · points 50, 누적 출석 0, 정지 종료 null / 401 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-01 (CI P) |

### IT-PT-02 — 포인트 이력 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-PT-02 |
| 영역 | 포인트 |
| 구분 | 신규 |
| 요구사항 ID | PT-05 |
| API·대상 | GET /user-service/api/users/me/points/history |
| 유형 | 정상·예외 |
| 테스트 항목 | 포인트 이력 조회 |
| 사전 조건 | 차감 이력 1건 이상 |
| 입력값(테스트 데이터) | page=0&size=20 / size=0 |
| 테스트 절차 | 1) 이력 조회 2) 잘못된 페이지 값 |
| 기대 결과 | 200 · 최신순 reason·delta(DEPOSIT_CHARGED -10 등) / 400 INVALID_INPUT |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-01 (CI P) |

### IT-GW-01 — 서비스명 경로 라우팅

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-01 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-01·MSA-3·UI-01 |
| API·대상 | /<서비스명>/** 전체 |
| 유형 | 정상 |
| 테스트 항목 | 서비스명 경로 라우팅 |
| 사전 조건 | 전체 서비스 기동 |
| 입력값(테스트 데이터) | user·match·facility·ai·notification 대표 GET |
| 테스트 절차 | 1) Gateway 8000으로 서비스별 대표 API 호출 |
| 기대 결과 | 5개 서비스 모두 2xx, 서비스명 접두어 제거 후 전달 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-03. health 라우팅은 ST-DEP-01에서 P |

### IT-GW-02 — 내부·actuator 경로 외부 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-02 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-04·NFR-05 |
| API·대상 | /internal/**, /actuator/** |
| 유형 | 예외 |
| 테스트 항목 | 내부·actuator 경로 외부 차단 |
| 사전 조건 | Gateway 실행 |
| 입력값(테스트 데이터) | GET /user-service/internal/users/1, GET /match-service/actuator/env |
| 테스트 절차 | 1) Gateway로 내부 경로 호출 2) actuator 호출 |
| 기대 결과 | 403 FORBIDDEN · 서비스까지 전달 안 됨 (공개 health는 200) |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-03 (CI P) |
| 비고(원 ID 등) | 원 ID TC-MSA-04 |

### IT-GW-03 — JWT 위조·만료

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-03 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-02·NFR-05 |
| API·대상 | 비공개 API 전체 |
| 유형 | 예외 |
| 테스트 항목 | JWT 위조·만료 |
| 사전 조건 | 서비스 운영 |
| 입력값(테스트 데이터) | 서명 위조 토큰, 만료 토큰, "Token xxx" |
| 테스트 절차 | 1) 각 토큰으로 GET /user-service/api/users/me |
| 기대 결과 | 401 UNAUTHORIZED |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-02 (CI P) |
| 비고(원 ID 등) | 원 ID TC-QA-02 |

### IT-GW-04 — 클라이언트 X-User-Id 위조 제거

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-04 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-02 |
| API·대상 | 공개·비공개 API |
| 유형 | 예외 |
| 테스트 항목 | 클라이언트 X-User-Id 위조 제거 |
| 사전 조건 | 회원 A 토큰 |
| 입력값(테스트 데이터) | 헤더 X-User-Id: 2, X-User-Role: ADMIN |
| 테스트 절차 | 1) A 토큰 + 위조 헤더로 /users/me 2) 무토큰 + 위조 헤더로 공개 목록 |
| 기대 결과 | A 본인 정보만 반환 / 공개 경로에도 위조 헤더 전달 안 됨 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-02 (CI P) |

### IT-GW-05 — 경로 우회 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-05 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-04 |
| API·대상 | ".." 포함 경로 |
| 유형 | 예외 |
| 테스트 항목 | 경로 우회 차단 |
| 사전 조건 | Gateway 실행 |
| 입력값(테스트 데이터) | GET /match-service/api/../internal/withdrawals/1 |
| 테스트 절차 | 1) 호출 |
| 기대 결과 | 400 INVALID_PATH |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-01 (CI P) |

### IT-GW-06 — 관리자 경로 USER 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-06 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-03·USR-07 |
| API·대상 | /<서비스>/api/admin/**, /prometheus/** |
| 유형 | 예외 |
| 테스트 항목 | 관리자 경로 USER 차단 |
| 사전 조건 | USER 토큰, ADMIN 토큰 |
| 입력값(테스트 데이터) | GET /match-service/api/admin/stats |
| 테스트 절차 | 1) USER 토큰 호출 2) ADMIN 토큰 호출 |
| 기대 결과 | 403 FORBIDDEN / 200 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-02 (CI P) |

### IT-GW-07 — CORS 허용 origin

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-GW-07 |
| 영역 | Gateway |
| 구분 | 신규 |
| 요구사항 ID | GW-05 |
| API·대상 | OPTIONS preflight |
| 유형 | 정상·예외 |
| 테스트 항목 | CORS 허용 origin |
| 사전 조건 | Config의 허용 origin |
| 입력값(테스트 데이터) | Origin: 프론트 주소 / Origin: http://evil.test |
| 테스트 절차 | 1) preflight 요청 |
| 기대 결과 | 허용 origin만 Access-Control-Allow-Origin 응답 |
| 결과 | 미실행 |

### IT-EM-01 — 매치 생성 접수·확정

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-01 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-01·PT-02·EM-10·MSA-7 |
| API·대상 | POST /match-service/api/matches |
| 유형 | 정상 |
| 테스트 항목 | 매치 생성 접수·확정 |
| 사전 조건 | 50점 ACTIVE 회원, 활성 시설(운영시간 내) |
| 입력값(테스트 데이터) | {serviceId, sportType:FUTSAL, startAt:2026-11-08T19:00:00, endAt:21:00, maxParticipant:10, genderGroup:MIXED, skillLevel:BEGINNER} |
| 테스트 절차 | 1) 생성 2) GET /matches/requests/{requestId} 확정까지 조회 3) DB·포인트 확인 |
| 기대 결과 | 202 {requestId, matchId, status:"PENDING"} → CONFIRMED, 매치 RECRUITING·OWNER 1건, 10점 1회 차감(50→40) |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-01. 같은 흐름이 ST-POINT-01에서 P(단독 실행 기록 없음) |

### IT-EM-02 — 없는·비활성 시설

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-02 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-01·FC-04 |
| API·대상 | POST /match-service/api/matches |
| 유형 | 예외 |
| 테스트 항목 | 없는·비활성 시설 |
| 사전 조건 | 시설 ID 없음/비활성 |
| 입력값(테스트 데이터) | serviceId=999999 / 비활성 serviceId |
| 테스트 절차 | 1) 생성 2) match_db 확인 |
| 기대 결과 | 404 / FACILITY_INACTIVE 거절 · match·participant 0건 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-02 |

### IT-EM-03 — 정원 1명 생성·수정 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-03 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-01·EM-04 |
| API·대상 | POST·PUT /match-service/api/matches |
| 유형 | 예외 |
| 테스트 항목 | 정원 1명 생성·수정 거절 |
| 사전 조건 | ACTIVE 방장, 유효 시설 |
| 입력값(테스트 데이터) | maxParticipant=1 |
| 테스트 절차 | 1) 정원 1로 생성 2) 기존 매치를 정원 1로 수정 |
| 기대 결과 | 400 INVALID_INPUT · 생성·변경 없음 / 정원 2는 정상 접수 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-02·UT-MT-06 (CI P) |
| 비고(원 ID 등) | 원 ID TC-EM-18 |

### IT-EM-04 — 시설 서비스 장애 시 생성

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-04 |
| 영역 | 매칭 |
| 구분 | 신규 |
| 요구사항 ID | EM-01·NFR-02 |
| API·대상 | POST /match-service/api/matches |
| 유형 | 예외 |
| 테스트 항목 | 시설 서비스 장애 시 생성 |
| 사전 조건 | facility-service 중지 |
| 입력값(테스트 데이터) | 정상 생성 body |
| 테스트 절차 | 1) 생성 2) DB 확인 |
| 기대 결과 | 503 FACILITY_SERVICE_UNAVAILABLE · match·OWNER 0건, 차감 요청 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-16. 같은 조건이 ST-OBS-01에서 P |

### IT-EM-05 — 다중 AND 필터

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-05 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-02 |
| API·대상 | GET /match-service/api/matches |
| 유형 | 정상 |
| 테스트 항목 | 다중 AND 필터 |
| 사전 조건 | 다양한 매치 시드 |
| 입력값(테스트 데이터) | sportType=FUTSAL&region=강남구&skillLevel=BEGINNER |
| 테스트 절차 | 1) 토큰 없이 목록 조회 |
| 기대 결과 | 200 · sportType·region·skillLevel 세 조건 모두 맞는 매치만, PENDING·CREATION_FAILED 제외 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-03 |

### IT-EM-06 — 잘못된 날짜 범위

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-06 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-02 |
| API·대상 | GET /match-service/api/matches |
| 유형 | 예외 |
| 테스트 항목 | 잘못된 날짜 범위 |
| 사전 조건 | 서버 정상 |
| 입력값(테스트 데이터) | from > to |
| 테스트 절차 | 1) 조회 |
| 기대 결과 | 400 INVALID_INPUT |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-04 |

### IT-EM-07 — 상세 로그인/비로그인

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-07 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-03 |
| API·대상 | GET /match-service/api/matches/{matchId} |
| 유형 | 정상 |
| 테스트 항목 | 상세 로그인/비로그인 |
| 사전 조건 | 매치 존재 |
| 입력값(테스트 데이터) | Bearer 유효 / 없음 |
| 테스트 절차 | 1) 비로그인 조회 2) 로그인 조회 |
| 기대 결과 | 둘 다 200 · 로그인 시 본인 역할 플래그 정확, 시설 스냅샷 표시 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-05 |

### IT-EM-08 — 타인 수정·정원 축소 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-08 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-04 |
| API·대상 | PUT /match-service/api/matches/{matchId} |
| 유형 | 예외 |
| 테스트 항목 | 타인 수정·정원 축소 거절 |
| 사전 조건 | OWNER + 참가자 3명 |
| 입력값(테스트 데이터) | 비OWNER 토큰 / maxParticipant=2 |
| 테스트 절차 | 1) 비OWNER 수정 2) 현재 인원보다 작게 수정 |
| 기대 결과 | 403 MATCH_MODIFY_FORBIDDEN / 400 MATCH_CAPACITY_BELOW_CURRENT · 정보 불변 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-06 |

### IT-EM-09 — 정원 확장 수정

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-09 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-04 |
| API·대상 | PUT /match-service/api/matches/{matchId} |
| 유형 | 정상 |
| 테스트 항목 | 정원 확장 수정 |
| 사전 조건 | 매치·참가자 존재 |
| 입력값(테스트 데이터) | maxParticipant 5→8 |
| 테스트 절차 | 1) 수정 2) 상세 조회 |
| 기대 결과 | 200 · 정원 8, 참가 인원 보존 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-17 |

### IT-EM-10 — 매치 삭제 → 취소 보존

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-10 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-05 |
| API·대상 | DELETE /match-service/api/matches/{matchId} |
| 유형 | 정상 |
| 테스트 항목 | 매치 삭제 → 취소 보존 |
| 사전 조건 | OWNER, 참가자 있음, 시작 전 |
| 입력값(테스트 데이터) | OWNER 토큰 |
| 테스트 절차 | 1) 삭제 2) 상세·DB·알림 확인 |
| 기대 결과 | 204 · 매치 CANCELLED로 남음(하드 삭제 아님), 취소 시각·사유 기록, status-changed 발행, 참가자 보증금 반환 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-07 (원 기대값 "함께 정리"를 결정 사항 CANCELLED 보존으로 보정) |

### IT-EM-11 — 방장 취소

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-11 |
| 영역 | 매칭 |
| 구분 | 신규 |
| 요구사항 ID | EM-05·MSA-7 |
| API·대상 | PATCH /match-service/api/matches/{matchId}/cancel |
| 유형 | 정상·예외 |
| 테스트 항목 | 방장 취소 |
| 사전 조건 | RECRUITING 매치 |
| 입력값(테스트 데이터) | OWNER 토큰 / 비OWNER 토큰 / 시작된 매치 |
| 테스트 절차 | 1) 방장 취소 2) 비OWNER 취소 3) 시작 후 취소 |
| 기대 결과 | 204 CANCELLED / 403 MATCH_CANCEL_FORBIDDEN / 409 MATCH_CANCEL_NOT_ALLOWED |
| 결과 | 미실행 |

### IT-EM-12 — 참가 접수·확정·중복

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-12 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-06·PT-02 |
| API·대상 | POST /match-service/api/matches/{matchId}/participants |
| 유형 | 정상·예외 |
| 테스트 항목 | 참가 접수·확정·중복 |
| 사전 조건 | RECRUITING, 여유 정원, 50점 회원 |
| 입력값(테스트 데이터) | 같은 회원 2회 |
| 테스트 절차 | 1) 참가 2) 요청 상태 조회 3) 같은 회원 재참가 |
| 기대 결과 | 202 PENDING → CONFIRMED / 409 MATCH_ALREADY_JOINED · 중복 확정·차감 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-08 |

### IT-EM-13 — 마지막 1자리 경쟁

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-13 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-06·PT-06 |
| API·대상 | POST /match-service/api/matches/{matchId}/participants |
| 유형 | 동시성 |
| 테스트 항목 | 마지막 1자리 경쟁 |
| 사전 조건 | 남은 정원 1 |
| 입력값(테스트 데이터) | 서로 다른 회원 2명 동시 요청 |
| 테스트 절차 | 1) 동시 참가 2) 각 requestId 최종 상태·원장 |
| 기대 결과 | CONFIRMED 신규 1명 이하, 나머지 FAILED(MATCH_FULL)·반환 완료, 중복 차감 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-04 (CI P) |
| 비고(원 ID 등) | 원 ID TC-EM-09 |

### IT-EM-14 — 정원 포화 재참가

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-14 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-06 |
| API·대상 | POST /match-service/api/matches/{matchId}/participants |
| 유형 | 경계 |
| 테스트 항목 | 정원 포화 재참가 |
| 사전 조건 | current = max (CLOSED) |
| 입력값(테스트 데이터) | 추가 회원 |
| 테스트 절차 | 1) 참가 |
| 기대 결과 | 409 MATCH_FULL 또는 접수 후 FAILED·반환 · 확정 인원 정원 이하 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-12 |

### IT-EM-15 — 마감·시작된 매치 참가 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-15 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-06 |
| API·대상 | POST /match-service/api/matches/{matchId}/participants |
| 유형 | 경계 |
| 테스트 항목 | 마감·시작된 매치 참가 차단 |
| 사전 조건 | CLOSED 또는 startAt < 현재 |
| 입력값(테스트 데이터) | 참가 요청 |
| 테스트 절차 | 1) 참가 |
| 기대 결과 | 409 MATCH_RECRUITMENT_CLOSED / MATCH_ALREADY_STARTED · 미등록 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-15 (CI P) |
| 비고(원 ID 등) | 원 ID TC-EM-13·TC-EM-14 |

### IT-EM-16 — OWNER 재참가 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-16 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-06 |
| API·대상 | POST /match-service/api/matches/{matchId}/participants |
| 유형 | 경계 |
| 테스트 항목 | OWNER 재참가 차단 |
| 사전 조건 | OWNER 자동 등록 |
| 입력값(테스트 데이터) | OWNER 토큰 |
| 테스트 절차 | 1) 참가 |
| 기대 결과 | 409 MATCH_ALREADY_JOINED · 중복 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-15 |

### IT-EM-17 — 참가 취소·OWNER 차단

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-17 |
| 영역 | 매칭 |
| 구분 | 변경 |
| 요구사항 ID | EM-07·PT-02·WL-02 |
| API·대상 | DELETE /match-service/api/matches/{matchId}/participants/me |
| 유형 | 정상·예외 |
| 테스트 항목 | 참가 취소·OWNER 차단 |
| 사전 조건 | CONFIRMED 참가자, OWNER |
| 입력값(테스트 데이터) | 참가자 토큰 / OWNER 토큰 |
| 테스트 절차 | 1) 참가자 취소 2) OWNER 취소 |
| 기대 결과 | 204 · 보증금 반환 요청·대기자 승급 / 409 MATCH_OWNER_CANNOT_LEAVE |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-10 |

### IT-EM-18 — 내 매치만 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-18 |
| 영역 | 매칭 |
| 구분 | 1차 |
| 요구사항 ID | EM-08 |
| API·대상 | GET /match-service/api/matches/me |
| 유형 | 정상 |
| 테스트 항목 | 내 매치만 조회 |
| 사전 조건 | 회원 2명 서로 다른 참가 |
| 입력값(테스트 데이터) | 각 회원 토큰 |
| 테스트 절차 | 1) 각자 조회 |
| 기대 결과 | 200 · 본인 소유·참가 매치만 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-EM-11 |

### IT-EM-19 — 요청 처리 상태 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EM-19 |
| 영역 | 매칭 |
| 구분 | 신규 |
| 요구사항 ID | EM-10 |
| API·대상 | GET /match-service/api/matches/requests/{requestId} |
| 유형 | 정상·예외 |
| 테스트 항목 | 요청 처리 상태 조회 |
| 사전 조건 | 본인 requestId, 타인 requestId |
| 입력값(테스트 데이터) | 본인 / 타인 / 토큰 없음 |
| 테스트 절차 | 1) 본인 조회 2) 타인 조회 3) 무토큰 |
| 기대 결과 | 200 {status, refundStatus, failureCode} / 404 PARTICIPATION_REQUEST_NOT_FOUND / 401 |
| 결과 | 미실행 |

### IT-ATT-01 — 방장 출석 수정

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-01 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | PATCH /match-service/api/matches/{matchId}/participants/{participantId}/attendance |
| 유형 | 정상 |
| 테스트 항목 | 방장 출석 수정 |
| 사전 조건 | 시작 이후·종료 전, CONFIRMED 참가자 |
| 입력값(테스트 데이터) | {matchParticipantStatus:"NO_SHOW"} |
| 테스트 절차 | 1) 방장 PATCH 2) 상세 재조회 |
| 기대 결과 | 204 본문 없음 · DB NO_SHOW, 정산 발행 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-01 |

### IT-ATT-02 — 출석 복구·같은 값 재요청

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-02 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 정상 |
| 테스트 항목 | 출석 복구·같은 값 재요청 |
| 사전 조건 | 수정 가능 시간 |
| 입력값(테스트 데이터) | NO_SHOW→ATTENDED, 같은 요청 반복 |
| 테스트 절차 | 1) 복구 2) 반복 |
| 기대 결과 | 매번 204 · 최종 ATTENDED, 중복 정산 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-02 |

### IT-ATT-03 — 비방장 수정 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-03 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 예외 |
| 테스트 항목 | 비방장 수정 거절 |
| 사전 조건 | 일반 참가자·외부 회원 |
| 입력값(테스트 데이터) | 일반 회원 토큰 |
| 테스트 절차 | 1) PATCH |
| 기대 결과 | 403 FORBIDDEN · 출석 불변 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-03 |

### IT-ATT-04 — 비로그인 수정 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-04 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·GW-02 |
| API·대상 | 출석 PATCH |
| 유형 | 예외 |
| 테스트 항목 | 비로그인 수정 거절 |
| 사전 조건 | Gateway 경유 |
| 입력값(테스트 데이터) | Authorization 없음 |
| 테스트 절차 | 1) PATCH |
| 기대 결과 | 401 · DB 변경 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-04 |

### IT-ATT-05 — 시작·종료 시각 경계

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-05 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 경계 |
| 테스트 항목 | 시작·종료 시각 경계 |
| 사전 조건 | 시간 제어 격리 환경 |
| 입력값(테스트 데이터) | 시작 직전/정각/종료 직전/정각 |
| 테스트 절차 | 1) 시점별 PATCH |
| 기대 결과 | startAt ≤ now < endAt만 204, 나머지 409 ATTENDANCE_UPDATE_NOT_ALLOWED |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-05 |

### IT-ATT-06 — 취소·완료·생성 중 매치

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-06 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 예외 |
| 테스트 항목 | 취소·완료·생성 중 매치 |
| 사전 조건 | CANCELLED/COMPLETED/CREATION_PENDING/CREATION_FAILED |
| 입력값(테스트 데이터) | 유효 방장 토큰 |
| 테스트 절차 | 1) 상태별 PATCH |
| 기대 결과 | 409 ATTENDANCE_UPDATE_NOT_ALLOWED · 출석 불변 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-06 |

### IT-ATT-07 — 잘못된 입력

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-07 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 예외 |
| 테스트 항목 | 잘못된 입력 |
| 사전 조건 | 수정 가능 매치 |
| 입력값(테스트 데이터) | {} / null / "FOO" / {attendance:"NO_SHOW"} |
| 테스트 절차 | 1) 입력별 PATCH |
| 기대 결과 | 400 INVALID_INPUT · DB 변경 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-07 |

### IT-ATT-08 — 다른 매치·비확정 참가자

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-08 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH |
| 유형 | 예외 |
| 테스트 항목 | 다른 매치·비확정 참가자 |
| 사전 조건 | PENDING/FAILED/CANCELLED·다른 매치 참가자 |
| 입력값(테스트 데이터) | 해당 participantId |
| 테스트 절차 | 1) PATCH |
| 기대 결과 | 404 MATCH_PARTICIPANT_NOT_FOUND · 대상 불변 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-08 |

### IT-ATT-09 — 상세 출석 정보 공개 범위

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-ATT-09 |
| 영역 | 출석 |
| 구분 | 신규 |
| 요구사항 ID | EM-03·EM-11 |
| API·대상 | GET /match-service/api/matches/{matchId} |
| 유형 | 보안 |
| 테스트 항목 | 상세 출석 정보 공개 범위 |
| 사전 조건 | 출석값이 있는 매치 |
| 입력값(테스트 데이터) | 방장/참가자/외부/비로그인 |
| 테스트 절차 | 1) 각자 상세 조회 |
| 기대 결과 | CONFIRMED만 명단, participantId 제공, matchParticipantStatus는 방장에게만 값·나머지 null |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-ATT-09 |

### IT-WL-01 — 대기 등록

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-WL-01 |
| 영역 | 대기열 |
| 구분 | 신규 |
| 요구사항 ID | WL-01 |
| API·대상 | POST /match-service/api/matches/{matchId}/waitlist |
| 유형 | 정상 |
| 테스트 항목 | 대기 등록 |
| 사전 조건 | 정원 찬 매치, 비참가 회원 |
| 입력값(테스트 데이터) | 회원 토큰 |
| 테스트 절차 | 1) 대기 등록 2) 포인트 확인 |
| 기대 결과 | 201 · 순번(rank) 반환, 보증금 차감 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-19 (CI P) |

### IT-WL-02 — 대기 등록 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-WL-02 |
| 영역 | 대기열 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·PT-04 |
| API·대상 | POST /match-service/api/matches/{matchId}/waitlist |
| 유형 | 예외 |
| 테스트 항목 | 대기 등록 거절 |
| 사전 조건 | OWNER·참가자·중복·미마감·정지 회원 |
| 입력값(테스트 데이터) | 각 조건 회원 토큰 |
| 테스트 절차 | 1) 조건별 등록 |
| 기대 결과 | 409 MATCH_OWNER_CANNOT_WAIT / MATCH_ALREADY_JOINED / WAITLIST_ALREADY_JOINED / MATCH_NOT_FULL, 정지 PARTICIPATION_SUSPENDED · 행 생성 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-19 (CI P) |

### IT-WL-03 — 대기 취소

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-WL-03 |
| 영역 | 대기열 |
| 구분 | 신규 |
| 요구사항 ID | WL-01 |
| API·대상 | DELETE /match-service/api/matches/{matchId}/waitlist/me |
| 유형 | 정상·예외 |
| 테스트 항목 | 대기 취소 |
| 사전 조건 | 대기 등록자 / 미등록자 |
| 입력값(테스트 데이터) | 각 토큰 |
| 테스트 절차 | 1) 취소 2) 미등록자 취소 |
| 기대 결과 | 204 · 뒤 순번 앞당김 / 404 WAITLIST_NOT_FOUND |
| 결과 | 미실행 |

### IT-WL-04 — 자동 승급

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-WL-04 |
| 영역 | 대기열 |
| 구분 | 신규 |
| 요구사항 ID | WL-02·PT-02·NT-02 |
| API·대상 | 참가 취소 → 승급 |
| 유형 | 정상 |
| 테스트 항목 | 자동 승급 |
| 사전 조건 | 대기자 2명, 확정 참가자 취소 |
| 입력값(테스트 데이터) | 참가자 취소 |
| 테스트 절차 | 1) 참가 취소 2) 1순위 대기자 상태·포인트·알림 |
| 기대 결과 | 1순위만 차감 후 CONFIRMED, waitlist-promoted 발행·알림 1건, 부적격 대기자 건너뜀 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-04·UT-MT-19 (CI P) |

### IT-FC-01 — 시설 필터 검색

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-01 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-01 |
| API·대상 | GET /facility-service/api/services |
| 유형 | 정상 |
| 테스트 항목 | 시설 필터 검색 |
| 사전 조건 | 시설 데이터 시드 |
| 입력값(테스트 데이터) | district=GANGNAM&sportType=FUTSAL |
| 테스트 절차 | 1) 토큰 없이 조회 |
| 기대 결과 | 200 · 조건 일치 활성 시설만 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-FC-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-FC-01 |

### IT-FC-02 — 공공데이터 수집 실패 시 기존 목록

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-02 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-01·FC-03 |
| API·대상 | GET /facility-service/api/services |
| 유형 | 장애 |
| 테스트 항목 | 공공데이터 수집 실패 시 기존 목록 |
| 사전 조건 | DB 기존 데이터 |
| 입력값(테스트 데이터) | 공공 API 500 모의 |
| 테스트 절차 | 1) 동기화 실패 2) 목록 조회 |
| 기대 결과 | 200 기존 목록 · 기존 데이터 불변 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-FC-03 (CI P) |
| 비고(원 ID 등) | 원 ID TC-FC-02 |

### IT-FC-03 — 시설 상세·예약 링크

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-03 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-02 |
| API·대상 | GET /facility-service/api/services/{serviceId} |
| 유형 | 정상 |
| 테스트 항목 | 시설 상세·예약 링크 |
| 사전 조건 | 시설 존재 |
| 입력값(테스트 데이터) | serviceId |
| 테스트 절차 | 1) 상세 조회 |
| 기대 결과 | 200 · 예약 URL 포함, 내부 예약 처리 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-FC-03 |

### IT-FC-04 — 잘못된·없는 시설 ID

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-04 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-02 |
| API·대상 | GET /facility-service/api/services/{serviceId} |
| 유형 | 예외 |
| 테스트 항목 | 잘못된·없는 시설 ID |
| 사전 조건 | 서버 정상 |
| 입력값(테스트 데이터) | abc / 999999 |
| 테스트 절차 | 1) 각각 조회 |
| 기대 결과 | 400 INVALID_SERVICE_ID / 404 · 5xx 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-FC-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-FC-04 |

### IT-FC-05 — 비활성 시설 상세

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-05 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-02 |
| API·대상 | GET /facility-service/api/services/{serviceId} |
| 유형 | 경계 |
| 테스트 항목 | 비활성 시설 상세 |
| 사전 조건 | active=false 시설 |
| 입력값(테스트 데이터) | 비활성 serviceId |
| 테스트 절차 | 1) 상세 조회 |
| 기대 결과 | 404 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-FC-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-FC-05 |

### IT-FC-06 — 공공데이터 일부 값 누락

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-FC-06 |
| 영역 | 시설 |
| 구분 | 1차 |
| 요구사항 ID | FC-02 |
| API·대상 | GET /facility-service/api/services/{serviceId} |
| 유형 | 경계 |
| 테스트 항목 | 공공데이터 일부 값 누락 |
| 사전 조건 | 좌표·연락처 null 시설 |
| 입력값(테스트 데이터) | 해당 serviceId |
| 테스트 절차 | 1) 상세 조회 |
| 기대 결과 | 200 · 빈 값 기본 표기, NPE 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-FC-06 |

### IT-AI-01 — AI 초안 생성·저장 금지

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-01 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-01 |
| API·대상 | POST /ai-service/api/ai/matches |
| 유형 | 정상 |
| 테스트 항목 | AI 초안 생성·저장 금지 |
| 사전 조건 | 로그인 |
| 입력값(테스트 데이터) | {prompt:"토요일 저녁 7시 강남 풋살 10명"} |
| 테스트 절차 | 1) 초안 생성 2) match_db 확인 |
| 기대 결과 | 200 · 초안 필드·시설 후보, 매치 저장 안 됨 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-01 |

### IT-AI-02 — 빈 프롬프트·미지원 종목·500자 초과

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-02 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-01 |
| API·대상 | POST /ai-service/api/ai/matches |
| 유형 | 예외 |
| 테스트 항목 | 빈 프롬프트·미지원 종목·500자 초과 |
| 사전 조건 | 로그인 |
| 입력값(테스트 데이터) | prompt="" / "스쿼시" / 501자 |
| 테스트 절차 | 1) 각각 호출 |
| 기대 결과 | 빈 값·501자: 400 INVALID_INPUT(LLM 호출 전 검증). 미지원 종목: 400 AI_UNSUPPORTED_SPORT(LLM 도구 인자 검증 후 거절 가능) |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-02·TC-AI-09 |

### IT-AI-03 — 자연어 조건 추출 + 재검색

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-03 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-02 |
| API·대상 | POST /ai-service/api/ai/matches/search |
| 유형 | 정상 |
| 테스트 항목 | 자연어 조건 추출 + 재검색 |
| 사전 조건 | 검색 데이터 시드 |
| 입력값(테스트 데이터) | "이번 주말 강남 초급 풋살" |
| 테스트 절차 | 1) 토큰 없이 호출 |
| 기대 결과 | 200 · 조건 요약 + 조건 일치 매치 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-05 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-03 |

### IT-AI-04 — 조건 불명확·결과 없음

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-04 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-02 |
| API·대상 | POST /ai-service/api/ai/matches/search |
| 유형 | 경계 |
| 테스트 항목 | 조건 불명확·결과 없음 |
| 사전 조건 | 해당 매치 없음 |
| 입력값(테스트 데이터) | "강동구에서 수영" / 조건 없는 문장 |
| 테스트 절차 | 1) 호출 |
| 기대 결과 | 200 matches=[] 조건 요약 유지 / 400 AI_CONDITION_NOT_FOUND |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-05 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-04 |

### IT-AI-05 — 프롬프트 조작 무시

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-05 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-02·NFR-05 |
| API·대상 | POST /ai-service/api/ai/matches/search |
| 유형 | 보안 |
| 테스트 항목 | 프롬프트 조작 무시 |
| 사전 조건 | Mock AI |
| 입력값(테스트 데이터) | 시스템 명령 삽입 문장 |
| 테스트 절차 | 1) 호출 |
| 기대 결과 | 서버 필터 우회·내부 호출 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-AI-07 |

### IT-AI-06 — 맞춤 추천 최대 3건

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-06 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-03 |
| API·대상 | GET /ai-service/api/ai/matches/recommendations |
| 유형 | 정상 |
| 테스트 항목 | 맞춤 추천 최대 3건 |
| 사전 조건 | 프로필·매치 시드 |
| 입력값(테스트 데이터) | 회원 Bearer |
| 테스트 절차 | 1) 추천 조회 |
| 기대 결과 | 200 · 지금 이후 시작하는 모집 중 매치, 최대 3건 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-04 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-05 |

### IT-AI-07 — 선호 종목 없음

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-07 |
| 영역 | AI |
| 구분 | 1차 |
| 요구사항 ID | AI-03 |
| API·대상 | GET /ai-service/api/ai/matches/recommendations |
| 유형 | 경계 |
| 테스트 항목 | 선호 종목 없음 |
| 사전 조건 | sportTypes=[] 회원 |
| 입력값(테스트 데이터) | 회원 Bearer |
| 테스트 절차 | 1) 추천 조회 |
| 기대 결과 | 200 · 크래시 없음(빈 목록 또는 최신순) |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-AI-08 |

### IT-AI-08 — LLM 장애 대체 응답

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AI-08 |
| 영역 | AI |
| 구분 | 신규 |
| 요구사항 ID | AI-04·NFR-02 |
| API·대상 | GET /ai-service/api/ai/matches/recommendations, POST /search |
| 유형 | 장애 |
| 테스트 항목 | LLM 장애 대체 응답 |
| 사전 조건 | 대체 후보 존재 |
| 입력값(테스트 데이터) | LLM timeout 주입 |
| 테스트 절차 | 1) 추천 2) 검색 |
| 기대 결과 | 5xx 없이 최신순 추천 / 문장 속 종목·자치구로 대체 검색, 지표 fallback |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-04·UT-AI-05 (CI P) |
| 비고(원 ID 등) | 원 ID TC-AI-06 |

### IT-NT-01 — 내 알림 목록

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-NT-01 |
| 영역 | 알림 |
| 구분 | 신규 |
| 요구사항 ID | NT-03 |
| API·대상 | GET /notification-service/api/notifications/me |
| 유형 | 정상 |
| 테스트 항목 | 내 알림 목록 |
| 사전 조건 | 알림 3건 이상 |
| 입력값(테스트 데이터) | 회원 Bearer |
| 테스트 절차 | 1) 조회 |
| 기대 결과 | 200 · 본인 알림만 최신순, 최대 50건 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-02 (CI P) |

### IT-NT-02 — 안 읽은 개수

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-NT-02 |
| 영역 | 알림 |
| 구분 | 신규 |
| 요구사항 ID | NT-03 |
| API·대상 | GET /notification-service/api/notifications/me/unread-count |
| 유형 | 정상 |
| 테스트 항목 | 안 읽은 개수 |
| 사전 조건 | 안 읽은 알림 2건 |
| 입력값(테스트 데이터) | 회원 Bearer |
| 테스트 절차 | 1) 조회 |
| 기대 결과 | 200 · {count:2} |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-02 (CI P) |

### IT-NT-03 — 읽음 처리·타인 알림

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-NT-03 |
| 영역 | 알림 |
| 구분 | 신규 |
| 요구사항 ID | NT-03 |
| API·대상 | PATCH /notification-service/api/notifications/{notificationId}/read |
| 유형 | 정상·예외 |
| 테스트 항목 | 읽음 처리·타인 알림 |
| 사전 조건 | 내 알림·타인 알림 |
| 입력값(테스트 데이터) | 내 ID / 타인 ID / abc |
| 테스트 절차 | 1) 내 알림 읽음 2) 타인 알림 3) 잘못된 ID |
| 기대 결과 | 200 read=true·첫 readAt 유지 / 403 NOTIFICATION_FORBIDDEN / 400·404 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-02 (CI P) |

### IT-AD-01 — 모임·참가 통계

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AD-01 |
| 영역 | 관리자 |
| 구분 | 신규 |
| 요구사항 ID | AD-01 |
| API·대상 | GET /match-service/api/admin/stats |
| 유형 | 정상·예외 |
| 테스트 항목 | 모임·참가 통계 |
| 사전 조건 | ADMIN·USER 토큰 |
| 입력값(테스트 데이터) | 각 토큰 |
| 테스트 절차 | 1) ADMIN 조회 2) USER 조회 |
| 기대 결과 | 200 · 상태별 매치 수·참가 수 / 403 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-18 (CI P) |

### IT-AD-02 — 탈퇴 Saga 통계

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AD-02 |
| 영역 | 관리자 |
| 구분 | 신규 |
| 요구사항 ID | AD-02 |
| API·대상 | GET /user-service/api/admin/stats |
| 유형 | 정상·예외 |
| 테스트 항목 | 탈퇴 Saga 통계 |
| 사전 조건 | Saga 이력 |
| 입력값(테스트 데이터) | ADMIN / USER 토큰 |
| 테스트 절차 | 1) 조회 |
| 기대 결과 | 200 · CLEANED·REJECTED·TIMED_OUT 건수 / 403 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-03 (CI P) |

### IT-AD-03 — Prometheus 조회 프록시

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-AD-03 |
| 영역 | 관리자 |
| 구분 | 신규 |
| 요구사항 ID | AD-03·GW-03 |
| API·대상 | GET /prometheus/api/v1/query, /query_range |
| 유형 | 정상·예외 |
| 테스트 항목 | Prometheus 조회 프록시 |
| 사전 조건 | ADMIN 토큰 |
| 입력값(테스트 데이터) | query=up / POST·다른 경로 |
| 테스트 절차 | 1) ADMIN query·query_range 2) USER 3) 허용 외 메서드 |
| 기대 결과 | 200 Prometheus 결과 / 403 / 차단 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 관리자 화면에서 호출되는 것은 AT-07에서 확인 |

### IT-INT-01 — 회원 단건 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-01 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | USR-08·MSA-5 |
| API·대상 | GET /internal/users/{id} (I1) |
| 유형 | 정상·예외 |
| 테스트 항목 | 회원 단건 조회 |
| 사전 조건 | ACTIVE·정지·탈퇴 회원 |
| 입력값(테스트 데이터) | 회원 ID / 999999 / abc |
| 테스트 절차 | 1) match에서 Feign 호출 |
| 기대 결과 | 200 성별·상태·자치구·종목·suspendedUntil / 404 USER_NOT_FOUND / 400 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-13 (CI P) |

### IT-INT-02 — 닉네임 일괄 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-02 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | USR-08 |
| API·대상 | GET /internal/users?ids= (I2) |
| 유형 | 정상 |
| 테스트 항목 | 닉네임 일괄 조회 |
| 사전 조건 | 회원 3명 |
| 입력값(테스트 데이터) | ids=1,2,999 |
| 테스트 절차 | 1) 호출 |
| 기대 결과 | 200 · 있는 회원만, 중복 ID 1회 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-13 (CI P) |

### IT-INT-03 — 매치→시설 확인·스냅샷

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-03 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | FC-04·MSA-5 |
| API·대상 | GET /internal/facilities/{id} (I3) |
| 유형 | 정상·예외 |
| 테스트 항목 | 매치→시설 확인·스냅샷 |
| 사전 조건 | 두 서비스 UP |
| 입력값(테스트 데이터) | serviceId 정상 / 999999 / 비활성 |
| 테스트 절차 | 1) 매치 생성으로 I3 호출 2) match_db 스냅샷 확인 |
| 기대 결과 | I3 정상: 이름·운영시간·활성·예약 링크 복사. 없는 시설: 404. 비활성: I3는 200 active:false, 매치 생성은 400 FACILITY_INACTIVE·스냅샷/차감 없음. 다른 DB 직접 접근 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-FC-01 (CI P) |
| 비고(원 ID 등) | 원 ID TC-MSA-06 |

### IT-INT-04 — AI 초안용 시설 후보

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-04 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | FC-04 |
| API·대상 | GET /internal/facilities?district=&sportType= (I4) |
| 유형 | 정상 |
| 테스트 항목 | AI 초안용 시설 후보 |
| 사전 조건 | 시설 시드 |
| 입력값(테스트 데이터) | district=GANGNAM&sportType=FUTSAL |
| 테스트 절차 | 1) AI 초안 생성 |
| 기대 결과 | 초안의 시설 후보 목록 채움, 실패 시 빈 배열 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-01 (CI P) |

### IT-INT-05 — 탈퇴 정리 결과 조회

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-05 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | EM-13·NFR-03 |
| API·대상 | GET /internal/withdrawals/{sagaId} (I5) |
| 유형 | 정상 |
| 테스트 항목 | 탈퇴 정리 결과 조회 |
| 사전 조건 | 처리/미처리/거절 Saga |
| 입력값(테스트 데이터) | sagaId |
| 테스트 절차 | 1) user에서 호출 |
| 기대 결과 | CLEANED / NONE / REJECTED 결과 반환 |
| 결과 | 미실행 |

### IT-INT-06 — Feign 타임아웃 격리

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-INT-06 |
| 영역 | 내부 API |
| 구분 | 신규 |
| 요구사항 ID | MSA-5·⑤·NFR-02 |
| API·대상 | Feign match→facility |
| 유형 | 장애 |
| 테스트 항목 | Feign 타임아웃 격리 |
| 사전 조건 | facility 지연/중단 |
| 입력값(테스트 데이터) | Feign timeout 설정값 기록 |
| 테스트 절차 | 1) 생성 반복 2) 응답 시간·DB 확인 |
| 기대 결과 | 설정 시간 안에 503 또는 정상 접수→CONFIRMED 분리, 무한 대기·부분 생성·중복 차감 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-07 |

### IT-EVT-01 — 탈퇴 토픽 3종

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-01 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | MSA-6·NFR-03 |
| API·대상 | user.withdrawal-requested.v1 → match.withdrawal-cleaned.v1 / withdrawal-rejected.v1 |
| 유형 | 정상 |
| 테스트 항목 | 탈퇴 토픽 3종 |
| 사전 조건 | Kafka·user·match 기동 |
| 입력값(테스트 데이터) | 탈퇴 요청 1건 |
| 테스트 절차 | 1) Outbox·토픽 레코드 확인 |
| 기대 결과 | sagaId·requestEventId·userId 일치, 키 userId, 결과 1건 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-15·UT-MT-25 (CI P) |

### IT-EVT-02 — 보증금 토픽 5종

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-02 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | MSA-6·PT-02 |
| API·대상 | match.deposit-charge-requested / user.deposit-charged / user.deposit-charge-rejected / match.deposit-refund-requested / user.deposit-refund-completed |
| 유형 | 정상 |
| 테스트 항목 | 보증금 토픽 5종 |
| 사전 조건 | 실제 Kafka |
| 입력값(테스트 데이터) | 생성·참가·취소 각 1건 |
| 테스트 절차 | 1) 토픽·Outbox·processed_events 대조 |
| 기대 결과 | requestId 단위로 요청→결과 1:1, 공통 필드(eventId·requestId·userId·matchId·occurredAt) |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-07 (CI P) |

### IT-EVT-03 — 출석 정산 이벤트

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-03 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | MSA-6·PT-03 |
| API·대상 | match.attendance-settlement-requested.v1 |
| 유형 | 정상 |
| 테스트 항목 | 출석 정산 이벤트 |
| 사전 조건 | 출석/노쇼 각 1명, 실제 Kafka |
| 입력값(테스트 데이터) | 매치 종료 |
| 테스트 절차 | 1) Outbox·Kafka 확인 |
| 기대 결과 | CONFIRMED별 1건, key=userId, outcome ATTENDED/NO_SHOW/UNDER_MIN_PARTICIPANTS |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-SET-02 |

### IT-EVT-04 — 참여 정지 이벤트

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-04 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | MSA-6·PT-04 |
| API·대상 | user.participation-suspended.v1 |
| 유형 | 정상 |
| 테스트 항목 | 참여 정지 이벤트 |
| 사전 조건 | 0점 회원 노쇼 확정 |
| 입력값(테스트 데이터) | 정산 이벤트 |
| 테스트 절차 | 1) 발행·match 대기 정리 확인 |
| 기대 결과 | 정지 종료일 포함 1건, 기존 대기 등록 취소 |
| 결과 | 미실행 |

### IT-EVT-05 — 알림 토픽 4종 → 알림 저장

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-05 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | MSA-6·NT-01·NT-02 |
| API·대상 | match.joined / status-changed / waitlist-promoted / starting-soon |
| 유형 | 정상 |
| 테스트 항목 | 알림 토픽 4종 → 알림 저장 |
| 사전 조건 | notification 기동 |
| 입력값(테스트 데이터) | 토픽별 이벤트 1건 |
| 테스트 절차 | 1) notification_db 확인 |
| 기대 결과 | 대상자별 알림 저장, 같은 eventId 1회 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-01·UT-NT-04 (CI P) |

### IT-EVT-06 — 같은 이벤트 두 번 처리

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-06 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| API·대상 | 소비자 전체(processed_events) |
| 유형 | 멱등성 |
| 테스트 항목 | 같은 이벤트 두 번 처리 |
| 사전 조건 | 같은 eventId 확보 |
| 입력값(테스트 데이터) | 같은 eventId 2회 발행 |
| 테스트 절차 | 1) 처리 결과·processed_events 확인 |
| 기대 결과 | 상태 변경 1회, processed_events 1건 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-01·UT-US-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-MSA-09 (원 대상 AI projection은 없어 소비자 전체로 바꿈) |

### IT-EVT-07 — 재시도 3회 후 DLT

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-07 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| API·대상 | <원본 토픽>.DLT |
| 유형 | 장애 |
| 테스트 항목 | 재시도 3회 후 DLT |
| 사전 조건 | 깨진 payload |
| 입력값(테스트 데이터) | 필수 필드 없는 이벤트 |
| 테스트 절차 | 1) 발행 2) DLT 확인 |
| 기대 결과 | 3회 재시도 후 DLT 1건, 정상 이벤트 무영향 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-NT-01·UT-US-07 (CI P) |

### IT-EVT-08 — Kafka 중단 후 Outbox 재발행

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-EVT-08 |
| 영역 | 이벤트 |
| 구분 | 신규 |
| 요구사항 ID | NFR-04 |
| API·대상 | outbox_event |
| 유형 | 장애 |
| 테스트 항목 | Kafka 중단 후 Outbox 재발행 |
| 사전 조건 | Kafka 중지 |
| 입력값(테스트 데이터) | 매치 생성 1건 |
| 테스트 절차 | 1) Kafka 중지 중 생성 2) 복구 |
| 기대 결과 | Outbox 미발행으로 남음 → 복구 후 재발행, 소비 1회 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-24 (CI P) |
| 비고(원 ID 등) | 원 ID TC-OPT-05 |

### IT-SET-01 — 종료 후 자동 완료

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-01 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-09·EM-11·MSA-7 |
| API·대상 | MatchLifecycleScheduler |
| 유형 | 정상 |
| 테스트 항목 | 종료 후 자동 완료 |
| 사전 조건 | 차감 완료 CONFIRMED 2명 이상 |
| 입력값(테스트 데이터) | 기본 60초 주기 |
| 테스트 절차 | 1) 종료 시각 경과 후 대기 |
| 기대 결과 | COMPLETED·status-changed, 참가자별 정산 Outbox |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-01 |

### IT-SET-02 — 비확정 참가자 제외

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-02 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-10·EM-11 |
| API·대상 | 정산 대상 |
| 유형 | 경계 |
| 테스트 항목 | 비확정 참가자 제외 |
| 사전 조건 | CONFIRMED·PENDING·FAILED·CANCELLED 혼재 |
| 입력값(테스트 데이터) | 매치 종료 |
| 테스트 절차 | 1) 정산 대상 확인 |
| 기대 결과 | CONFIRMED만 정산 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-SET-03 |

### IT-SET-03 — 확정 2명 미만

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-03 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-03 |
| API·대상 | UNDER_MIN_PARTICIPANTS |
| 유형 | 경계 |
| 테스트 항목 | 확정 2명 미만 |
| 사전 조건 | CONFIRMED 1명 |
| 입력값(테스트 데이터) | 매치 종료 |
| 테스트 절차 | 1) 정산·포인트·누적 확인 |
| 기대 결과 | 보증금만 반환(상한 100), 누적·보상·정지 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11·UT-US-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-04 |

### IT-SET-04 — 반복·동시 완료 중복 방지

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-04 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-06 |
| API·대상 | 스케줄러·이벤트 재전달 |
| 유형 | 멱등성 |
| 테스트 항목 | 반복·동시 완료 중복 방지 |
| 사전 조건 | 같은 완료 대상 |
| 입력값(테스트 데이터) | 동시 실행·재전달 |
| 테스트 절차 | 1) 상태·원장 확인 |
| 기대 결과 | 전이·차감·반환·보상 중복 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-05 |

### IT-SET-05 — 중단 중 시작·종료 모두 경과

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-05 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-09 |
| API·대상 | 스케줄러 재개 |
| 유형 | 경계 |
| 테스트 항목 | 중단 중 시작·종료 모두 경과 |
| 사전 조건 | 서버 중단 후 복구 |
| 입력값(테스트 데이터) | startAt·endAt 과거 |
| 테스트 절차 | 1) 재개 후 이벤트 확인 |
| 기대 결과 | IN_PROGRESS를 거쳐 COMPLETED, 상태 이벤트·정산 기록 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-06 |

### IT-SET-06 — 정산 Outbox 실패 시 롤백

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-06 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·NFR-04 |
| API·대상 | 정산 Outbox |
| 유형 | 장애 |
| 테스트 항목 | 정산 Outbox 실패 시 롤백 |
| 사전 조건 | 장애 주입 가능 DB |
| 입력값(테스트 데이터) | 정산 INSERT 실패 |
| 테스트 절차 | 1) 완료 실행 2) 복구·재시도 |
| 기대 결과 | 완료 상태·이벤트 함께 롤백, 재시도 후 1회 반영 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-SET-07 |

### IT-SET-07 — 보증금 비활성 시 정산 미발행

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-07 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-03 |
| API·대상 | match.deposit.enabled=false |
| 유형 | 설정 |
| 테스트 항목 | 보증금 비활성 시 정산 미발행 |
| 사전 조건 | 격리 환경 설정 변경 |
| 입력값(테스트 데이터) | 매치 종료 |
| 테스트 절차 | 1) 종료 처리 |
| 기대 결과 | COMPLETED·상태 이벤트는 수행, 정산 이벤트 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-08 |

### IT-SET-08 — 정상 출석 반환·5회 보상

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-08 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-03 |
| API·대상 | user 정산 처리 |
| 유형 | 정상 |
| 테스트 항목 | 정상 출석 반환·5회 보상 |
| 사전 조건 | 누적 4회 회원 |
| 입력값(테스트 데이터) | ATTENDED 정산 |
| 테스트 절차 | 1) 이력 확인 |
| 기대 결과 | 반환 +10, 5회 보상 +10(상한 100), 누적 0 초기화 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-09 |

### IT-SET-09 — 노쇼 몰수·0점 정지

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-09 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-03·PT-04 |
| API·대상 | user 정산 처리 |
| 유형 | 정상 |
| 테스트 항목 | 노쇼 몰수·0점 정지 |
| 사전 조건 | 차감 후 0점 |
| 입력값(테스트 데이터) | NO_SHOW 정산 |
| 테스트 절차 | 1) 포인트·정지·대기 확인 |
| 기대 결과 | 반환 없음·NO_SHOW_FORFEITED, 0점이면 정지·정지 이벤트·대기 정리 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-11 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-10 |

### IT-SET-10 — 차감 없는 요청 정산 보호

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-10 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | PT-06 |
| API·대상 | user 정산 처리 |
| 유형 | 방어 |
| 테스트 항목 | 차감 없는 요청 정산 보호 |
| 사전 조건 | 차감 이력 없는 요청 |
| 입력값(테스트 데이터) | 정산 수신·재수신 |
| 테스트 절차 | 1) 원장 확인 |
| 기대 결과 | 반환·보상·누적 증가 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-US-06 (CI P) |
| 비고(원 ID 등) | 원 ID TC-HS-SET-11 |

### IT-SET-11 — 출석 수정과 자동 완료 경합

| 항목 | 내용 |
| --- | --- |
| TC ID | IT-SET-11 |
| 영역 | 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11 |
| API·대상 | 출석 PATCH·자동 완료 |
| 유형 | 동시성 |
| 테스트 항목 | 출석 수정과 자동 완료 경합 |
| 사전 조건 | 격리 MariaDB |
| 입력값(테스트 데이터) | 같은 matchId 두 순서 |
| 테스트 절차 | 1) 수정 선행/완료 선행 |
| 기대 결과 | 행 잠금으로 직렬화, 완료 후 수정 409, 최종 출석과 outcome 일치 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-HS-SET-12 |

## 시스템 테스트(ST)

### ST-SAGA-01 — 정상 탈퇴와 이력 보존

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-SAGA-01 |
| 영역 | 탈퇴 Saga |
| 구분 | 신규 |
| 요구사항 ID | USR-04·EM-13·NFR-03·⑩ |
| API·대상 | A3 + Kafka + I5 |
| 유형 | 정상 |
| 테스트 항목 | 정상 탈퇴와 이력 보존 |
| 사전 조건 | ACTIVE 방장(미래 매치 M-01), 다른 매치 CONFIRMED 참가(M-02), 대기 1건, 유효 Refresh |
| 입력값(테스트 데이터) | A3 {password}, 일회용 회원 U-01 |
| 테스트 절차 | 1) 기준값 저장 2) A3 3) Kafka·user_db 4) match_db·다른 참가자 5) Refresh·포인트 |
| 기대 결과 | 202 WITHDRAWING·sagaId → CLEANED/WITHDRAWN, M-01 CANCELLED·본인 참가/대기 정리, 타인 확정 이력·반환 보존, 본인 보증금 미반환, Refresh 거절 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-SAGA-001 · 재시험 최종 PASS. 실제 결과: 방장 탈퇴 202→CLEANED/WITHDRAWN, 소유 매치 취소, 타 참가자 이력·환불 보존 |

### ST-SAGA-02 — 진행 중 방장 탈퇴 거절

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-SAGA-02 |
| 영역 | 탈퇴 Saga |
| 구분 | 신규 |
| 요구사항 ID | USR-04·EM-13·NFR-03·NT-01 |
| API·대상 | A3 + match.withdrawal-rejected.v1 |
| 유형 | 예외 |
| 테스트 항목 | 진행 중 방장 탈퇴 거절 |
| 사전 조건 | IN_PROGRESS 매치 M-03의 OWNER U-02 |
| 입력값(테스트 데이터) | A3 {password} |
| 테스트 절차 | 1) 기준값 2) A3 3) REJECTED 이벤트 4) A11·A25·A28·DB 대조 |
| 기대 결과 | REJECTED/ACTIVE, 매치·참가·포인트 불변, 거절 알림 1회 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-SAGA-002 · 재시험 최종 PASS. 실제 결과: 진행 중 방장 202→REJECTED/ACTIVE, 매치·포인트 불변, 거절 알림 1건 |

### ST-SAGA-03 — 마감 후 늦은 CLEANED

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-SAGA-03 |
| 영역 | 탈퇴 Saga |
| 구분 | 신규 |
| 요구사항 ID | USR-04·NFR-03 |
| API·대상 | A3 + 결과 이벤트 지연 |
| 유형 | 장애 |
| 테스트 항목 | 마감 후 늦은 CLEANED |
| 사전 조건 | 격리 fixture, Match 정리 후 결과 Outbox 발행만 지연 |
| 입력값(테스트 데이터) | A3 {password}, 마감 5분 + 유예 30초 |
| 테스트 절차 | 1) A3 2) 결과 지연 3) 마감 경과 확인 4) 늦은 CLEANED 전달 5) 양쪽 DB 대조 |
| 기대 결과 | 늦은 결과에도 회원·매치 상태가 서로 맞아야 함 (현재 기대: 마감 후 I5 조회로 CLEANED → WITHDRAWN/CLEANED) |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-SAGA-003 · 재시험 최종 PASS. 실제 결과: A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |

### ST-SAGA-04 — 마감 후 미처리(NONE)

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-SAGA-04 |
| 영역 | 탈퇴 Saga |
| 구분 | 신규 |
| 요구사항 ID | USR-04·NFR-03 |
| API·대상 | A3 + I5 |
| 유형 | 장애 |
| 테스트 항목 | 마감 후 미처리(NONE) |
| 사전 조건 | Match 소비 중단, 정리 미시작 |
| 입력값(테스트 데이터) | A3 {password} |
| 테스트 절차 | 1) A3 2) 마감+유예 경과 3) I5 결과 NONE 확인 |
| 기대 결과 | TIMED_OUT/ACTIVE 복구, 뒤늦은 정리는 DEADLINE_EXCEEDED로 거절 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-SAGA-003 · 재시험 최종 PASS. 실제 결과: A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |

### ST-SAGA-05 — 마감 후 결과 조회 실패

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-SAGA-05 |
| 영역 | 탈퇴 Saga |
| 구분 | 신규 |
| 요구사항 ID | USR-04·NFR-03 |
| API·대상 | A3 + I5 |
| 유형 | 장애 |
| 테스트 항목 | 마감 후 결과 조회 실패 |
| 사전 조건 | I5가 409·5xx·연결 실패 |
| 입력값(테스트 데이터) | A3 {password} |
| 테스트 절차 | 1) A3 2) 마감 경과 3) I5 실패 주입 4) 복구 후 재확인 |
| 기대 결과 | WITHDRAWING/PROCESSING 유지 후 재확인으로 확정 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-SAGA-003 · 재시험 최종 PASS. 실제 결과: A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |

### ST-POINT-01 — 생성·참가 보증금 차감과 확정

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-POINT-01 |
| 영역 | 포인트 Saga |
| 구분 | 신규 |
| 요구사항 ID | PT-02·EM-01·EM-06·EM-10·⑩ |
| API·대상 | A9·A14·요청 상태 조회 |
| 유형 | 정상 |
| 테스트 항목 | 생성·참가 보증금 차감과 확정 |
| 사전 조건 | 방장 U-P01·회원 U-P02 각 50점, 보증금 활성 |
| 입력값(테스트 데이터) | A9 생성 body, A14 참가 |
| 테스트 절차 | 1) 기준값 2) A9 → 상태 조회 3) A14 → 상태 조회 4) Kafka·Outbox·point_history 대조 |
| 기대 결과 | 각 202 PENDING → CONFIRMED, 회원별 DEPOSIT_CHARGED -10 1회(50→40), OWNER 1명, 정원 초과 없음 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-POINT-001 · 재시험 최종 PASS. 실제 결과: CREATE/JOIN 202→CONFIRMED, 각 50→40점·차감 1회, Kafka/DB 일치 |

### ST-POINT-02 — 차감 거절·비활성 보호

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-POINT-02 |
| 영역 | 포인트 Saga |
| 구분 | 신규 |
| 요구사항 ID | PT-02·PT-04·PT-06 |
| API·대상 | A9·A14·I1 |
| 유형 | 예외 |
| 테스트 항목 | 차감 거절·비활성 보호 |
| 사전 조건 | 잔액 <10점, 참여 정지, WITHDRAWING 회원 |
| 입력값(테스트 데이터) | 조건별 생성/참가 요청 |
| 테스트 절차 | 1) 즉시 거절과 202 후 FAILED 분리 2) failureCode·잔액·이력 대조 3) 정상 회원 교차 회귀 |
| 기대 결과 | INSUFFICIENT_POINTS / PARTICIPATION_SUSPENDED / USER_NOT_ACTIVE, 무차감·무확정 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-POINT-002 · 재시험 최종 PASS. 실제 결과: 잔액 부족 FAILED, 정지 403, 비활성 400; 무차감·정상 계정 회귀 |

### ST-POINT-03 — 취소·확정 실패·만료·중복 보상

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-POINT-03 |
| 영역 | 포인트 Saga |
| 구분 | 신규 |
| 요구사항 ID | PT-02·PT-06·EM-07 |
| API·대상 | A15·요청 상태 조회 |
| 유형 | 장애 |
| 테스트 항목 | 취소·확정 실패·만료·중복 보상 |
| 사전 조건 | 차감 전 취소, 차감 후 취소, 확정 실패, 5분 만료 fixture |
| 입력값(테스트 데이터) | 분기별 requestId, 같은 eventId 재전달 |
| 테스트 절차 | 1) 분기별 실행 2) 늦은 성공·중복 재전달 3) 원장 대조 |
| 기대 결과 | 차감 후 취소 반환 10점 1회, 차감 전 취소 0점, FAILED/CANCELLED 뒤 재확정 없음, DEPOSIT_RETURNED 중복 0 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-POINT-003 · 재시험 최종 PASS. 실제 결과: 기존 취소·성별 불일치/환불에 더해 차감 전 취소, 5분 만료·늦은 CHARGED, 동일·새 eventId 재전달까지 확인 |

### ST-POINT-04 — 출석·노쇼·미달 정산

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-POINT-04 |
| 영역 | 포인트 Saga |
| 구분 | 신규 |
| 요구사항 ID | PT-03·PT-04·EM-11 |
| API·대상 | 출석 PATCH·스케줄러·정산 |
| 유형 | 정상 |
| 테스트 항목 | 출석·노쇼·미달 정산 |
| 사전 조건 | ATTENDED/NO_SHOW/2명 미만, 5회 출석·0점 fixture |
| 입력값(테스트 데이터) | 방장 출석 수정, 매치 종료 |
| 테스트 절차 | 1) 출석 수정 2) 자동 COMPLETED·정산 Outbox 3) 분기별 원장 4) 같은 eventId 재전달 |
| 기대 결과 | 출석 반환·5회 보상(상한 100), 노쇼 몰수·0점 정지, 미달 반환, 중복 정산 없음 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-POINT-004 · 재시험 최종 PASS. 실제 결과: 출석 5회 보상, 노쇼 몰수·정지, 최소 인원 미달 반환, 중복 정산 불변 |

### ST-OBS-01 — Facility 중단과 복구

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-01 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-4·NFR-02·⑤ |
| API·대상 | A9·A11·I3 |
| 유형 | 장애 |
| 테스트 항목 | Facility 중단과 복구 |
| 사전 조건 | 기존 확정 매치 M-04, 정상 시설 |
| 입력값(테스트 데이터) | Compose에서 facility-service 중지 |
| 테스트 절차 | 1) 기준 A9·A11 2) Facility 중지 3) A9 반복·M-04 조회 4) 지표 5) 복구 후 A9 |
| 기대 결과 | 중단 중 신규 A9 503·부분 생성 없음, M-04 스냅샷 조회 200, up 0→1 복구, 복구 후 202→CONFIRMED |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-OBS-001 · 재시험 최종 PASS. 실제 결과: Facility DOWN 중 신규 A9 503, 기존 A11 200·스냅샷 불변, 1→0→1 복구 |

### ST-OBS-02 — Facility 지연과 Trace

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-02 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-4·⑥·NFR-06 |
| API·대상 | A9·I3·Zipkin |
| 유형 | 장애 |
| 테스트 항목 | Facility 지연과 Trace |
| 사전 조건 | 지연 주입 수단, Zipkin |
| 입력값(테스트 데이터) | Facility 응답 약 1500ms 지연 |
| 테스트 절차 | 1) 기준선·Trace ID 2) 지연 주입 3) A9 반복 4) span·Feign 지표 5) 원복 |
| 기대 결과 | 지연 구간 span(Gateway·Match·Facility)·Feign 지표 확인, 원복 후 정상 응답 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-OBS-002 · 재시험 최종 PASS. 실제 결과: Facility 1.5초 지연: 168→1,902ms, Zipkin trace, 원복 뒤 확정 |

### ST-OBS-03 — k6 100 VU 조회·참가 경쟁

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-03 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | ⑦·NFR-01·MON-4·PT-06 |
| API·대상 | A10·A14 (k6) |
| 유형 | 부하 |
| 테스트 항목 | k6 100 VU 조회·참가 경쟁 |
| 사전 조건 | 회원 101명(방장 포함) 50점, 정원 10 매치 |
| 입력값(테스트 데이터) | A10 100 VU·60초, A14 서로 다른 100명 1회 |
| 테스트 절차 | 1) smoke 2) A10 부하 3) A14 100건 4) 요청별 최종 상태 폴링 5) DB·포인트 대조 6) Grafana |
| 기대 결과 | HTTP 실패 0, 202 접수와 최종 확정 분리: 신규 확정 9·정원 거절·반환 91, 방장 포함 10/10, 중복 없음 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-OBS-003 · 재시험 최종 PASS. 실제 결과: 100 VU·60초 5,517건·실패 0, 참가 100→확정 9/환불 91, DB 10/10 |

### ST-OBS-04 — Notification 중단·Lag·복구

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-04 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-4·NFR-04·NT-01 |
| API·대상 | A14·A25·A27·Kafka Lag |
| 유형 | 장애 |
| 테스트 항목 | Notification 중단·Lag·복구 |
| 사전 조건 | 회원 5명, 여유 정원 6 |
| 입력값(테스트 데이터) | notification Consumer 중지 후 5명 참가 |
| 테스트 절차 | 1) Consumer 중지 2) 5명 A14·확정 3) Lag 관측 4) 재시작 5) 같은 eventId 재전달 |
| 기대 결과 | 참가 확정은 알림 장애와 무관, Lag 0→5→0, 알림 누락·중복 없음 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.6 최종 실행 보고서 / r10-v06-execution-report.md |
| 비고(원 ID 등) | 원 ID TC-OBS-004 · 재시험 최종 PASS. 실제 결과: Notification DOWN 중 참가 5건 확정, Lag 0→5→0, 알림·재처리 중복 없음 |

### ST-OBS-05 — 대시보드 5종

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-05 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-2 |
| API·대상 | Grafana |
| 유형 | 정상 |
| 테스트 항목 | 대시보드 5종 |
| 사전 조건 | 모니터링 스택 기동 |
| 입력값(테스트 데이터) | 부하·장애 실행 시각 |
| 테스트 절차 | 1) 서비스 개요·서비스 간 통신·Kafka·JVM·도메인/AI 대시보드 열기 |
| 기대 결과 | 5종 모두 자동 로드되고 패널에 데이터 표시 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.5 모니터링 검증 보고서(보완 검증) · Grafana 실제 브라우저 PNG 5개 |
| 비고(원 ID 등) | 원 ID TC-MSA-13 |

### ST-OBS-06 — Saga 지표 교차 확인

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-06 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | AD-02·AD-03·AD-04·MON-1 |
| API·대상 | A28·A30·A31·React |
| 유형 | 정상 |
| 테스트 항목 | Saga 지표 교차 확인 |
| 사전 조건 | Saga 성공·거절·타임아웃 실행 후 |
| 입력값(테스트 데이터) | A28 응답, Prometheus 카운터 |
| 테스트 절차 | 1) A28 2) sporty_withdrawal_saga_results_total 3) React 도메인 탭 비교 |
| 기대 결과 | 세 값 일치 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.5 모니터링 검증 보고서(보완 검증) · react-browser-check.json |

### ST-OBS-07 — 경보 4종 → Discord

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-07 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-3·⑨ |
| API·대상 | Alertmanager → Discord |
| 유형 | 장애 |
| 테스트 항목 | 경보 4종 → Discord |
| 사전 조건 | Discord 웹훅 설정 |
| 입력값(테스트 데이터) | 서비스 다운 1분, 5xx 5%(2분), p95 1초(2분), Lag 100 |
| 테스트 절차 | 1) 조건별 장애 주입 2) Discord 채널 확인 |
| 기대 결과 | 규칙별 경보 1건 수신·해소 알림, 웹훅 주소 마스킹 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 근거 자료에 Discord 수신 기록 없음 |

### ST-OBS-08 — AWS 수집 대상 UP

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-OBS-08 |
| 영역 | 장애·관측 |
| 구분 | 신규 |
| 요구사항 ID | MON-1·④ |
| API·대상 | infra Prometheus |
| 유형 | 정상 |
| 테스트 항목 | AWS 수집 대상 UP |
| 사전 조건 | AWS infra EC2, K8s 앱 Pod 기동 |
| 입력값(테스트 데이터) | Prometheus targets |
| 테스트 절차 | 1) 수집 대상 상태 확인 |
| 기대 결과 | 수집 대상 8개 모두 UP |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |

### ST-NFR-01 — Gateway 보안 경로 차단 종합

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-01 |
| 영역 | 보안 |
| 구분 | 신규 |
| 요구사항 ID | GW-02·GW-03·GW-04·NFR-05 |
| API·대상 | Gateway 실환경 |
| 유형 | 보안 |
| 테스트 항목 | Gateway 보안 경로 차단 종합 |
| 사전 조건 | Compose 또는 K8s 전체 기동 |
| 입력값(테스트 데이터) | internal·actuator·".."·admin·위조 헤더 요청 |
| 테스트 절차 | 1) 각 요청을 Gateway로 호출 |
| 기대 결과 | internal 403, actuator 403(공개 health 200), ".." 400 INVALID_PATH, USER의 admin 403, 위조 헤더 제거 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-GW-01~03 (CI P) |
| 비고(원 ID 등) | 원 ID TC-MSA-04·TC-QA-02. 실환경 실행 기록 없음 |

### ST-NFR-02 — local·dev·prod 프로필 분리

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-02 |
| 영역 | 설정 |
| 구분 | 신규 |
| 요구사항 ID | MSA-4·NFR-07 |
| API·대상 | Config Server 8888 |
| 유형 | 정상 |
| 테스트 항목 | local·dev·prod 프로필 분리 |
| 사전 조건 | config-repo 공통 + 서비스별 yml |
| 입력값(테스트 데이터) | profile=local/dev/prod |
| 테스트 절차 | 1) /<서비스>/<프로필> 조회 2) 서비스 기동 후 설정값 확인 |
| 기대 결과 | 프로필별 다른 값 로드, 비밀값 평문 노출 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-05·TC-MSA-14 |

### ST-NFR-03 — Config Server 미연결 시 기동 거부

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-03 |
| 영역 | 설정 |
| 구분 | 신규 |
| 요구사항 ID | NFR-07 |
| API·대상 | 서비스 기동 |
| 유형 | 장애 |
| 테스트 항목 | Config Server 미연결 시 기동 거부 |
| 사전 조건 | config-service 중지 |
| 입력값(테스트 데이터) | 서비스 하나 기동 |
| 테스트 절차 | 1) 기동 로그 확인 |
| 기대 결과 | fail-fast로 기동 실패 |
| 결과 | 미실행 |

### ST-NFR-04 — Bus 설정 일괄 갱신

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-04 |
| 영역 | 설정 |
| 구분 | 신규 |
| 요구사항 ID | ① |
| API·대상 | POST /actuator/busrefresh |
| 유형 | 정상 |
| 테스트 항목 | Bus 설정 일괄 갱신 |
| 사전 조건 | RabbitMQ·Bus 연결 |
| 입력값(테스트 데이터) | config-repo 로그 레벨 변경 커밋 |
| 테스트 절차 | 1) busrefresh 1회 2) 서비스별 로그 레벨 확인 |
| 기대 결과 | 연결된 서비스 모두 재기동 없이 반영 |
| 결과 | 미실행 |
| 비고(원 ID 등) | RabbitMQ 연결 자체는 ST-DEP-06에서 P |

### ST-NFR-05 — prod 비밀값 복호화

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-05 |
| 영역 | 설정 |
| 구분 | 신규 |
| 요구사항 ID | ②·NFR-05 |
| API·대상 | Config {cipher} |
| 유형 | 보안 |
| 테스트 항목 | prod 비밀값 복호화 |
| 사전 조건 | 키스토어·prod 프로필 |
| 입력값(테스트 데이터) | {cipher} DB 비밀번호·JWT 시크릿 |
| 테스트 절차 | 1) prod 기동 2) 저장소 평문 검색 |
| 기대 결과 | 서비스 정상 기동, 저장소에 평문 비밀값 없음 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-CFG-01·UT-CFG-02 (CI P) |

### ST-NFR-06 — 분산 추적

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-06 |
| 영역 | 관측 |
| 구분 | 신규 |
| 요구사항 ID | ⑥·NFR-06 |
| API·대상 | Zipkin |
| 유형 | 정상 |
| 테스트 항목 | 분산 추적 |
| 사전 조건 | Zipkin, 샘플링 100% |
| 입력값(테스트 데이터) | A9 1건 |
| 테스트 절차 | 1) traceId로 span 조회 |
| 기대 결과 | Gateway→Match→Facility 한 Trace로 연결 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 근거·자동 테스트 | R10 v0.5 실행 보고서(격리 Compose sporty-k6-v05, backend c5c90c2·PR #142 e33ca69) · ST-OBS-02와 같은 실행의 zipkin-delay-trace.json |
| 비고(원 ID 등) | 원 ID TC-QA-05(correlationId → traceId) |

### ST-NFR-07 — Circuit Breaker 상태 전이

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-07 |
| 영역 | 가용성 |
| 구분 | 신규 |
| 요구사항 ID | ⑤·NFR-02 |
| API·대상 | Resilience4j |
| 유형 | 장애 |
| 테스트 항목 | Circuit Breaker 상태 전이 |
| 사전 조건 | facility·user 중지 |
| 입력값(테스트 데이터) | 실패율 임계치 이상 연속 호출 |
| 테스트 절차 | 1) 연속 실패 2) 대기 3) 복구 후 호출 |
| 기대 결과 | OPEN → HALF_OPEN → CLOSED, fallback(회원 확인 불가 503, 닉네임 "알 수 없음") |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-OPT-01. ST-OBS-01은 up 지표로 확인, CB 상태 기록은 근거에 없음 |

### ST-NFR-08 — 공통 에러 형식

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-08 |
| 영역 | 관측 |
| 구분 | 신규 |
| 요구사항 ID | NFR-06 |
| API·대상 | 5개 서비스 공통 |
| 유형 | 예외 |
| 테스트 항목 | 공통 에러 형식 |
| 사전 조건 | 전체 기동 |
| 입력값(테스트 데이터) | 잘못된 JSON, 없는 경로, 허용 안 된 메서드 |
| 테스트 절차 | 1) 서비스별 호출 |
| 기대 결과 | 본문 {code, message}: 400 INVALID_INPUT, 404 NOT_FOUND, 405 METHOD_NOT_ALLOWED, 500 내부 메시지 숨김 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-AI-02·UT-FC-02·UT-MT-01·UT-NT-03 (CI P) |

### ST-NFR-09 — DB 최소 권한

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-09 |
| 영역 | 보안 |
| 구분 | 신규 |
| 요구사항 ID | MSA-8·NFR-05 |
| API·대상 | MariaDB 계정 |
| 유형 | 보안 |
| 테스트 항목 | DB 최소 권한 |
| 사전 조건 | 서비스별 계정 4개 |
| 입력값(테스트 데이터) | user 계정으로 match_db SELECT |
| 테스트 절차 | 1) 다른 스키마 접근 |
| 기대 결과 | 접근 거부 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-11 |

### ST-NFR-10 — 서비스 간 물리 FK 없음

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-10 |
| 영역 | 데이터 |
| 구분 | 신규 |
| 요구사항 ID | MSA-8 |
| API·대상 | DDL R10 |
| 유형 | 정상 |
| 테스트 항목 | 서비스 간 물리 FK 없음 |
| 사전 조건 | 4개 스키마 생성 |
| 입력값(테스트 데이터) | information_schema |
| 테스트 절차 | 1) 스키마 간 FK 조회 |
| 기대 결과 | 다른 스키마 FK 0건 |
| 결과 | 미실행 |
| 근거·자동 테스트 | UT-MT-17 (CI P) |
| 비고(원 ID 등) | 원 ID TC-MSA-10 |

### ST-NFR-11 — 서비스 등록·해제

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-11 |
| 영역 | 디스커버리 |
| 구분 | 신규 |
| 요구사항 ID | MSA-2 |
| API·대상 | Eureka 8761 |
| 유형 | 정상 |
| 테스트 항목 | 서비스 등록·해제 |
| 사전 조건 | 전체 기동 |
| 입력값(테스트 데이터) | 서비스 1개 중지 |
| 테스트 절차 | 1) 대시보드 확인 2) 중지 후 확인 |
| 기대 결과 | 전 서비스 UP 등록, 중지 서비스 해제 반영 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-02 |

### ST-NFR-12 — 토큰·비밀값 로그 마스킹

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-12 |
| 영역 | 보안 |
| 구분 | 신규 |
| 요구사항 ID | NFR-05 |
| API·대상 | 서비스 로그 |
| 유형 | 보안 |
| 테스트 항목 | 토큰·비밀값 로그 마스킹 |
| 사전 조건 | 인증 요청 후 |
| 입력값(테스트 데이터) | Bearer 토큰 문자열 |
| 테스트 절차 | 1) 전 서비스 로그 검색 |
| 기대 결과 | 원문 토큰·비밀번호·웹훅 없음 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-QA-06 |

### ST-NFR-13 — p95 응답시간·오류율

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-13 |
| 영역 | 성능 |
| 구분 | 신규 |
| 요구사항 ID | NFR-01·⑦ |
| API·대상 | A10·A14 |
| 유형 | 부하 |
| 테스트 항목 | p95 응답시간·오류율 |
| 사전 조건 | ST-OBS-03 환경 |
| 입력값(테스트 데이터) | 100 VU |
| 테스트 절차 | 1) k6 summary p95·실패율 기록 |
| 기대 결과 | p95·오류율 수치 기록, p95 1초 초과 2분이면 경보 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-QA-01. ST-OBS-03에서 실패 0은 확인, p95 수치는 근거 자료에 없음 |

### ST-NFR-14 — 외부 API 장애 대체

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-NFR-14 |
| 영역 | 가용성 |
| 구분 | 신규 |
| 요구사항 ID | NFR-02·AI-04·FC-03 |
| API·대상 | LLM·공공데이터 API |
| 유형 | 장애 |
| 테스트 항목 | 외부 API 장애 대체 |
| 사전 조건 | Mock 서버 |
| 입력값(테스트 데이터) | 503·timeout |
| 테스트 절차 | 1) AI 검색·추천 2) 시설 동기화 |
| 기대 결과 | AI 대체 응답, 시설 기존 목록 유지, 에러 로그 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-QA-04 |

### ST-DEP-01 — Compose 전체 기동

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-01 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | MSA-9·MSA-1·GW-01 |
| API·대상 | docker compose |
| 유형 | 정상 |
| 테스트 항목 | Compose 전체 기동 |
| 사전 조건 | 깨끗한 러너, 시험용 .env |
| 입력값(테스트 데이터) | docker compose up -d --build --wait |
| 테스트 절차 | 1) 전체 빌드·기동 2) Gateway 8000으로 5개 서비스 /actuator/health |
| 기대 결과 | 전 컨테이너 healthy, user·match·facility·ai·notification health 200 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·자동 테스트 | compose-smoke run 41666137521 (backend 96357e5) success |
| 비고(원 ID 등) | 원 ID TC-MSA-01·TC-MSA-12(기동 부분) |

### ST-DEP-02 — 재시작 후 데이터 유지

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-02 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | MSA-9 |
| API·대상 | Kubernetes Deployment |
| 유형 | 정상 |
| 테스트 항목 | 재시작 후 데이터 유지 |
| 사전 조건 | 격리 QA namespace 및 독립 데이터 저장소 준비, 기준 데이터 생성 |
| 입력값(테스트 데이터) | 격리 Deployment 재시작 |
| 테스트 절차 | 1) 격리 Deployment 재시작 2) Pod Ready·핵심 API·저장 데이터 재조회 |
| 기대 결과 | Pod 복구, 저장 데이터 유지, 핵심 API 성공 |
| 결과 | 미실행 |
| 비고(원 ID 등) | 원 ID TC-MSA-12(데이터 부분) |

### ST-DEP-03 — CI·이미지 자동화

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-03 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | NFR-08 |
| API·대상 | GitHub Actions |
| 유형 | 정상 |
| 테스트 항목 | CI·이미지 자동화 |
| 사전 조건 | main 머지 |
| 입력값(테스트 데이터) | main push |
| 테스트 절차 | 1) CI·Compose 시험·Image Push 결과 확인 |
| 기대 결과 | 빌드·테스트·Compose 기동 성공, Docker Hub 이미지 push 성공 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | GitHub Actions CI |
| 근거·자동 테스트 | CI run 41666137412·compose-smoke 41666137521 (96357e5), Image Push 41652492308 (2e4d4f7) 모두 success |
| 비고(원 ID 등) | 원 ID TC-OPT-04 |

### ST-DEP-04 — K8s 앱 Pod 기동

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-04 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | ③ |
| API·대상 | kubeadm K8s (Kustomize) |
| 유형 | 정상 |
| 테스트 항목 | K8s 앱 Pod 기동 |
| 사전 조건 | EC2 master 1·worker 2, Docker Hub 이미지 |
| 입력값(테스트 데이터) | kubectl apply -k |
| 테스트 절차 | 1) Pod 상태 확인 |
| 기대 결과 | 앱 Pod 9개 Running |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |
| 비고(원 ID 등) | 원 ID TC-OPT-02. match-service가 startupProbe 한도(약 130초) 초과로 재시작 반복 → failureThreshold 48로 조정 후 정상(backend PR #150) |

### ST-DEP-05 — AWS 외부 접속

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-05 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | ④·UI-01 |
| API·대상 | 프론트 NodePort 30000 |
| 유형 | 정상 |
| 테스트 항목 | AWS 외부 접속 |
| 사전 조건 | ST-DEP-04 완료 |
| 입력값(테스트 데이터) | http://<노드>:30000, /<서비스>/actuator/health |
| 테스트 절차 | 1) 프론트 접속 2) 프론트 프록시 경유 5개 health |
| 기대 결과 | 프론트 200, user·match·facility·ai·notification health 모두 200 |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |

### ST-DEP-06 — infra 구성 요소 연결

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-06 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | ④·①·MON-2 |
| API·대상 | infra EC2 (Compose) |
| 유형 | 정상 |
| 테스트 항목 | infra 구성 요소 연결 |
| 사전 조건 | infra EC2 기동 |
| 입력값(테스트 데이터) | Grafana /api/health, RabbitMQ 연결 목록 |
| 테스트 절차 | 1) Grafana health 2) RabbitMQ 연결 확인 |
| 기대 결과 | Grafana 200, RabbitMQ 연결 7개(sporty 계정) |
| 결과 | P |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |

### ST-DEP-07 — Gateway 외부 직접 접속

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-07 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | ④ |
| API·대상 | Gateway NodePort 30080 |
| 유형 | 정상 |
| 테스트 항목 | Gateway 외부 직접 접속 |
| 사전 조건 | 보안 그룹 설정 |
| 입력값(테스트 데이터) | http://<노드>:30080/match-service/api/matches |
| 테스트 절차 | 1) 외부에서 호출 |
| 기대 결과 | 200 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |
| 비고(원 ID 등) | 보안 그룹상 30080 외부 접속 불가. 프론트 프록시 경유로만 확인(ST-DEP-05) |

### ST-DEP-08 — AWS 매치 생성 시연

| 항목 | 내용 |
| --- | --- |
| TC ID | ST-DEP-08 |
| 영역 | 배포 |
| 구분 | 신규 |
| 요구사항 ID | ④·EM-01 |
| API·대상 | AWS 환경 매치 생성 |
| 유형 | 정상 |
| 테스트 항목 | AWS 매치 생성 시연 |
| 사전 조건 | 회원 로그인, 시설 데이터 |
| 입력값(테스트 데이터) | 매치 생성 body |
| 테스트 절차 | 1) 화면에서 매치 생성 |
| 기대 결과 | 202 → CONFIRMED, 목록 노출 |
| 결과 | B |
| 실행일 | 2026-11-04 |
| 실행자 | 이상혁 |
| 근거·자동 테스트 | AWS 배포 확인 2026-11-04 00:10~00:15 KST (backend 2e4d4f7 / frontend 8b6bc9e) |
| 비고(원 ID 등) | 시설 데이터 0건(공공데이터 키 미설정)이라 생성 시연 불가 |

## 인수 테스트(AT)

### AT-01-01 — 비회원 둘러보기

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-01-01 |
| 시나리오명 | 비회원 둘러보기 |
| 구분 | 1차 |
| 요구사항 ID | EM-02·EM-03·FC-01·FC-02·AI-02·UI-01·UI-05 |
| 단계 | 1 |
| 화면 | / |
| 사용자 행동 | 메인 접속 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | AI 검색창·일정 보드·헤더 [로그인] |
| 관련 TC ID | IT-GW-01 |
| 결과 | 미실행 |

### AT-01-02 — 비회원 둘러보기

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-01-02 |
| 시나리오명 | 비회원 둘러보기 |
| 구분 | 1차 |
| 요구사항 ID | EM-02·EM-03·FC-01·FC-02·AI-02·UI-01·UI-05 |
| 단계 | 2 |
| 화면 | /matches/search |
| 사용자 행동 | 종목 풋살·강남구·초급 필터 |
| 입력값(테스트 데이터) | sportType=FUTSAL, district=GANGNAM |
| 기대 결과(화면에 보이는 것) | 조건에 맞는 모집 중 매치 카드만 보임 |
| 관련 TC ID | IT-EM-05 |
| 결과 | 미실행 |

### AT-01-03 — 비회원 둘러보기

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-01-03 |
| 시나리오명 | 비회원 둘러보기 |
| 구분 | 1차 |
| 요구사항 ID | EM-02·EM-03·FC-01·FC-02·AI-02·UI-01·UI-05 |
| 단계 | 3 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 매치 카드 클릭 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 시설명·장소·정원·상태 표시, [참가] 누르면 로그인 화면으로 이동 |
| 관련 TC ID | IT-EM-07 |
| 결과 | 미실행 |

### AT-01-04 — 비회원 둘러보기

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-01-04 |
| 시나리오명 | 비회원 둘러보기 |
| 구분 | 1차 |
| 요구사항 ID | EM-02·EM-03·FC-01·FC-02·AI-02·UI-01·UI-05 |
| 단계 | 4 |
| 화면 | /facilities |
| 사용자 행동 | 시설 목록 → 시설 클릭 |
| 입력값(테스트 데이터) | district=GANGNAM |
| 기대 결과(화면에 보이는 것) | 시설 상세·예약 링크(외부 사이트) 표시 |
| 관련 TC ID | IT-FC-01·IT-FC-03 |
| 결과 | 미실행 |

### AT-01-05 — 비회원 둘러보기

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-01-05 |
| 시나리오명 | 비회원 둘러보기 |
| 구분 | 1차 |
| 요구사항 ID | EM-02·EM-03·FC-01·FC-02·AI-02·UI-01·UI-05 |
| 단계 | 5 |
| 화면 | / |
| 사용자 행동 | AI 검색창에 문장 입력 |
| 입력값(테스트 데이터) | "이번 주말 강남 초급 풋살" |
| 기대 결과(화면에 보이는 것) | 조건 요약 칩과 결과 매치 목록 표시 |
| 관련 TC ID | IT-AI-03 |
| 결과 | 미실행 |

### AT-02-01 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-01 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 1 |
| 화면 | /signup |
| 사용자 행동 | 회원가입 입력 → [가입] |
| 입력값(테스트 데이터) | 회원 A: a01@test.io / Test1234! / 방장A |
| 기대 결과(화면에 보이는 것) | 가입 완료 후 로그인 화면 이동 |
| 관련 TC ID | IT-USR-01 |
| 결과 | 미실행 |

### AT-02-02 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-02 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 2 |
| 화면 | /login |
| 사용자 행동 | 로그인 |
| 입력값(테스트 데이터) | 회원 A |
| 기대 결과(화면에 보이는 것) | 헤더에 닉네임·알림 배지 |
| 관련 TC ID | IT-USR-03 |
| 결과 | 미실행 |

### AT-02-03 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-03 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 3 |
| 화면 | /mypage |
| 사용자 행동 | 포인트 확인 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 내 포인트 50점, 이력 "가입 지급" |
| 관련 TC ID | IT-PT-01 |
| 결과 | 미실행 |

### AT-02-04 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-04 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 4 |
| 화면 | /matches/new |
| 사용자 행동 | 시설 선택·일정·정원 입력 → [만들기] |
| 입력값(테스트 데이터) | 풋살, 2026-11-08 19:00~21:00, 정원 10 |
| 기대 결과(화면에 보이는 것) | "처리 중" → "확정", 보증금 10점 안내 |
| 관련 TC ID | IT-EM-01·ST-POINT-01 |
| 결과 | 미실행 |

### AT-02-05 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-05 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 5 |
| 화면 | /mypage |
| 사용자 행동 | 포인트 이력 확인 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 40점, DEPOSIT_CHARGED -10 |
| 관련 TC ID | IT-PT-02 |
| 결과 | 미실행 |

### AT-02-06 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-06 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 6 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 회원 B 로그인 후 [참가] |
| 입력값(테스트 데이터) | 회원 B (50점) |
| 기대 결과(화면에 보이는 것) | "처리 중" → "참가 확정", 참가 인원 2/10 |
| 관련 TC ID | IT-EM-12 |
| 결과 | 미실행 |

### AT-02-07 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-07 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 7 |
| 화면 | /notifications |
| 사용자 행동 | 회원 A 헤더 알림 배지 클릭 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | "참가 확정" 알림 1건, 안 읽은 개수 1 |
| 관련 TC ID | IT-NT-01·IT-NT-02·IT-EVT-05 |
| 결과 | 미실행 |

### AT-02-08 — 가입 → 매치 개설 → 참가 → 알림 → 포인트

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-02-08 |
| 시나리오명 | 가입 → 매치 개설 → 참가 → 알림 → 포인트 |
| 구분 | 변경 |
| 요구사항 ID | USR-01·PT-01·EM-01·PT-02·EM-06·EM-10·NT-01·NT-03·PT-05·UI-02·UI-04 |
| 단계 | 8 |
| 화면 | /notifications |
| 사용자 행동 | 알림 클릭(읽음) |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 배지 숫자 감소, 읽음 표시 |
| 관련 TC ID | IT-NT-03 |
| 결과 | 미실행 |

### AT-03-01 — 대기 등록과 자동 승급

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-03-01 |
| 시나리오명 | 대기 등록과 자동 승급 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·WL-02·NT-02·UI-03 |
| 단계 | 1 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 정원 찬 매치에서 [대기 등록] |
| 입력값(테스트 데이터) | 회원 C |
| 기대 결과(화면에 보이는 것) | 대기 순번 1 표시, 포인트 차감 없음 |
| 관련 TC ID | IT-WL-01 |
| 결과 | 미실행 |

### AT-03-02 — 대기 등록과 자동 승급

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-03-02 |
| 시나리오명 | 대기 등록과 자동 승급 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·WL-02·NT-02·UI-03 |
| 단계 | 2 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 확정 참가자 B가 [참가 취소] |
| 입력값(테스트 데이터) | 회원 B |
| 기대 결과(화면에 보이는 것) | B 보증금 반환, 인원 감소 |
| 관련 TC ID | IT-EM-17 |
| 결과 | 미실행 |

### AT-03-03 — 대기 등록과 자동 승급

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-03-03 |
| 시나리오명 | 대기 등록과 자동 승급 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·WL-02·NT-02·UI-03 |
| 단계 | 3 |
| 화면 | /notifications |
| 사용자 행동 | 회원 C 알림 확인 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | "대기 승급" 알림, C 참가 확정·10점 차감 |
| 관련 TC ID | IT-WL-04 |
| 결과 | 미실행 |

### AT-03-04 — 대기 등록과 자동 승급

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-03-04 |
| 시나리오명 | 대기 등록과 자동 승급 |
| 구분 | 신규 |
| 요구사항 ID | WL-01·WL-02·NT-02·UI-03 |
| 단계 | 4 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 회원 D가 [대기 취소] |
| 입력값(테스트 데이터) | 회원 D |
| 기대 결과(화면에 보이는 것) | 대기 목록에서 빠짐 |
| 관련 TC ID | IT-WL-03 |
| 결과 | 미실행 |

### AT-04-01 — 출석 체크와 정산

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-04-01 |
| 시나리오명 | 출석 체크와 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·PT-03·PT-04·UI-04 |
| 단계 | 1 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 진행 중 매치에서 방장이 참가자 [노쇼] 체크 |
| 입력값(테스트 데이터) | 참가자 E |
| 기대 결과(화면에 보이는 것) | E 상태 노쇼 표시(방장 화면만) |
| 관련 TC ID | IT-ATT-01·IT-ATT-09 |
| 결과 | 미실행 |

### AT-04-02 — 출석 체크와 정산

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-04-02 |
| 시나리오명 | 출석 체크와 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·PT-03·PT-04·UI-04 |
| 단계 | 2 |
| 화면 | /matches/:matchId |
| 사용자 행동 | 종료 후 다시 보기 |
| 입력값(테스트 데이터) | 종료 시각 + 1분 |
| 기대 결과(화면에 보이는 것) | 상태 "완료", 출석 수정 버튼 비활성 |
| 관련 TC ID | IT-SET-01·IT-ATT-05 |
| 결과 | 미실행 |

### AT-04-03 — 출석 체크와 정산

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-04-03 |
| 시나리오명 | 출석 체크와 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·PT-03·PT-04·UI-04 |
| 단계 | 3 |
| 화면 | /mypage |
| 사용자 행동 | 출석자 포인트 이력 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 보증금 반환 +10, 누적 출석 +1 |
| 관련 TC ID | IT-SET-08 |
| 결과 | 미실행 |

### AT-04-04 — 출석 체크와 정산

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-04-04 |
| 시나리오명 | 출석 체크와 정산 |
| 구분 | 신규 |
| 요구사항 ID | EM-11·PT-03·PT-04·UI-04 |
| 단계 | 4 |
| 화면 | /mypage |
| 사용자 행동 | 노쇼자(0점) 포인트·정지 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 반환 없음, 참여 정지 종료 시각 표시, 매치 참가 시 "참여 정지" 안내 |
| 관련 TC ID | IT-SET-09·IT-WL-02 |
| 결과 | 미실행 |

### AT-05-01 — 방장의 매치 수정·취소

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-05-01 |
| 시나리오명 | 방장의 매치 수정·취소 |
| 구분 | 변경 |
| 요구사항 ID | EM-04·EM-05·PT-02·NT-01·UI-03 |
| 단계 | 1 |
| 화면 | /matches/:matchId/edit |
| 사용자 행동 | 정원 수정 |
| 입력값(테스트 데이터) | 정원 10 → 12 |
| 기대 결과(화면에 보이는 것) | 상세에 정원 12, 인원 보존 |
| 관련 TC ID | IT-EM-09 |
| 결과 | 미실행 |

### AT-05-02 — 방장의 매치 수정·취소

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-05-02 |
| 시나리오명 | 방장의 매치 수정·취소 |
| 구분 | 변경 |
| 요구사항 ID | EM-04·EM-05·PT-02·NT-01·UI-03 |
| 단계 | 2 |
| 화면 | /matches/:matchId/edit |
| 사용자 행동 | 현재 인원보다 작게 수정 |
| 입력값(테스트 데이터) | 정원 → 1 |
| 기대 결과(화면에 보이는 것) | 오류 안내, 정보 그대로 |
| 관련 TC ID | IT-EM-08·IT-EM-03 |
| 결과 | 미실행 |

### AT-05-03 — 방장의 매치 수정·취소

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-05-03 |
| 시나리오명 | 방장의 매치 수정·취소 |
| 구분 | 변경 |
| 요구사항 ID | EM-04·EM-05·PT-02·NT-01·UI-03 |
| 단계 | 3 |
| 화면 | /matches/:matchId |
| 사용자 행동 | [매치 취소] → 확인 |
| 입력값(테스트 데이터) | 사유 입력 |
| 기대 결과(화면에 보이는 것) | 상태 "취소됨"으로 남음(목록에서 상태 표시) |
| 관련 TC ID | IT-EM-11 |
| 결과 | 미실행 |

### AT-05-04 — 방장의 매치 수정·취소

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-05-04 |
| 시나리오명 | 방장의 매치 수정·취소 |
| 구분 | 변경 |
| 요구사항 ID | EM-04·EM-05·PT-02·NT-01·UI-03 |
| 단계 | 4 |
| 화면 | /notifications |
| 사용자 행동 | 참가자 알림 확인 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | "매치 취소" 알림과 사유, 보증금 반환 이력 |
| 관련 TC ID | IT-EVT-05·IT-EM-10 |
| 결과 | 미실행 |

### AT-06-01 — 회원 탈퇴

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-06-01 |
| 시나리오명 | 회원 탈퇴 |
| 구분 | 변경 |
| 요구사항 ID | USR-04·EM-13·UI-02·NFR-03 |
| 단계 | 1 |
| 화면 | /mypage |
| 사용자 행동 | [회원 탈퇴] → 비밀번호 입력 |
| 입력값(테스트 데이터) | 회원 A 비밀번호 |
| 기대 결과(화면에 보이는 것) | 탈퇴 API 202 접수 후 Access·Refresh 세션 삭제, /login 이동 |
| 관련 TC ID | IT-USR-12 |
| 결과 | 미실행 |

### AT-06-02 — 회원 탈퇴

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-06-02 |
| 시나리오명 | 회원 탈퇴 |
| 구분 | 변경 |
| 요구사항 ID | USR-04·EM-13·UI-02·NFR-03 |
| 단계 | 2 |
| 화면 | /mypage |
| 사용자 행동 | 잠시 후 새로고침 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | "탈퇴 완료" → 로그아웃, 방장 매치는 취소됨 |
| 관련 TC ID | ST-SAGA-01 |
| 결과 | 미실행 |

### AT-06-03 — 회원 탈퇴

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-06-03 |
| 시나리오명 | 회원 탈퇴 |
| 구분 | 변경 |
| 요구사항 ID | USR-04·EM-13·UI-02·NFR-03 |
| 단계 | 3 |
| 화면 | /login |
| 사용자 행동 | 탈퇴 계정으로 로그인 |
| 입력값(테스트 데이터) | 회원 A |
| 기대 결과(화면에 보이는 것) | 로그인 실패 안내 |
| 관련 TC ID | IT-USR-05 |
| 결과 | 미실행 |

### AT-06-04 — 회원 탈퇴

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-06-04 |
| 시나리오명 | 회원 탈퇴 |
| 구분 | 변경 |
| 요구사항 ID | USR-04·EM-13·UI-02·NFR-03 |
| 단계 | 4 |
| 화면 | /mypage |
| 사용자 행동 | 진행 중 매치 방장이 탈퇴 요청 |
| 입력값(테스트 데이터) | 회원 F |
| 기대 결과(화면에 보이는 것) | "탈퇴 거절" 안내·알림, 회원 상태 유지 |
| 관련 TC ID | ST-SAGA-02 |
| 결과 | 미실행 |

### AT-07-01 — 관리자 대시보드

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-07-01 |
| 시나리오명 | 관리자 대시보드 |
| 구분 | 신규 |
| 요구사항 ID | AD-01·AD-02·AD-03·AD-04·USR-07·⑧ |
| 단계 | 1 |
| 화면 | /login |
| 사용자 행동 | 관리자 계정 로그인 |
| 입력값(테스트 데이터) | 초기 관리자 계정 |
| 기대 결과(화면에 보이는 것) | 헤더에 관리자 메뉴 |
| 관련 TC ID | IT-GW-06 |
| 결과 | 미실행 |

### AT-07-02 — 관리자 대시보드

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-07-02 |
| 시나리오명 | 관리자 대시보드 |
| 구분 | 신규 |
| 요구사항 ID | AD-01·AD-02·AD-03·AD-04·USR-07·⑧ |
| 단계 | 2 |
| 화면 | /admin/dashboard |
| 사용자 행동 | 서비스 상태 탭 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 서비스별 UP·오류율·API 오류 표시 (A30·A31 호출) |
| 관련 TC ID | IT-AD-03·ST-OBS-06 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 비고 | react-browser-check.json |

### AT-07-03 — 관리자 대시보드

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-07-03 |
| 시나리오명 | 관리자 대시보드 |
| 구분 | 신규 |
| 요구사항 ID | AD-01·AD-02·AD-03·AD-04·USR-07·⑧ |
| 단계 | 3 |
| 화면 | /admin/dashboard |
| 사용자 행동 | 도메인 탭 |
| 입력값(테스트 데이터) | - |
| 기대 결과(화면에 보이는 것) | 탈퇴 Saga 성공·거절·시간 초과(A28)와 도메인 지표(Prometheus A30·A31) 표시 |
| 관련 TC ID | IT-AD-01·IT-AD-02·ST-OBS-06 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 비고 | react-browser-check.json |

### AT-07-04 — 관리자 대시보드

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-07-04 |
| 시나리오명 | 관리자 대시보드 |
| 구분 | 신규 |
| 요구사항 ID | AD-01·AD-02·AD-03·AD-04·USR-07·⑧ |
| 단계 | 4 |
| 화면 | /admin/dashboard |
| 사용자 행동 | 시간 범위·서비스 필터 변경 |
| 입력값(테스트 데이터) | 1시간 → 6시간, match-service |
| 기대 결과(화면에 보이는 것) | 그래프가 선택 범위·서비스로 다시 그려짐 |
| 관련 TC ID | IT-AD-03 |
| 결과 | P |
| 실행일 | 2026-11-03 |
| 비고 | react-browser-check.json |

### AT-07-05 — 관리자 대시보드

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-07-05 |
| 시나리오명 | 관리자 대시보드 |
| 구분 | 신규 |
| 요구사항 ID | AD-01·AD-02·AD-03·AD-04·USR-07·⑧ |
| 단계 | 5 |
| 화면 | /admin/dashboard |
| 사용자 행동 | 일반 회원으로 접근 |
| 입력값(테스트 데이터) | 회원 B |
| 기대 결과(화면에 보이는 것) | 접근 거부 안내 (API 403) |
| 관련 TC ID | IT-GW-06 |
| 결과 | 미실행 |

### AT-08-01 — AI 초안·맞춤 추천

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-08-01 |
| 시나리오명 | AI 초안·맞춤 추천 |
| 구분 | 1차 |
| 요구사항 ID | AI-01·AI-03·AI-04·FC-04 |
| 단계 | 1 |
| 화면 | / |
| 사용자 행동 | AI 초안 입력 → [만들기] |
| 입력값(테스트 데이터) | "토요일 저녁 7시 강남 풋살 10명" |
| 기대 결과(화면에 보이는 것) | /matches/new에 종목·일시·정원·시설 후보가 채워짐 (저장 전) |
| 관련 TC ID | IT-AI-01·IT-INT-04 |
| 결과 | 미실행 |

### AT-08-02 — AI 초안·맞춤 추천

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-08-02 |
| 시나리오명 | AI 초안·맞춤 추천 |
| 구분 | 1차 |
| 요구사항 ID | AI-01·AI-03·AI-04·FC-04 |
| 단계 | 2 |
| 화면 | / |
| 사용자 행동 | 로그인 후 추천 영역 확인 |
| 입력값(테스트 데이터) | 회원 A (선호 FUTSAL) |
| 기대 결과(화면에 보이는 것) | 추천 매치 최대 3건 |
| 관련 TC ID | IT-AI-06 |
| 결과 | 미실행 |

### AT-08-03 — AI 초안·맞춤 추천

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-08-03 |
| 시나리오명 | AI 초안·맞춤 추천 |
| 구분 | 1차 |
| 요구사항 ID | AI-01·AI-03·AI-04·FC-04 |
| 단계 | 3 |
| 화면 | / |
| 사용자 행동 | LLM 장애 상태에서 검색·추천 |
| 입력값(테스트 데이터) | Mock/LLM timeout |
| 기대 결과(화면에 보이는 것) | 오류 화면 없이 대체 결과 표시 |
| 관련 TC ID | IT-AI-08 |
| 결과 | 미실행 |

### AT-09-01 — 시작 하루 전 알림

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-09-01 |
| 시나리오명 | 시작 하루 전 알림 |
| 구분 | 신규 |
| 요구사항 ID | EM-12·NT-02 |
| 단계 | 1 |
| 화면 | /notifications |
| 사용자 행동 | 시작 24시간 이내 매치의 참가자 알림 확인 |
| 입력값(테스트 데이터) | 방장·확정 참가자 |
| 기대 결과(화면에 보이는 것) | "내일 19:00 시작" 알림 1건(대기자 제외) |
| 관련 TC ID | IT-EVT-05 |
| 결과 | 미실행 |

### AT-09-02 — 시작 하루 전 알림

| 항목 | 내용 |
| --- | --- |
| 시나리오 ID | AT-09-02 |
| 시나리오명 | 시작 하루 전 알림 |
| 구분 | 신규 |
| 요구사항 ID | EM-12·NT-02 |
| 단계 | 2 |
| 화면 | /notifications |
| 사용자 행동 | 매치 취소 후 확인 |
| 입력값(테스트 데이터) | 취소된 매치 |
| 기대 결과(화면에 보이는 것) | 하루 전 알림 없음 |
| 관련 TC ID | IT-EVT-05 |
| 결과 | 미실행 |

## 요구사항 추적

| 요구사항 ID | 요구사항 | 종류 | 구분 | 단위(UT) | 통합(IT) | 시스템(ST) | 인수(AT) | 결과 요약(UT·IT·ST) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| USR-01 | 회원가입(가입 시 50점) | 기능 | 변경 | UT-US-01, UT-US-12 | IT-USR-01, IT-USR-02 |  | AT-02 | P 2 · 미실행 2 |
| USR-02 | 로그인 | 기능 | 1차 |  | IT-USR-03, IT-USR-04, IT-USR-05 |  |  | 미실행 3 |
| USR-03 | 로그아웃 | 기능 | 1차 |  | IT-USR-06 |  |  | 미실행 1 |
| USR-04 | 회원 탈퇴(탈퇴 Saga) | 기능 | 변경 | UT-US-15, UT-US-16 | IT-USR-05, IT-USR-12, IT-USR-13 | ST-SAGA-01, ST-SAGA-02, ST-SAGA-03, ST-SAGA-04, ST-SAGA-05 | AT-06 | P 7 · 미실행 3 |
| USR-05 | 토큰 재발급 | 기능 | 1차 | UT-US-04 | IT-USR-07 |  |  | P 1 · 미실행 1 |
| USR-06 | 내 정보 조회 | 기능 | 1차 |  | IT-USR-08 |  |  | 미실행 1 |
| USR-07 | 회원 역할 USER·ADMIN | 기능 | 신규 | UT-US-02 | IT-GW-06 |  | AT-07 | P 1 · 미실행 1 |
| USR-08 | 내부 회원 조회(I1·I2) | 기능 | 신규 | UT-MT-08, UT-MT-09, UT-US-13 | IT-INT-01, IT-INT-02 |  |  | P 2 · B 1 · 미실행 2 |
| PR-01 | 프로필 수정 | 기능 | 1차 | UT-US-12 | IT-USR-09, IT-USR-10 |  |  | P 1 · 미실행 2 |
| PR-02 | 프로필 조회 | 기능 | 1차 |  | IT-USR-11 |  |  | 미실행 1 |
| GW-01 | 단일 진입점·라우팅 | 기능 | 신규 |  | IT-GW-01 | ST-DEP-01 |  | P 1 · 미실행 1 |
| GW-02 | JWT 검증·회원 정보 전달 | 기능 | 신규 | UT-GW-01, UT-GW-02 | IT-GW-03, IT-GW-04, IT-ATT-04 | ST-NFR-01 |  | P 2 · 미실행 4 |
| GW-03 | 관리자 경로 보호 | 기능 | 신규 | UT-GW-01, UT-GW-02 | IT-GW-06, IT-AD-03 | ST-NFR-01 |  | P 2 · 미실행 3 |
| GW-04 | 내부 경로 차단 | 기능 | 신규 | UT-GW-01, UT-GW-03 | IT-GW-02, IT-GW-05 | ST-NFR-01 |  | P 2 · 미실행 3 |
| GW-05 | CORS | 기능 | 신규 |  | IT-GW-07 |  |  | 미실행 1 |
| EM-01 | 매치 생성 | 기능 | 변경 | UT-MT-02 | IT-EM-01, IT-EM-02, IT-EM-03, IT-EM-04 | ST-POINT-01, ST-DEP-08 | AT-02 | P 2 · B 1 · 미실행 4 |
| EM-02 | 매치 목록·검색 | 기능 | 1차 | UT-MT-02 | IT-EM-05, IT-EM-06 |  | AT-01 | P 1 · 미실행 2 |
| EM-03 | 매치 상세 | 기능 | 1차 | UT-MT-02 | IT-EM-07, IT-ATT-09 |  | AT-01 | P 1 · 미실행 2 |
| EM-04 | 매치 수정 | 기능 | 변경 | UT-MT-02, UT-MT-06 | IT-EM-03, IT-EM-08, IT-EM-09 |  | AT-05 | P 2 · 미실행 3 |
| EM-05 | 매치 취소(CANCELLED 보존) | 기능 | 변경 | UT-MT-06 | IT-EM-10, IT-EM-11 |  | AT-05 | P 1 · 미실행 2 |
| EM-06 | 매치 참가(202·확정) | 기능 | 변경 | UT-MT-04, UT-MT-15 | IT-EM-12, IT-EM-13, IT-EM-14, IT-EM-15, IT-EM-16 | ST-POINT-01 | AT-02 | P 3 · 미실행 5 |
| EM-07 | 참가 취소 | 기능 | 변경 | UT-MT-15 | IT-EM-17 | ST-POINT-03 |  | P 2 · 미실행 1 |
| EM-08 | 내 매치 목록 | 기능 | 1차 |  | IT-EM-18 |  |  | 미실행 1 |
| EM-09 | 상태 전이·스케줄러 | 기능 | 신규 | UT-MT-06, UT-MT-10, UT-MT-11 | IT-SET-01, IT-SET-05 |  |  | P 3 · 미실행 2 |
| EM-10 | 참가 요청 관리(requestId) | 기능 | 신규 | UT-MT-04 | IT-EM-01, IT-EM-19, IT-SET-02 | ST-POINT-01 | AT-02 | P 2 · 미실행 3 |
| EM-11 | 출석 관리 | 기능 | 신규 | UT-MT-11 | IT-ATT-01, IT-ATT-02, IT-ATT-03, IT-ATT-04, IT-ATT-05, IT-ATT-06, IT-ATT-07, IT-ATT-08, IT-ATT-09, IT-SET-01, IT-SET-02, IT-SET-06, IT-SET-11 | ST-POINT-04 | AT-04 | P 2 · 미실행 13 |
| EM-12 | 시작 하루 전 알림 | 기능 | 신규 | UT-MT-16 |  |  | AT-09 | P 1 |
| EM-13 | 탈퇴 회원 정리 | 기능 | 신규 | UT-MT-25 | IT-INT-05 | ST-SAGA-01, ST-SAGA-02 | AT-06 | P 3 · 미실행 1 |
| WL-01 | 대기 등록·취소 | 기능 | 신규 | UT-MT-19 | IT-WL-01, IT-WL-02, IT-WL-03 |  | AT-03 | P 1 · 미실행 3 |
| WL-02 | 자동 승급 | 기능 | 신규 | UT-MT-04, UT-MT-19 | IT-EM-17, IT-WL-04 |  | AT-03 | P 2 · 미실행 2 |
| FC-01 | 시설 목록 | 기능 | 1차 | UT-FC-01 | IT-FC-01, IT-FC-02 |  | AT-01 | P 1 · 미실행 2 |
| FC-02 | 시설 상세 | 기능 | 1차 | UT-FC-01 | IT-FC-03, IT-FC-04, IT-FC-05, IT-FC-06 |  | AT-01 | P 1 · 미실행 4 |
| FC-03 | 공공데이터 일일 동기화 | 기능 | 1차 | UT-FC-03 | IT-FC-02 | ST-NFR-14 |  | P 1 · 미실행 2 |
| FC-04 | 내부 시설 조회(I3·I4) | 기능 | 신규 | UT-AI-01, UT-FC-01, UT-MT-07, UT-MT-09 | IT-EM-02, IT-INT-03, IT-INT-04 |  | AT-08 | P 3 · B 1 · 미실행 3 |
| FC-05 | 거리 표시(P2) | 기능 | 신규 |  |  |  |  | 미구현(P2) · TC 없음 |
| AI-01 | AI 매치 초안 | 기능 | 1차 | UT-AI-01 | IT-AI-01, IT-AI-02 |  | AT-08 | P 1 · 미실행 2 |
| AI-02 | 자연어 매치 검색 | 기능 | 1차 | UT-AI-05 | IT-AI-03, IT-AI-04, IT-AI-05 |  | AT-01 | P 1 · 미실행 3 |
| AI-03 | 맞춤 매치 추천 | 기능 | 1차 | UT-AI-04 | IT-AI-06, IT-AI-07 |  | AT-08 | P 1 · 미실행 2 |
| AI-04 | 대체 응답·AI 지표 | 기능 | 신규 | UT-AI-03, UT-AI-04, UT-AI-05, UT-AI-06, UT-AI-07, UT-AI-09 | IT-AI-08 | ST-NFR-14 | AT-08 | P 6 · 미실행 2 |
| NT-01 | 이벤트 알림 저장 | 기능 | 신규 | UT-MT-13, UT-NT-01, UT-NT-04 | IT-EVT-05 | ST-SAGA-02, ST-OBS-04 | AT-02, AT-05 | P 5 · 미실행 1 |
| NT-02 | 대기 승급·하루 전 알림 | 기능 | 신규 | UT-NT-01, UT-NT-06 | IT-WL-04, IT-EVT-05 |  | AT-03, AT-09 | P 2 · 미실행 2 |
| NT-03 | 알림함 | 기능 | 신규 | UT-NT-02 | IT-NT-01, IT-NT-02, IT-NT-03 |  | AT-02 | P 1 · 미실행 3 |
| PT-01 | 포인트 보유(0~100, 가입 50) | 기능 | 신규 |  | IT-USR-01, IT-PT-01 |  | AT-02 | 미실행 2 |
| PT-02 | 참가 보증금 10점 | 기능 | 신규 | UT-MT-03, UT-MT-04, UT-MT-14, UT-US-06, UT-US-07 | IT-EM-01, IT-EM-12, IT-EM-17, IT-WL-04, IT-EVT-02 | ST-POINT-01, ST-POINT-02, ST-POINT-03 | AT-02, AT-05 | P 7 · B 1 · 미실행 5 |
| PT-03 | 출석 정산 | 기능 | 신규 | UT-MT-11, UT-US-11 | IT-EVT-03, IT-SET-03, IT-SET-07, IT-SET-08, IT-SET-09 | ST-POINT-04 | AT-04 | P 3 · 미실행 5 |
| PT-04 | 참여 정지·해제 | 기능 | 신규 | UT-MT-05, UT-US-09, UT-US-10, UT-US-11 | IT-WL-02, IT-EVT-04, IT-SET-09 | ST-POINT-02, ST-POINT-04 | AT-04 | P 6 · 미실행 3 |
| PT-05 | 포인트 조회·이력 | 기능 | 신규 | UT-US-01 | IT-PT-01, IT-PT-02 |  | AT-02 | P 1 · 미실행 2 |
| PT-06 | 중복·동시성 방지 | 기능 | 신규 | UT-US-06, UT-US-08, UT-US-11 | IT-EM-13, IT-SET-04, IT-SET-10 | ST-POINT-02, ST-POINT-03, ST-OBS-03 |  | P 6 · 미실행 3 |
| AD-01 | 모임·참가 통계 | 기능 | 신규 | UT-MT-18 | IT-AD-01 |  | AT-07 | P 1 · 미실행 1 |
| AD-02 | 탈퇴 Saga 통계 | 기능 | 신규 | UT-US-03 | IT-AD-02 | ST-OBS-06 | AT-07 | P 2 · 미실행 1 |
| AD-03 | 지표 조회(Prometheus) | 기능 | 신규 |  | IT-AD-03 | ST-OBS-06 | AT-07 | P 1 · 미실행 1 |
| AD-04 | 관리자 대시보드 | 기능 | 신규 | UT-FE-01 |  | ST-OBS-06 | AT-07 | P 2 |
| UI-01 | Gateway 연결 | 기능 | 변경 | UT-FE-01 | IT-GW-01 | ST-DEP-05 | AT-01 | P 2 · 미실행 1 |
| UI-02 | 알림함·탈퇴 상태 화면 | 기능 | 신규 | UT-FE-01 |  |  | AT-02, AT-06 | P 1 |
| UI-03 | 매치 상태·취소·대기 화면 | 기능 | 신규 | UT-FE-01 |  |  | AT-03, AT-05 | P 1 |
| UI-04 | 포인트 화면 | 기능 | 신규 | UT-FE-01 |  |  | AT-02, AT-04 | P 1 |
| UI-05 | 화면 리뉴얼 | 기능 | 변경 | UT-FE-01 |  |  | AT-01 | P 1 |
| MSA-1 | 마이크로서비스 분리 | 비기능 | 신규 |  |  | ST-DEP-01 |  | P 1 |
| MSA-2 | Service Discovery(Eureka) | 비기능 | 신규 |  |  | ST-NFR-11 |  | 미실행 1 |
| MSA-3 | API Gateway | 비기능 | 신규 |  | IT-GW-01 |  |  | 미실행 1 |
| MSA-4 | Config 중앙화 | 비기능 | 신규 |  |  | ST-NFR-02 |  | 미실행 1 |
| MSA-5 | 동기 통신(OpenFeign) | 비기능 | 신규 |  | IT-INT-01, IT-INT-03, IT-INT-06 |  |  | 미실행 3 |
| MSA-6 | 비동기 통신(Kafka 14종) | 비기능 | 신규 |  | IT-EVT-01, IT-EVT-02, IT-EVT-03, IT-EVT-04, IT-EVT-05 |  |  | 미실행 5 |
| MSA-7 | 도메인 API·상태 관리 | 비기능 | 신규 | UT-MT-06 | IT-EM-01, IT-EM-11, IT-SET-01 |  |  | P 1 · 미실행 3 |
| MSA-8 | 서비스별 DB 분리 | 비기능 | 신규 | UT-MT-17 |  | ST-NFR-09, ST-NFR-10 |  | P 1 · 미실행 2 |
| MSA-9 | 컨테이너화(Compose) | 비기능 | 신규 |  |  | ST-DEP-01, ST-DEP-02 |  | P 1 · 미실행 1 |
| MON-1 | 모니터링 지표 수집 | 비기능 | 신규 | UT-AI-09, UT-NT-05 |  | ST-OBS-06, ST-OBS-08 |  | P 4 |
| MON-2 | 대시보드 5종 | 비기능 | 신규 |  |  | ST-OBS-05, ST-DEP-06 |  | P 2 |
| MON-3 | 경보 | 비기능 | 신규 |  |  | ST-OBS-07 |  | 미실행 1 |
| MON-4 | 장애 분석 4종 | 비기능 | 신규 |  |  | ST-OBS-01, ST-OBS-02, ST-OBS-03, ST-OBS-04 |  | P 4 |
| ① | Spring Cloud Bus | 비기능 | 신규 |  |  | ST-NFR-04, ST-DEP-06 |  | P 1 · 미실행 1 |
| ② | 설정 암호화 {cipher} | 비기능 | 신규 | UT-CFG-01, UT-CFG-02 |  | ST-NFR-05 |  | P 2 · 미실행 1 |
| ③ | Kubernetes 배포 | 비기능 | 신규 |  |  | ST-DEP-04 |  | P 1 |
| ④ | 클라우드 실배포(AWS) | 비기능 | 신규 |  |  | ST-OBS-08, ST-DEP-05, ST-DEP-06, ST-DEP-07, ST-DEP-08 |  | P 3 · B 2 |
| ⑤ | Circuit Breaker | 비기능 | 신규 | UT-MT-07, UT-MT-09 | IT-INT-06 | ST-OBS-01, ST-NFR-07 |  | P 2 · B 1 · 미실행 2 |
| ⑥ | 분산 추적(Zipkin) | 비기능 | 신규 |  |  | ST-OBS-02, ST-NFR-06 |  | P 2 |
| ⑦ | 부하 테스트(k6) | 비기능 | 신규 |  |  | ST-OBS-03, ST-NFR-13 |  | P 1 · 미실행 1 |
| ⑧ | 관리자 대시보드 | 비기능 | 신규 |  |  |  | AT-07 | AT만 |
| ⑨ | 알림 연동(Discord) | 비기능 | 신규 |  |  | ST-OBS-07 |  | 미실행 1 |
| ⑩ | 추가 핵심기술 Saga | 비기능 | 신규 |  |  | ST-SAGA-01, ST-POINT-01 |  | P 2 |
| NFR-01 | 성능 | 비기능 | 신규 |  |  | ST-OBS-03, ST-NFR-13 |  | P 1 · 미실행 1 |
| NFR-02 | 가용성 | 비기능 | 신규 | UT-MT-09 | IT-EM-04, IT-AI-08, IT-INT-06 | ST-OBS-01, ST-NFR-07, ST-NFR-14 |  | P 2 · 미실행 5 |
| NFR-03 | 정합성(Saga) | 비기능 | 신규 | UT-MT-20, UT-MT-22, UT-MT-24, UT-MT-25, UT-US-14, UT-US-15, UT-US-16 | IT-INT-05, IT-EVT-01 | ST-SAGA-01, ST-SAGA-02, ST-SAGA-03, ST-SAGA-04, ST-SAGA-05 | AT-06 | P 12 · 미실행 2 |
| NFR-04 | 신뢰성(이벤트) | 비기능 | 신규 | UT-MT-03, UT-MT-12, UT-MT-13, UT-MT-21, UT-MT-23, UT-MT-24, UT-NT-01, UT-NT-07, UT-US-05, UT-US-07, UT-US-14 | IT-EVT-06, IT-EVT-07, IT-EVT-08, IT-SET-06 | ST-OBS-04 |  | P 10 · B 2 · 미실행 4 |
| NFR-05 | 보안 | 비기능 | 신규 | UT-CFG-01, UT-CFG-02, UT-GW-02 | IT-GW-02, IT-GW-03, IT-AI-05 | ST-NFR-01, ST-NFR-05, ST-NFR-09, ST-NFR-12 |  | P 3 · 미실행 7 |
| NFR-06 | 관측성·공통 에러 형식 | 비기능 | 신규 | UT-AI-02, UT-FC-02, UT-MT-01, UT-NT-03 |  | ST-OBS-02, ST-NFR-06, ST-NFR-08 |  | P 6 · 미실행 1 |
| NFR-07 | 운영 환경 3개 프로필 | 비기능 | 신규 | UT-AI-08 |  | ST-NFR-02, ST-NFR-03 |  | P 1 · 미실행 2 |
| NFR-08 | CI·협업 자동화 | 비기능 | 신규 |  |  | ST-DEP-03 |  | P 1 |

## 11종 재시험

| 통합 TC ID | 원 11종 ID | 실행일 | 핵심 실제 결과 |
| --- | --- | --- | --- |
| ST-SAGA-01 | TC-SAGA-001 | 2026-11-03 | 방장 탈퇴 202→CLEANED/WITHDRAWN, 소유 매치 취소, 타 참가자 이력·환불 보존 |
| ST-SAGA-02 | TC-SAGA-002 | 2026-11-03 | 진행 중 방장 202→REJECTED/ACTIVE, 매치·포인트 불변, 거절 알림 1건 |
| ST-SAGA-03 | TC-SAGA-003 | 2026-11-04 | A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |
| ST-SAGA-04 | TC-SAGA-003 | 2026-11-04 | A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |
| ST-SAGA-05 | TC-SAGA-003 | 2026-11-04 | A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 |
| ST-POINT-01 | TC-POINT-001 | 2026-11-03 | CREATE/JOIN 202→CONFIRMED, 각 50→40점·차감 1회, Kafka/DB 일치 |
| ST-POINT-02 | TC-POINT-002 | 2026-11-03 | 잔액 부족 FAILED, 정지 403, 비활성 400; 무차감·정상 계정 회귀 |
| ST-POINT-03 | TC-POINT-003 | 2026-11-04 | 기존 취소·성별 불일치/환불에 더해 차감 전 취소, 5분 만료·늦은 CHARGED, 동일·새 eventId 재전달까지 확인 |
| ST-POINT-04 | TC-POINT-004 | 2026-11-03 | 출석 5회 보상, 노쇼 몰수·정지, 최소 인원 미달 반환, 중복 정산 불변 |
| ST-OBS-01 | TC-OBS-001 | 2026-11-03 | Facility DOWN 중 신규 A9 503, 기존 A11 200·스냅샷 불변, 1→0→1 복구 |
| ST-OBS-02 | TC-OBS-002 | 2026-11-03 | Facility 1.5초 지연: 168→1,902ms, Zipkin trace, 원복 뒤 확정 |
| ST-OBS-03 | TC-OBS-003 | 2026-11-03 | 100 VU·60초 5,517건·실패 0, 참가 100→확정 9/환불 91, DB 10/10 |
| ST-OBS-04 | TC-OBS-004 | 2026-11-03 | Notification DOWN 중 참가 5건 확정, Lag 0→5→0, 알림·재처리 중복 없음 |
| 11개 원 시나리오가 13개 ST 행으로 연결됨. 다른 UT·IT·AT 판정은 유지. 전체 243 / P87 F0 B6 미실행150. |  |  |  |

## 부록: 11종 최종 실행 보고서

### Sporty v2 R10 v0.6 통합 E2E 최종 실행 보고서

> 사용자 제공 최종 보고서의 판정을 반영했습니다. 본문에 적힌 PNG·JSON·verdict 등 상대 증거 파일은 이번에 첨부되지 않았으므로 경로를 텍스트로 보존합니다. 이 저장소 정리 과정에서 시험을 다시 실행한 것은 아닙니다.

| 항목 | 결과 |
| --- | --- |
| 실행일 | 최초 2026-11-03, BLOCKED 2종 재시험 완료 2026-11-04 KST |
| 판정 | **PASS 11 · FAIL 0 · BLOCKED 0 · NOT RUN 0** |
| 코드 기준 | Backend `bacaa84518029c7c2656a2be64e4c2223bcc5e31`, Frontend `e01fdbfec10ddbbb09586dd55906a367d7d38d49`, Config `8695cafaab132caec94232cae2b9e03a58d746bb` (각 최신 main) |
| 시험 환경 | 별도 Compose 프로젝트 `sporty-k6-90`, Gateway `:18090`, Prometheus `:19090`, Grafana `:13001`; 개발 프로젝트 `sporty` 미기동, 개발 볼륨 보존 |
| 코드 변경 | Backend 업무 코드 및 Frontend 추적 파일 변경 없음. Commit·Push·PR 없음 |

### 1. 11종 판정

| 케이스 | 판정 | 핵심 실제 결과 | 케이스 증거 |
| --- | --- | --- | --- |
| TC-SAGA-001 | PASS | 방장 탈퇴 202→CLEANED/WITHDRAWN, 소유 매치 취소, 타 참가자 이력·환불 보존 | 세부 결과 (증거 경로: `./TC-SAGA-001/verdict.md`) |
| TC-SAGA-002 | PASS | 진행 중 방장 202→REJECTED/ACTIVE, 매치·포인트 불변, 거절 알림 1건 | 세부 결과 (증거 경로: `./TC-SAGA-002/verdict.md`) |
| TC-SAGA-003 | PASS | A/C 기한 전 결과 커밋·발행 지연 후 내부 재조회 확정, B NONE→TIMED_OUT, D 조회 실패 6회 뒤 정상 복구; 늦은 Kafka 결과·재전달 불변 | 재시험 결과 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/verdict.md`) |
| TC-POINT-001 | PASS | CREATE/JOIN 202→CONFIRMED, 각 50→40점·차감 1회, Kafka/DB 일치 | 세부 결과 (증거 경로: `./TC-POINT-001/verdict.md`) |
| TC-POINT-002 | PASS | 잔액 부족 FAILED, 정지 403, 비활성 400; 무차감·정상 계정 회귀 | 세부 결과 (증거 경로: `./TC-POINT-002/verdict.md`) |
| TC-POINT-003 | PASS | 기존 취소·성별 불일치/환불에 더해 차감 전 취소, 5분 만료·늦은 CHARGED, 동일·새 eventId 재전달까지 확인 | 재시험 결과 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/verdict.md`) |
| TC-POINT-004 | PASS | 출석 5회 보상, 노쇼 몰수·정지, 최소 인원 미달 반환, 중복 정산 불변 | 세부 결과 (증거 경로: `./TC-POINT-004/verdict.md`) |
| TC-OBS-001 | PASS | Facility DOWN 중 신규 A9 503, 기존 A11 200·스냅샷 불변, 1→0→1 복구 | 세부 결과 (증거 경로: `./TC-OBS-001/verdict.md`) |
| TC-OBS-002 | PASS | Facility 1.5초 지연: 168→1,902ms, Zipkin trace, 원복 뒤 확정 | 세부 결과 (증거 경로: `./TC-OBS-002/verdict.md`) |
| TC-OBS-003 | PASS | 100 VU·60초 5,517건·실패 0, 참가 100→확정 9/환불 91, DB 10/10 | 세부 결과 (증거 경로: `./TC-OBS-003/verdict.md`) |
| TC-OBS-004 | PASS | Notification DOWN 중 참가 5건 확정, Lag 0→5→0, 알림·재처리 중복 없음 | 세부 결과 (증거 경로: `./TC-OBS-004/verdict.md`) |

**판정 기준:** HTTP 202는 접수로만 취급했다. 각 PASS는 최종 요청 상태와 서비스별 DB, 포인트 원장, Outbox/Kafka 결과를 대조했다. 최초 9 PASS·2 BLOCKED 보고서 원본 (증거 경로: `./final-execution-report-before-retest.md`)과 케이스별 원본 증거를 보존한 채, 새 fixture의 재시험 증거로 2종만 갱신했다. 이전 v0.5 실행 결과는 이번 판정에 재사용하지 않았다.

### 2. HTTP·DB·Kafka·포인트 대조

- 정상 생성·참가의 요청은 HTTP 202/PENDING에서 최종 CONFIRMED로 전이했고 요청별 `DEPOSIT_CHARGED` -10은 1건이다. 거절 경로는 접수 전 400/403과 접수 후 FAILED를 구분했다.
- 탈퇴 CLEANED는 소유 매치를 CANCELLED로 바꾸고 탈퇴자의 참가·대기를 정리했다. 다른 회원의 확정 이력은 남았고 보증금 +10 반환은 1건; 탈퇴자의 보증금은 반환되지 않았다.
- 경쟁 부하에서는 정원 10에 방장 포함 확정 10명, 신규 9명, 거절·환불 91명이다. `fixture.py verify`에서 100개 요청·참가·Outbox·포인트 이력을 대조했다.
- 알림 장애 중 Match 확정은 진행됐고, 복구 뒤 수신자별 알림 10건 및 Kafka Lag 0을 확인했다. 같은 `match.joined.v1` eventId 재전달 후에도 중복이 없었다.
- 출석 정산 13개 Outbox의 outcome은 ATTENDED 11, NO_SHOW 1, UNDER_MIN_PARTICIPANTS 1이다. 포인트 원장은 차감 13, 반환 12, 출석 보상 2, 노쇼 몰수 1이다. 동일·새 eventId 재전달 뒤 특정 요청의 포인트·카운터·이력은 불변이다.
- TC-POINT-003 추가 재시험에서 차감 전 취소는 요청/참가 CANCELLED, 잔액 50, 0점 취소 원장 1건이다. 별도 5분 만료는 늦은 CHARGED 후 -10/+10 각 1건, 잔액 50, 환불 COMPLETED, 재확정 0건이며 재전달 뒤 불변이다.
- TC-SAGA-003 추가 재시험에서 A/C/D의 Match 결과 Outbox는 기한 전 커밋되고 발행은 기한 뒤까지 지연됐다. 내부 조회로 CLEANED·REJECTED를 확정한 뒤 늦은 Kafka 결과와 재전달이 도착해도 회원·Saga·매치·포인트·알림은 변하지 않았다. B는 Match 결과 NONE에서 TIMED_OUT/ACTIVE가 되고 늦은 원 요청은 DEADLINE_EXCEEDED로 거절됐다.

### 3. 실제 관리자 화면과 모니터링 원본

각 TC의 `dashboard/`에는 **실제 React 관리자 대시보드**의 서비스 개요, Feign·CB, Kafka, JVM·리소스, 도메인·AI 탭을 각 단계별 전체 화면 PNG로 저장했다. 화면은 전용 시험 Prometheus와 관리자 API를 사용했다. AI 서비스는 본 시험 의존성이 아니어서 의도적으로 기동하지 않았고 화면의 DOWN 표시는 결함으로 집계하지 않았다. 차감·환불의 회계 판정은 화면의 누적 Counter가 아니라 DB 원장을 기준으로 했다.

| 케이스 | 실제 화면 단계 | 대표 화면 |
| --- | --- | --- |
| SAGA-001 | 전·후, 10장 | 탈퇴 후 Saga/도메인 (증거 경로: `./TC-SAGA-001/dashboard/after-domain.png`) |
| SAGA-002 | 전·후, 10장 | 거절 후 Saga/도메인 (증거 경로: `./TC-SAGA-002/dashboard/after-domain.png`) |
| SAGA-003 | 기존 장애 실험 20장 + A/C/D·B 재시험 8단계 및 모니터링 복구 45장 | A/C/D 재조회 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/acd-after-recheck-domain.png`), B 타임아웃 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/b-timed-out-domain.png`), Lag 복구 후 Kafka (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/monitoring-restored-kafka.png`) |
| POINT-001 | 전·후, 10장 | 확정 후 Kafka (증거 경로: `./TC-POINT-001/dashboard/after-kafka.png`) |
| POINT-002 | 전·후, 10장 | 거절 후 도메인 (증거 경로: `./TC-POINT-002/dashboard/after-domain.png`) |
| POINT-003 | 기존 전·취소·성별 불일치 15장 + 만료 전·늦은 CHARGED 후·모니터링 복구 15장 | 만료 전 도메인 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/pending-before-timeout-domain.png`), 늦은 CHARGED 후 도메인 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/after-timeout-late-domain.png`), Lag 복구 후 Kafka (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/monitoring-restored-kafka.png`) |
| POINT-004 | 전·진행 중·후, 15장 | 정산 후 도메인 (증거 경로: `./TC-POINT-004/dashboard/after-domain.png`) |
| OBS-001 | 전·장애 중·복구 후, 15장 | Facility 장애 중 Feign·CB (증거 경로: `./TC-OBS-001/dashboard/during-feign.png`) |
| OBS-002 | 전·후, 10장 | 지연 후 Feign·CB (증거 경로: `./TC-OBS-002/dashboard/after-feign.png`) |
| OBS-003 | 전·조회 부하 중·참가 중·후·필터, 26장 | 조회 부하 중 서비스 개요 (증거 경로: `./TC-OBS-003/dashboard/during-list-overview.png`) |
| OBS-004 | 전·장애 중·복구 후, 15장 | Notification 장애 중 Kafka (증거 경로: `./TC-OBS-004/dashboard/during-kafka.png`) |

TC-OBS-003은 k6 조회 부하 시간 **22:56:35~22:57:38 KST**를 Prometheus 원본 시계열 (증거 경로: `./TC-OBS-003/prometheus-range.json`)과 Grafana 패널에 같은 범위로 적용했다. 실제 Grafana 캡처: 서비스 개요 (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-service-overview.png`), 서비스 통신 (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-service-communication.png`), Kafka (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-kafka.png`), JVM (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-jvm-resources.png`), 도메인·AI (증거 경로: `./TC-OBS-003/grafana/after-top-sporty-domain-ai.png`). React의 현재 기간 화면은 부하 중 실시간 캡처이고, Grafana·Prometheus는 부하 시간으로 고정한 과거 범위다. 집계 시간·단위 차이는 동일 수치의 직접 등치로 해석하지 않았다. k6 P95 415.45ms는 측정값이며 사전 합의 성능 기준은 없다.

React의 기간 1시간·user-service 필터 화면 (증거 경로: `./TC-OBS-003/dashboard/filters-user-service-1h.png`)도 실제 UI에서 선택하고 재조회해 저장했다. 선택된 서비스 행 강조, 요청량·P95·CPU/Heap의 해당 서비스 표시를 확인했다.

재시험의 실제 React 캡처는 SAGA-003 45장 (증거 경로: `./retest-blocked-20261103/TC-SAGA-003/dashboard/`)과 POINT-003 15장 (증거 경로: `./retest-blocked-20261103/TC-POINT-003/dashboard/`)이다. SAGA-003은 결과 발행 전·재조회 직후·늦은 발행 후 및 B의 Consumer 중단·타임아웃·복구 화면을 각 5개 탭에서 저장했다. 메모리 확보를 위해 시험 중 Kafka exporter가 중단돼 일부 실시간 화면의 Lag는 DOWN이었으며, 복구 후 각 케이스의 Kafka 탭을 추가로 캡처했다. Prometheus 원본 (증거 경로: `./retest-blocked-20261103/monitoring-restored-prometheus.json`)은 exporter UP·Lag 합계 0을 확인한다. 포인트·Saga의 정확한 건수와 최종 판정은 DB/원장/Prometheus 원본을 기준으로 했다.

### 4. 결함·위험·잔여 검증

| 등급 | 항목 | 상태 |
| --- | --- | --- |
| 시험 방식 한계 | TC-SAGA-003 D의 409·500·식별값 불일치는 User 내부 조회 전용 프록시로 격리 주입했다. 실제 Match 정리 트랜잭션 경합 자체에서 나온 409는 직접 재현하지 않았다. 실제 Match 연결 실패는 최초 실행에서 확인했다. | 기록 |
| 선택 검증 | TC-POINT-003의 유효하지 않은 Kafka 이벤트 DLT 실험은 선택 항목으로 수행하지 않았다. | 기록 |
| 관측 한계 | AI 서비스는 시험 범위 밖이다. React/Grafana는 지원되는 현재 지표를 표시하지만 포인트 원장의 정확 건수는 DB로만 판정한다. | 기록 |

11개 필수 케이스에서 재현 가능한 신규 결함은 확인되지 않았다. **Issue #15는 이 실행 범위의 P0 검증 조건을 충족해 종료 가능**으로 판단한다. 실제 Issue 상태 변경과 PR 생성·병합은 수행하지 않았다.

### 5. 안전·복구

시험 전 개발 Compose는 미기동이었고, 기존 사용자 데이터와 볼륨을 삭제하지 않았다. 최초 실행의 가용 물리 메모리는 약 1.7 GiB 이상이었다. 보완 재시험에서도 관측한 최저 약 0.7 GiB로 0.3~0.4 GiB 중단선에 닿지 않았다. A/C/D의 Outbox 행 잠금은 해제했고, B의 Match 탈퇴 Consumer·User의 내부 조회 URL·MariaDB `innodb_lock_wait_timeout=50`을 기본값으로 복구했다. 시험용 HTTP 프록시와 Frontend 서버는 종료했다. Facility·Notification·Match·User 등 핵심 컨테이너와 Kafka exporter의 복구 직후 상태를 기록 (증거 경로: `./retest-blocked-20261103/environment-restored-before-stop.json`)했다. 검증 완료 후 전용 테스트 Compose만 중지했으며 컨테이너 17개와 전용 볼륨 2개는 보존했다. 중지 뒤 가용 메모리는 **약 3.61 GiB**, 실행 중인 Docker 컨테이너는 0이다(중지 후 상태 (증거 경로: `./retest-blocked-20261103/environment-after-stop.json`)). 이전 v0.5 원본과 최초 v0.6 보고서·증거는 보존했다.
