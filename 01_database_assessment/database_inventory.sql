USE WideWorldImporters;
GO

-- 서버 기본 정보
SELECT SERVERPROPERTY('ServerName') AS ServerName,
       SERVERPROPERTY('ProductVersion') AS ProductVersion,
       SERVERPROPERTY('Edition') AS Edition;

-- 데이터베이스 상태 및 복구 모델
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name = 'WideWorldImporters';

-- 스키마 목록
SELECT schema_id, name
FROM sys.schemas;

-- 사용자 테이블 목록 및 개수
SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS TableName
FROM sys.tables
WHERE is_ms_shipped = 0;

SELECT COUNT(*) AS TableCount
FROM sys.tables
WHERE is_ms_shipped = 0;

-- 스키마별 테이블 개수
SELECT a.name AS SchemaName, COUNT(*) AS TableCount
FROM sys.schemas a
JOIN sys.tables b ON a.schema_id = b.schema_id
WHERE b.is_ms_shipped = 0
GROUP BY a.name
ORDER BY TableCount DESC;

-- 사용자 프로시저 목록 및 개수
SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS ProcedureName
FROM sys.procedures
WHERE is_ms_shipped = 0;

SELECT COUNT(*) AS ProcedureCount
FROM sys.procedures
WHERE is_ms_shipped = 0;

-- 사용자 뷰 목록 및 개수
SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS ViewName
FROM sys.views
WHERE is_ms_shipped = 0;

SELECT COUNT(*) AS ViewCount
FROM sys.views
WHERE is_ms_shipped = 0;

-- 디스크 기반 테이블별 근사 행 수 및 예약 공간
SELECT
    a.name AS SchemaName,
    b.name AS TableName,
    SUM(
        CASE
            WHEN c.index_id IN (0, 1) THEN c.row_count
            ELSE 0
        END
    ) AS TotalRows,
    CAST(
        SUM(c.reserved_page_count) * 8.0 / 1024
        AS DECIMAL(18, 2)
    ) AS ReservedMB
FROM sys.schemas a
JOIN sys.tables b
    ON a.schema_id = b.schema_id
JOIN sys.dm_db_partition_stats c
    ON b.object_id = c.object_id
WHERE b.is_ms_shipped = 0
  AND b.is_memory_optimized = 0
GROUP BY a.name, b.name
ORDER BY TotalRows DESC;
