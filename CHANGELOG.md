## 0.1.3 (Jun 3, 2016)

Features:

- add Fixture module
- add fixture data directory
- add SQL Server 12 raw file support

Bugfixes:

- check test_sql_data_and_header.rb


## 0.1.2 (Jan 25, 2016)

Features:

- add SqlServerDts::RawFile#get_len

* get length of data by data or metadata

- add support of data types

* smallint
* real (float(24))
* money (decimal(19,4)), smallmoney ((decimal(10,4)))
* tinyint
* uniqueidentifier
* varbinary, binary, timestamp
* date
* smalldatetime
* time
* datetimeoffset

Bugfixes:

- fixed mappings for:

* int
* float
* bigint
* datetime
* datetime2


## 0.1.1 (Jan 20, 2016)

Features:

- add SqlServerDts::RawFile#eof?

* check io-stream eof

- add SqlServerDts::RawFile#pos

* get current position in inner io-stream object

Bugfixes:

- missing method SqlServerDts::RawFile#close

* is need to close inner io-stream object in some cases


## 0.0.1 (Jan 5, 2016)

Features:

- add support of SQL Server Dts Raw File versions:

* 00.90.00.00 => 9 (SQL Server: 9,10)
* 00.10.01.00 => 10 (SQL Server: 11)

- add support of basic data types:

* int (i.e. NULL w/o cast)
* float
* bit
* bigint
* (n)(var)char
* decimal, numeric
* datetime
* datetime2 (only SQL Server 10/11)

Bugfixes:

- initial release
