select cast(1 as int) [int], cast(3.14159265 as float) [float], cast(1 as bit) [bit], cast(POWER(2,30) as bigint) [bigint], cast('This is a variable length char string' as varchar(128)) [varchar], cast('This is a char string' as char(128)) [char], cast('��� ������ ���������� ����� � �������' as nvarchar(128)) [nvarchar], cast('��� ������ � �������' as nchar(128)) [nchar], cast(9.11 as decimal(18,6)) [decimal], cast(7.62 as numeric(18,6)) [numeric], getdate() [datetime], NULL [datetime2], NULL AS [NULL]
UNION ALL
select cast(2 as int) [int], cast(-37.0/3.0 as float) [float], cast(0 as bit) [bit], cast(-POWER(3,19) as bigint) [bigint], cast('This is another variable length char string' as varchar(128)) [varchar], cast('This is another char string' as char(128)) [char], cast('��� ��� ���� ������ ���������� ����� � �������' as nvarchar(128)) [nvarchar], cast('��� ��� ���� ������ � �������' as nchar(128)) [nchar], cast(-99.999 as decimal(18,6)) [decimal], cast(-5.56 as numeric(18,6)) [numeric], getdate() [datetime], NULL [datetime2], NULL AS [NULL]