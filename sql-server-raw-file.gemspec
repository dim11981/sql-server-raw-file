require 'rubygems'

require "#{File.dirname(__FILE__)}/lib/sql_server_dts_ns"

Gem::Specification.new do |s|
  s.name        = 'sql-server-raw-file'
  s.version     = SqlServerDts::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'sql-server-raw-file lib'
  s.description = 'Converts SQL Server Integration Services Raw File source to hash.'
  s.authors     = ['Dmitriy Mullo']
  s.email       = ['d.a.mullo1981@gmail.com']
  s.homepage    = 'https://github.com/dim11981/sql-server-raw-file'
  s.platform = Gem::Platform::RUBY
  s.files       = Dir['*.md']+Dir['sql-server-raw-file.*']+Dir['lib/*.rb']+Dir['test/*.rb']+Dir['fixtures/*']
  s.require_path = 'lib'
end
