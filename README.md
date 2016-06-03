# sql-server-raw-file: sql-server-raw-file lib

Converts SQL Server Integration Services raw file to hash objects.
Supports raw files generated from SQL Server 9, 10, 11, 12.

### Installation and usage

Install:

```
gem install sql-server-raw-file
```

Usage:

```ruby
# begin example 1
require 'sql_server_raw_file'

File.open('/path/to/sql/raw/file') { |raw_io|
  raw_obj = SqlServerDts::RawFile.new(raw_io)
  # ...
  puts raw_obj.version
  puts raw_obj.header
  # ...
  until raw_io.eof?
    # ...
    puts raw_obj.read_line
    # ...
  end
  # ...
}
# end example 1

# begin example 2
require 'sql_server_raw_file'

SqlServerDts::RawFile.new('/path/to/sql/raw/file') { |raw_obj, raw_io|
  # ...
  puts raw_obj.version
  puts raw_obj.header
  # ...
  until raw_io.eof?
    # ...
    puts raw_obj.read_line
    # ...
  end
  # ...
}
# end example 2
```

More detailed examples in ./fixtures/fixture_sql_data_and_header.rb

### Troubleshooting

Visit to [sql-server-raw-file homepage](https://github.com/dim11981/sql-server-raw-file)