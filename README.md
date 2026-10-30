# Sporty v2 Platform

LG CNS AM Inspire Camp 6기 미니프로젝트 2, 2조 바통터치의 공통 설계·계약·검증 문서 저장소입니다. 개발 기간은 2026-10-30부터 2026-11-05까지 5일입니다. 코드는 [backend](https://github.com/batontouch-sporty/backend), [frontend](https://github.com/batontouch-sporty/frontend), [config-repo](https://github.com/batontouch-sporty/config-repo)에서 관리합니다.

Sporty는 서울시 공공체육시설을 찾고 운동 매치를 개설·참여하며 AI로 자연어 검색·추천을 받는 서비스입니다. 이번에는 기존 기능을 MSA로 이관하면서 **Kafka 알림, 통합 모니터링, 회원 탈퇴 Saga**를 고도화합니다.

## 문서 읽는 순서

1. [최신 범위와 v0.1 차이](docs/decisions/2026-10-30-scope-update.md) — 팀에서 이후 확정한 5개 서비스·세 가지 고도화 범위
2. [수행계획서 v0.1](docs/planning/project-plan-v0.1.md) · [요구사항 v0.1](docs/requirements/requirements-v0.1.md) — 원본 Word 변환
3. [API·Kafka 계약 v0.1](docs/contracts/api-contract-v0.1.md) · [테이블 명세 v0.1](docs/data/table-spec-v0.1.md) — 원본 Excel 시트를 각 문서의 장으로 변환
4. [테스트 케이스 v0.1](docs/testing/test-cases-v0.1.md) — 원본 Excel 시트 변환, 전체 `Not Run`

## 상태와 변경 규칙

첨부 산출물은 **팀 합의 전 v0.1 초안**입니다. 변환 과정에서 원문 ID(`USR`, `EM`, `MSA`, `API`, `EVT`, `TC`, `D`)와 값, 시트 구성을 유지했습니다. `v0.1`의 4개 서비스, AI projection 이벤트, 단순 회원 탈퇴 흐름은 최신 범위와 다릅니다. 이 문서의 계획·예시는 구현 완료나 실행 성공의 증거가 아닙니다.

팀 합의 후 API·이벤트·DB 소유권과 TC를 함께 갱신하고, 각 변경의 근거와 실행 증빙을 남깁니다. 예약·결제 기능은 범위에 포함하지 않으며 공공 예약 URL을 안내합니다.
