# sql-server-raw-file: sql-server-raw-file lib

Converts SQL Server Dts Raw File source to hash.

### Installation and usage

```
1) gem install sql-server-raw-file
2) usage (examples):

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

### Troubleshooting

mailto:d.a.mullo1981@gmail.com
subject: sql-server-raw-file issue