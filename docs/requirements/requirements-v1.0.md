# Sporty v2 요구사항 명세서 v1.0

> **확정 원본:** [Sporty_v2_요구사항_명세서.pdf](Sporty_v2_요구사항_명세서.pdf) · 이상혁 · 2026-11-02. 이 문서는 GitHub 탐색용 요약입니다. 문구·우선순위·담당·완료 조건의 세부 사항은 원본 PDF를 우선합니다. 설계 확정과 구현·테스트 완료는 별개입니다.

> **2026-11-03 후속 변경:** 탈퇴 Saga 시간 초과 판정은 [PR #144 결정](../decisions/2026-11-03-withdrawal-result-reconciliation.md)과 [API v0.5](../contracts/api-spec-2026-11-03-v0.5.md)를 우선합니다. 아래 PDF의 5분 후 일괄 ACTIVE 복구와 늦은 CLEANED 경보 문장은 변경 전 기준입니다.

## 범위와 기준

| 구분 | 확정 내용 |
| --- | --- |
| 기능 | 51개. 회원·프로필, 매칭·대기열, 시설·AI, 알림·포인트, 관리자·화면 |
| 비기능 | MSA 공통 1~9, 핵심기술 10(모니터링), 선택 ①~⑩, 품질 NFR-01~07 |
| 우선순위 | P0: 11월 4일까지 필수; P1: P0 이후; P2: 여유 시 |
| 사용자 | 비회원, USER, 방장, ADMIN |
| ID | 1차 USR·PR·EM·FC·AI 유지, WL·NT·PT·AD·UI·NFR 추가 |

## 기능 요구사항

| 영역 | ID | 핵심 완료 기준과 우선순위 |
| --- | --- | --- |
| 회원·인증 | USR-01~08 | 가입 시 포인트 50점(포인트 기능은 P1); JWT의 USER/ADMIN 역할, Redis Refresh, 탈퇴 요청 202와 `ACTIVE → WITHDRAWING → WITHDRAWN` 또는 `ACTIVE` 복구, 외부 차단 내부 회원 조회. P0 |
| 프로필 | PR-01~02 | 내 프로필 수정, 다른 회원 공개 프로필 조회. P0 |
| 매치 | EM-01~09, EM-13 | 최소 정원 **방장 포함 2명**; 시설 Feign 확인과 스냅샷; 상태 전이·취소 이력; 참가 신청 PENDING(202) 및 확정/실패, 중복·정원 재확인; 탈퇴 시 매치 정리. P0. 보증금 단계는 포인트 제도와 함께 P1 |
| 매치 확장 | EM-10~12 | requestId로 생성·참가·차감·반환 연결, 출석·노쇼, 시작 하루 전 알림. P1 |
| 대기열 | WL-01~02 | 정원 초과 시 대기 등록·취소, 빈자리 FIFO 자동 승급·재검증. P1 |
| 시설 | FC-01~04 | 목록·상세, 03:00 서울시 공공 API 동기화, 내부 시설 조회. P0. 후보 조회 I4는 원본에서 P1로 표기 |
| 시설 확장 | FC-05 | 내 위치와 시설 거리. P2 |
| AI | AI-01~04 | 자연어 초안·검색·추천, LLM 장애 대체 응답과 호출 결과·응답시간 지표. P0 |
| 알림 | NT-01~03 | 참가·매치 상태·탈퇴 거절 알림과 내 알림함은 P0; 대기 승급·하루 전 알림은 P1 |
| 포인트 | PT-01~06 | 0~100점, 가입 50점, 보증금 10점 차감·반환, 출석 정산, 노쇼 정지·7일 해제, 내역, requestId 멱등·동시성. P1 |
| 관리자 | AD-01~04 | 매치·탈퇴 Saga 통계, ADMIN 전용 Prometheus 즉시/범위 조회, React 운영 대시보드. P0 |
| 화면 | UI-01~04 | Gateway 단일 호출·알림/탈퇴 상태·매치 취소/대기 버튼은 P0; 포인트 UI는 P1 |

매칭 API·상태 코드와 오류 코드는 [API 계약](../contracts/api-spec-v1.0.md) 및 최신 팀 계약을 함께 대조합니다. 이 요구사항 PDF는 `POST /api/matches`의 최소 정원 등 업무 수용 기준이며, PDF에 명시된 경로는 서비스 내부 경로여서 Gateway 경유 주소와 구분합니다.

## MSA·핵심기술

1. user·match·facility·ai·notification 5개 비즈니스 서비스와 책임 분리.
2. Eureka 등록, Gateway 단일 진입·JWT/ADMIN 검증, 클라이언트 `X-User-Id` 제거와 `/internal/**` 차단, Config Server 설정 중앙화.
3. OpenFeign 동기 조회, Kafka 이벤트(탈퇴·알림·포인트), 각 서비스 자기 DB만 접근, Docker Compose 통합 기동.
4. Actuator·Micrometer·Prometheus 전 서비스 수집, Grafana 5종(서비스·통신·Kafka·JVM·도메인/AI), Alertmanager → Discord 경보, 장애 4종 분석.

선택 목표 ① Bus ② 설정 암호화 ③ Kubernetes ④ AWS 실배포 ⑤ Circuit Breaker ⑥ Zipkin 분산 추적 ⑦ k6 부하 ⑧ 관리자 대시보드 ⑨ Discord 경보 ⑩ Saga. 원본 PDF는 각 항목의 담당·우선순위와 구체적 기준을 제시합니다.

## 품질·제약

| ID | 검증 기준 요약 |
| --- | --- |
| NFR-01~02 | 동시 100명 매치 조회·참가 p95/오류율 측정 및 경보; Feign CB/Fallback, 외부 AI·공공 API 장애 대체 |
| NFR-03 | 탈퇴 Saga Outbox·claim_token/requestEventId. **마감 5분+유예 30초 이후 Match 결과를 내부 조회:** CLEANED는 WITHDRAWN, REJECTED는 ACTIVE, NONE은 TIMED_OUT/ACTIVE, 조회 실패·불일치는 WITHDRAWING 유지·재확인. 이미 CLEANED 완료 후 같은 결과 이벤트는 정상 중복(late 경보 없음). 기존 3종과 결과 전달 지연·조회 실패를 분기별 검증 |
| NFR-04~05 | eventId 멱등, 재시도 3회·DLT; JWT·내부 API·DB 최소 권한·비밀 보호 |
| NFR-06~07 | 전 서비스 관측·추적, local/dev/prod 동일 코드와 Config 연결 실패 시 기동 차단 |

Java 17, Spring Boot 3.5, Spring Cloud 2025.0, Gradle·MariaDB를 사용합니다. 시설 예약은 외부 링크만 제공하며 허위 출석 검증은 범위 밖입니다. 기능 동결은 11월 4일 18:00, 산출물 제출은 11월 5일 09:00입니다.

**원본 우선 원칙:** 이 요약과 PDF가 다르면 PDF를 따르되, 위에 명시한 2026-11-03 탈퇴 Saga 후속 결정은 변경 전 PDF 문구보다 우선합니다. API·이벤트·DDL은 해당 확정 원본의 버전과 맞춰 검토하며, 실제 구현 상태는 코드·테스트 증빙으로 별도 판정합니다.
