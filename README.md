# Sporty v2 Platform

LG CNS AM Inspire Camp 6기 미니프로젝트 2, 2조 바통터치의 공통 설계·계약·검증 문서 저장소입니다. 개발 기간은 2026-10-30부터 2026-11-05까지 5일입니다. 코드는 [backend](https://github.com/batontouch-sporty/backend), [frontend](https://github.com/batontouch-sporty/frontend), [config-repo](https://github.com/batontouch-sporty/config-repo)에서 관리합니다.

Sporty는 서울시 공공체육시설을 찾고 운동 매치를 개설·참여하며 AI로 자연어 검색·추천을 받는 서비스입니다. 이번에는 기존 기능을 MSA로 이관하면서 **Kafka 알림, 통합 모니터링, 회원 탈퇴 Saga**를 고도화합니다.

## 문서 읽는 순서

1. [확정 요구사항 v1.0](docs/requirements/requirements-v1.0.md) ([PDF 원본](docs/requirements/Sporty_v2_요구사항_명세서.pdf)) · [확정 수행계획서 v1.0](docs/planning/project-plan-v1.0.md) ([PDF 원본](docs/planning/Sporty_v2_프로젝트_수행계획서.pdf)) — 2026-11-02 팀 기준. Markdown은 열람용 요약이며 세부 사항은 원본을 우선
2. [R10 테이블 명세](docs/data/table-spec-r10.md) ([Excel 원본](docs/data/Sporty_R10_테이블명세서.xlsx)) — 7개 시트 전체, 4개 DB·16개 테이블·130개 컬럼. 신규/기존 DB 적용 경로와 선택 제약은 별도
3. [2026-11-03 API v0.5 보완](docs/contracts/api-spec-2026-11-03-v0.5.md) — 외부 35·내부 5개 경로. PR #144의 탈퇴 결과 내부 조회 추가; 상세 필드·오류는 팀 노션과 PR 코드 대조. [v0.4](docs/contracts/api-spec-2026-11-03-v0.4.md)·[10/30 v1.0](docs/contracts/api-spec-v1.0.md)은 이력
4. [R10 통합 테스트 케이스 106개](docs/testing/test-cases-r10-consolidated.md) ([PDF](docs/testing/test-cases-r10-consolidated.pdf)) · [TC-SAGA-003 v0.6 재시험](docs/testing/k6-saga-chaos-test-cases-v0.6.md) — 과거 v0.5 보고서는 Pass 10·Fail 1, 새 Saga 재시험은 Not Run. 기존 PDF는 작성 당시 기대값의 이력
5. [탈퇴 Saga 마감 시 결과 재조회 결정](docs/decisions/2026-11-03-withdrawal-result-reconciliation.md) · [로컬 인프라 구성](docs/architecture/infra-overview.md) · [초기 범위 변경 이력](docs/decisions/2026-10-30-scope-update.md)
6. [R8 설계](docs/data/schema-r8.md) · [R8 SQL](docs/data/02_Sporty_v2_A_R8_DDL.sql) — 과거 버전 이력. R10 DB에 신규 설치·마이그레이션용으로 사용하지 않음
7. [요구사항 v0.1](docs/requirements/requirements-v0.1.md) · [수행계획 v0.1](docs/planning/project-plan-v0.1.md) · [테이블 v0.1](docs/data/table-spec-v0.1.md) · [테스트 케이스 v0.1](docs/testing/test-cases-v0.1.md) — 팀 합의 전 역사적 초안

## 상태와 변경 규칙

**확정 원본의 우선순위:** 요구사항·수행계획은 2026-11-02 v1.0 PDF, DB 테이블 명세는 R10 Excel입니다. Markdown은 GitHub 탐색용이며 원본의 모든 세부 항목을 대신하지 않습니다. 백엔드의 실제 R10 신규 설치 DDL·R9→R10 마이그레이션과 운영 DB 적용 결과는 별도로 확인합니다. 이 저장소의 R8 SQL은 변경 이력으로 유지합니다. 특히 R9 전용 변경 SQL을 R8 DB에 실행하지 마세요.

API·이벤트 계약의 필드, 상태 코드, 오류는 승인된 최신 원본/PR과 대조합니다. PR #144는 내부 조회 API·조회 실패 Counter를 추가했고 R10 DDL과 이벤트 형식은 바꾸지 않았습니다. 요구사항 PDF의 시간 초과 일괄 ACTIVE 복구와 과거 v0.5 FAIL은 최신 동작과 구분합니다. 특히 10/30 API v1.0의 매치 생성·참가 201과 정원 1명 설명은 최신 노션의 보증금 활성 R10 계약과 다릅니다. 수행계획서 Day 2의 `R8 DDL`은 작성 당시 일정이고 R10 결정 이후의 설치 기준이 아닙니다. 요구사항이나 계획의 항목을 구현·테스트 완료로 간주하지 않습니다. 실제 완료 상태는 각 서비스 코드, CI, 통합 테스트·배포 증빙을 확인해 기록합니다.

과거 v0.1과 R7/R8 자료는 설계 변경을 추적할 수 있도록 보관합니다. 시설의 실제 예약·결제는 범위 밖이며 공공 예약 URL을 안내합니다.
