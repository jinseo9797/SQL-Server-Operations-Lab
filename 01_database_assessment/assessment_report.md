# 데이터베이스 인수인계 및 현황 파악

## 목적

기존 WideWorldImporters 데이터베이스의 운영 환경과 객체 구조, 테이블 규모를 파악하기 위한 조회 쿼리를 작성했습니다.

## 조사 항목

| 항목 | 활용한 함수 및 시스템 뷰 |
|---|---|
| 서버 이름, 버전, 에디션 | `SERVERPROPERTY()` |
| 데이터베이스 상태 및 복구 모델 | `sys.databases` |
| 스키마 목록 | `sys.schemas` |
| 테이블 목록 및 개수 | `sys.tables` |
| 저장 프로시저 목록 및 개수 | `sys.procedures` |
| 뷰 목록 및 개수 | `sys.views` |
| 테이블별 행 수 및 예약 공간 | `sys.dm_db_partition_stats` |

## 진행 방식

### 객체 정보 조회

시스템 카탈로그 뷰를 활용하여 데이터베이스에 등록된 객체의 이름과 개수를 조회하도록 구성했습니다. 사용자 객체 조회 시 `is_ms_shipped = 0` 조건을 적용했습니다.

### 테이블 규모 및 저장 공간 조회

`sys.schemas`와 `sys.tables`는 `schema_id`를 기준으로 연결하고, `sys.tables`와 `sys.dm_db_partition_stats`는 `object_id`를 기준으로 연결했습니다.

- 데이터 건수: `index_id`가 0 또는 1인 파티션의 `row_count`만 합산하여 보조 인덱스로 인한 중복 집계를 방지했습니다.
- 예약 공간: 모든 인덱스의 `reserved_page_count`를 합산하고 페이지당 8KiB를 기준으로 MiB 단위로 변환했습니다.
- 별칭: SQL Server 예약어인 `ROWCOUNT`와의 충돌을 피하기 위해 `TotalRows`를 사용했습니다.

`WHERE` 절에서 인덱스 ID를 제한하면 보조 인덱스의 예약 공간까지 제외되므로, 행 수에만 `CASE WHEN` 조건을 적용했습니다.

## 참고 사항

행 수는 DMV에서 제공하는 근사치이며, 예약 공간은 실제 사용 공간과 구분됩니다. 테이블 규모 조회는 디스크 기반 테이블을 대상으로 하며 메모리 최적화 테이블은 제외했습니다.

시스템 뷰의 관계를 파악하고 JOIN 쿼리를 직접 작성했으며, 집계 및 용량 계산 구문은 AI의 설명과 도움을 받아 보완했습니다. 최종 쿼리의 실행 결과 및 측정 수치는 별도 검증 후 기록합니다.

## SQL 스크립트

[database_inventory.sql](./database_inventory.sql)
