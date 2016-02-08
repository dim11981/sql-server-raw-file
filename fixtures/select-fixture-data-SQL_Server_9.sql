select cast(1 as int) [int]
, cast(3.14159265 as float) [float]
, cast(1 as bit) [bit]
, cast(POWER(2,30) as bigint) [bigint]
, cast('This is a variable length char string' as varchar(128)) [varchar]
, cast('This is a char string' as char(128)) [char]
, cast('��� ������ ���������� ����� � �������' as nvarchar(128)) [nvarchar]
, cast('��� ������ � �������' as nchar(128)) [nchar]
, cast(9.11 as decimal(18,6)) [decimal]
, cast(7.62 as numeric(18,6)) [numeric]
, getdate() [datetime]
, NULL [datetime2]
, NULL AS [NULL]
, cast(0x30313233343536373839 AS VARBINARY(10)) [varbinary]
, cast(0x40414243 AS BINARY(10)) [binary]
, @@DBTS [timestamp]
, CAST($123.45 AS MONEY) [money]
, CAST($2.23 AS SMALLMONEY) [smallmoney]
, NULL [date]
, NULL [time]
, CAST(GETDATE() AS SMALLDATETIME) [smalldatetime]
, NULL [datetimeoffset]
, CAST('6F9619FF-8B86-D011-B42D-00C04FC964FF' AS UNIQUEIDENTIFIER) [uniqueidentifier]
, CAST(30000 AS SMALLINT) [smallint]
, CAST(POWER(2.015,30) AS REAL) [real]
, CAST(200 AS TINYINT) [tinyint]
UNION ALL
select cast(2 as int) [int]
, cast(-37.0/3.0 as float) [float]
, cast(0 as bit) [bit]
, cast(-POWER(3,19) as bigint) [bigint]
, cast('This is another variable length char string' as varchar(128)) [varchar]
, cast('This is another char string' as char(128)) [char]
, cast('��� ��� ���� ������ ���������� ����� � �������' as nvarchar(128)) [nvarchar]
, cast('��� ��� ���� ������ � �������' as nchar(128)) [nchar]
, cast(-99.999 as decimal(18,6)) [decimal]
, cast(-5.56 as numeric(18,6)) [numeric]
, getdate() [datetime]
, NULL [datetime2]
, NULL AS [NULL]
, cast(0x39383736353433323130 AS VARBINARY(10)) [varbinary]
, cast(0x43424140 AS BINARY(10)) [binary]
, @@DBTS [timestamp]
, CAST($-123.45 AS MONEY) [money]
, CAST($-2.23 AS SMALLMONEY) [smallmoney]
, NULL [date]
, NULL [time]
, CAST(GETDATE() AS SMALLDATETIME) [smalldatetime]
, NULL [datetimeoffset]
, CAST('FFEFAA09-8B86-D011-B42D-00C04FC964FF' AS UNIQUEIDENTIFIER) [uniqueidentifier]
, CAST(-30000 AS SMALLINT) [smallint]
, CAST(-POWER(3.019,18) AS REAL) [real]
, CAST(10 AS TINYINT) [tinyint]
