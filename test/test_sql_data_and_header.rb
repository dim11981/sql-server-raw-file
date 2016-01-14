# coding: utf-8
require 'csv'
require 'json'

require "#{File.dirname(__FILE__)}/../lib/sql_server_raw_file"

fixtures_path = "#{File.dirname(__FILE__)}/../fixtures/"
raw_path = %w(sql09.raw sql10.raw sql11.raw)

# current_fixture_index = 0
current_fixture_index = File.read(fixtures_path+'/current_sql_index').to_i

# show header of raw file and convert it hash and put it json-file
File.open(fixtures_path+raw_path[current_fixture_index]) { |raw_io|
  raw_obj = SqlServerDts::RawFile.new(raw_io)
  puts "RAW VERSION: #{raw_obj.version}"
  puts '=== BEGIN HEADER ==='
  puts raw_obj.header
  File.open("#{fixtures_path+File.basename(raw_io.path, '.*')}_header.json",'wt') { |json_io|
    header_json = JSON.pretty_generate(raw_obj.header)
    json_io.write(header_json)
  }
  puts '=== END HEADER ==='
}

# show data of raw file in rows table and convert it hash and put it csv-file
SqlServerDts::RawFile.new(fixtures_path+raw_path[current_fixture_index]) { |raw_obj, raw_io|
  puts '=== BEGIN DATA ==='
  i=0
  fields_arr = []
  raw_obj.header.each { |field_info| fields_arr << field_info[:name] }
  puts fields_arr.join("\t")
  CSV.open("#{fixtures_path+File.basename(raw_io.path, '.*')}_data.csv", 'wb', {headers: fields_arr, write_headers: true, col_sep: "\t"}) { |csv|
    until raw_io.eof?
      values_arr = []
      raw_obj.read_line.each_value { |v| values_arr << v }
      csv << values_arr
      puts values_arr.join("\t")
      i+=1
    end
  }
  puts '=== END DATA ==='
  puts "total: #{i}"
}