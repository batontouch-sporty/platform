# Sporty v2 Platform

LG CNS AM Inspire Camp 6기 미니프로젝트 2, **2조 바통터치**의 최종 설계·계약·검증 문서 저장소입니다.

Sporty는 서울시 체육시설을 탐색하고 운동 모임을 생성·참가하며 AI 검색·초안·추천을 제공하는 생활체육 플랫폼입니다. 5개 비즈니스 서비스로 분리하고 Kafka 알림, 통합 모니터링, 회원 탈퇴 Saga와 포인트 처리를 연결합니다.

## 최종 문서

| 종류 | 기준 문서 | 원본·증빙 |
| --- | --- | --- |
| 프로젝트 수행계획서 | [v1.0 요약](docs/planning/project-plan-v1.0.md) | [PDF](docs/planning/Sporty_v2_프로젝트_수행계획서.pdf) |
| 요구사항 명세서 | [v1.0 요약과 후속 결정](docs/requirements/requirements-v1.0.md) | [PDF](docs/requirements/Sporty_v2_요구사항_명세서.pdf) |
| API 명세서 | [2026-11-03 v0.5](docs/contracts/api-spec-2026-11-03-v0.5.md) | 외부 35·내부 5개 경로. 상세 필드·오류는 문서에 연결된 확정 노션 계약 우선 |
| 테이블 명세서 | [R10 전체 명세](docs/data/table-spec-r10.md) | [Excel](docs/data/Sporty_R10_테이블명세서.xlsx) · 4개 DB·16개 테이블·130개 컬럼 |
| 테스트 케이스 | [v1.1 안내·결과 요약](docs/testing/README.md) | [PDF](docs/testing/Sporty_v2_테스트_케이스.pdf) · [Excel](docs/testing/Sporty_v2_테스트_케이스.xlsx) · 2026-11-04, 243개 |
| 인프라 구성 | [인프라 구성 개요](docs/architecture/infra-overview.md) | [구성 이미지](docs/assets/architecture-msa-v1.png) |
| 탈퇴 Saga 후속 결정 | [마감 시 결과 재조회](docs/decisions/2026-11-03-withdrawal-result-reconciliation.md) | backend PR #144 · config-repo PR #18 |
| 최종 실행·모니터링 보고서 | [R10 v0.6 최종 실행 결과](docs/testing/r10-v06-execution-report.md) | 원 11종 PASS 11, BLOCKED 재시험 완료 2026-11-04 |

## 기준과 사용 원칙

- 각 종류의 최종 기준 문서와 원본을 유지합니다. 중복·초안·이전 버전은 삭제했으며 Git 커밋 이력에서 복원할 수 있습니다.
- PDF·Excel 원본과 요약을 함께 제공하는 경우 원본의 세부 항목을 우선합니다. 후속 승인 결정은 변경 전 원본 문구보다 우선합니다.
- 탈퇴 시간 초과 시 I5 결과를 재조회합니다. CLEANED는 WITHDRAWN, REJECTED는 ACTIVE, NONE은 TIMED_OUT/ACTIVE, 조회 실패는 WITHDRAWING 유지·재시도입니다. R10 DDL과 이벤트 형식은 변경되지 않았습니다.
- 테스트 케이스 원본의 기록은 **P 87 / F 0 / B 6 / 미실행 150**입니다. 제공된 재시험 결과를 반영했으며 이번 문서 작업에서 테스트를 재실행하지 않았습니다.
- 과거 실행 보고서는 최신 케이스 전체가 통과했다는 증거로 사용하지 않습니다. 실제 완료는 해당 커밋·환경의 코드·CI·통합 실행 증빙으로 판정합니다.
- DB 설치·변경 SQL은 [backend의 R10 DDL](https://github.com/batontouch-sporty/backend/tree/main/docker/mariadb/r10)을 사용합니다. 이 저장소에 이전 R7/R8 SQL 사본을 유지하지 않습니다.

## 코드 저장소

[Backend](https://github.com/batontouch-sporty/backend) · [Frontend](https://github.com/batontouch-sporty/frontend) · [Config](https://github.com/batontouch-sporty/config-repo)
