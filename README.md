# Sporty v2 Platform

LG CNS AM Inspire Camp 6기 미니프로젝트 2, 2조 바통터치의 공통 설계·계약·검증 문서 저장소입니다. 개발 기간은 2026-10-30부터 2026-11-05까지 5일입니다. 코드는 [backend](https://github.com/batontouch-sporty/backend), [frontend](https://github.com/batontouch-sporty/frontend), [config-repo](https://github.com/batontouch-sporty/config-repo)에서 관리합니다.

Sporty는 서울시 공공체육시설을 찾고 운동 매치를 개설·참여하며 AI로 자연어 검색·추천을 받는 서비스입니다. 이번에는 기존 기능을 MSA로 이관하면서 **Kafka 알림, 통합 모니터링, 회원 탈퇴 Saga**를 고도화합니다.

## 문서 읽는 순서

1. [확정 API 계약 v1.0](docs/contracts/api-spec-v1.0.md) — 외부 31개·내부 4개 경로, Gateway 인증, 관리자 통계·Prometheus 조회. 상세 JSON과 오류는 팀 확정 PDF 원본 부록 참조
2. [최신 범위와 v0.1 차이](docs/decisions/2026-10-30-scope-update.md) — 확정 API와 구분되는 Kafka·DB·검증 작업
3. [수행계획서 v0.1](docs/planning/project-plan-v0.1.md) · [요구사항 v0.1](docs/requirements/requirements-v0.1.md) — 원본 Word 변환
4. [서비스별 DB 설계 R8](docs/data/schema-r8.md) · [R8 신규 설치 SQL](docs/data/02_Sporty_v2_A_R8_DDL.sql) · [R7→R8 변경 SQL](docs/data/03_Sporty_v2_R7_to_R8.sql) · [적용 결과 확인 SQL](docs/data/04_Sporty_v2_R8_verify.sql) — 현재 스키마·적용 대상·검사 항목
5. [R7 설계](docs/data/schema-r7.md) · [R7 DDL](docs/data/01_Sporty_v2_A_R7_DDL.sql) · [R4 대조](docs/data/schema-r4-review.md) — 이전 스키마와 변경 이력
6. [API·Kafka 계약 v0.1](docs/contracts/api-contract-v0.1.md) · [테이블 명세 v0.1](docs/data/table-spec-v0.1.md) — 원본 Excel 시트를 각 문서의 장으로 변환한 역사적 초안
7. [테스트 케이스 v0.1](docs/testing/test-cases-v0.1.md) — 원본 Excel 시트 변환, 전체 `Not Run`

## 상태와 변경 규칙

**HTTP API는 팀 확정 `Sporty_v2 API 명세서 v1.0`(2026-10-30)이 기준입니다.** 저장소의 `api-spec-v1.0.md`는 그 내용을 탐색하기 쉽게 정리한 Markdown 요약입니다. 상세 요청·응답 JSON 및 API별 오류 코드는 원본 PDF 부록을 우선합니다.

DB 문서는 [R8 설계·적용 절차](docs/data/schema-r8.md)를 먼저 확인하세요. 새 MSA DB 설치와 R7→R8 변경은 서로 다른 SQL을 사용하며, 작성된 SQL만으로 실제 DB 적용이나 서비스 연동 성공을 증명할 수 없습니다. 백엔드 Compose의 빈 DB 초기화에는 [backend의 R8 스키마](https://github.com/batontouch-sporty/backend/blob/main/docker/mariadb/schema.sql)가 사용됩니다.

나머지 v0.1 산출물은 **팀 합의 전 초안**입니다. 변환 과정에서 원문 ID(`USR`, `EM`, `MSA`, `API`, `EVT`, `TC`, `D`)와 값, 시트 구성을 유지했습니다. `v0.1`의 4개 서비스, AI projection 이벤트, 단순 회원 탈퇴 흐름은 최신 API·범위와 다릅니다. 문서의 계획·예시는 구현 완료나 실행 성공의 증거가 아닙니다.

팀 합의 후 API·이벤트·DB 소유권과 TC를 함께 갱신하고, 각 변경의 근거와 실행 증빙을 남깁니다. 예약·결제 기능은 범위에 포함하지 않으며 공공 예약 URL을 안내합니다.
