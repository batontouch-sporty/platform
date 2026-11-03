# Sporty v2 프로젝트 수행계획서 v1.0

> **확정 원본:** [Sporty_v2_프로젝트_수행계획서.pdf](Sporty_v2_프로젝트_수행계획서.pdf) · 이상혁 · 2026-11-02. GitHub 탐색용 요약이며 일정·담당·목표의 정확한 표현은 PDF를 우선합니다. 계획은 구현 완료 증빙이 아닙니다.

## 목표와 구성

1차의 시설·매칭·AI·회원 기능을 유지하면서 user, match, facility, ai, notification의 **5개 비즈니스 서비스**로 분리합니다. Gateway(8000), Eureka(8761), Config Server(8888)를 공통으로 사용하고 OpenFeign 조회, Kafka 이벤트·Outbox, MariaDB 서비스별 DB, Redis, React를 연결합니다. Micrometer·Prometheus·Grafana·Zipkin으로 장애와 부하 시 변화를 검증하고 Compose 및 AWS Kubernetes 배포를 목표로 합니다.

| 서비스 | 포트 | 책임 | DB |
| --- | ---: | --- | --- |
| user-service | 8081 | 인증·프로필·탈퇴 Saga·관리자 통계 | user_db |
| match-service | 8082 | 매치 CRUD·상태·참가·대기열·탈퇴 정리·통계 | match_db |
| facility-service | 8083 | 공공 시설 조회·동기화·내부 조회 | facility_db |
| ai-service | 8084 | 자연어 검색·초안·추천과 실패 대체 | 없음 |
| notification-service | 8085 | Kafka 알림 저장·조회·읽음 | notification_db |

MariaDB 서버 한 대에서 DB 4개를 논리적으로 분리하고 각 앱 계정은 자기 DB만 사용합니다. 다른 서비스 정보는 API·이벤트로 확인합니다.

## 담당

| 팀원 | 역할·담당 |
| --- | --- |
| 이상혁 | 팀장, 계약·Gateway·JWT·Config·Bus·설정 암호화·발표 |
| 안지산 | 부팀장, QA·문서·테스트 케이스·관리자 모니터링 화면 연동 |
| 최환우 | 부팀장, 매칭 B·참가/취소·대기열·Feign/CB·알림 발행 |
| 손호성 | 매칭 A·ERD/테이블·CRUD·상태 전이·관리자 통계 |
| 진성민 | 회원·인증·탈퇴 Saga(user)·알림 서비스 |
| 박선아 | 시설·AI·공공데이터·AI 지표 |
| 서우영 | Prometheus·Grafana·Alertmanager·장애/k6·포인트 |
| 나유성 | Compose·Kafka 환경·Kubernetes·AWS |

## 일정

| 날 | 계획 |
| --- | --- |
| 10/30 Day 1 | 요구사항·서비스 경계·ERD·API/이벤트 계약, 저장소·CI·MSA 골격 |
| 11/02 Day 2 | 도메인 이관, 당시 R8 DDL·DB 계정, Feign/CB, Kafka Outbox·Saga, 모니터링·추적 |
| 11/03 Day 3 | Config 중앙화·상태 전이·통계, 코드 마감 및 K8s/AWS 진행 판단 |
| 11/04 Day 4 | Compose 통합, 장애 4종·k6·Saga 보상, 배포·관리자 화면, 18:00 기능 동결 |
| 11/05 Day 5 | 09:00 산출물 제출, 리허설, 10분 시연·발표 |

계획서의 Day 2 `R8 DDL` 표기는 **11월 2일 작성 당시 일정 기록**입니다. DB의 최신 확정 기준은 이후의 [R10 테이블 명세](../data/table-spec-r10.md)와 백엔드 R10 DDL입니다. R8 SQL을 신규 환경에 적용하라는 현재 지침으로 읽지 않습니다.

## 연동·검증 목표

| 분야 | 계획 |
| --- | --- |
| 동기 | match → user·facility, ai → match·user·facility; Feign/Resilience4j CB·Fallback |
| 비동기 | 탈퇴 Saga 요청/정리·거절, joined·status-changed·starting-soon·waitlist-promoted 알림; Outbox, eventId 중복 방지·DLT |
| 모니터링 | Grafana 5종, 장애 4종, k6 전후 지표 분석, Alertmanager 경보 |
| 탈퇴 Saga | 성공·거절·5분 시간 초과 복구와 마감 검사 |
| 선택 목표 | Bus, 설정 암호화, K8s, AWS EC2 4대, CB, Zipkin, k6, 관리자 대시보드, Discord 알림, Saga |

배포 범위는 local IDE, dev 전체 Compose, prod EC2 4대(kubeadm master 1·worker 2·infra 1)입니다. 이미지 전달은 Docker Hub, 외부 접근은 NodePort를 계획합니다. K8s가 지연되면 infra EC2의 Compose 배포로 전환하는 계획도 PDF에 명시돼 있습니다. 이는 **계획된 토폴로지**로, 실제 배포 여부·성능·장애 검증 결과는 별도 결과 보고서가 필요합니다.

협업은 backend/frontend/config-repo의 PR·CI·CodeRabbit 확인, 계약 합의, 결정 로그를 따릅니다. 11월 4일 18:00 이후에는 버그 수정만 합니다.
