# encoding: utf-8

require 'csv'
require 'json'

require(File.expand_path('../../lib/sql_server_raw_file.rb',__FILE__))

# Fixture module
# test fixture
module Fixture
  def self.show
    data_path = File.expand_path('../../data',__FILE__)+'/'
    raw_file_name = %w(sql09.raw sql10.raw sql11.raw sql12_1.raw sql12_2.raw)

    # current_fixture_index = 0
    current_fixture_index = File.read(data_path+'/current_sql_index').to_i
    raw_path = data_path+raw_file_name[current_fixture_index]

    # show version of raw file
    # signature: new(io)
    # @param io [IO] IO-stream
    # @return [SqlServerDts::RawFile]
    File.open(raw_path) { |raw_io|
      raw_obj = SqlServerDts::RawFile.new(raw_io)
      puts "RAW VERSION: #{raw_obj.version}"
    }

    # show header of raw file and convert it into hash and save it as json-file
    # signature: new(path)
    # @param path [String] Path to raw file
    # @return [SqlServerDts::RawFile]
    raw_obj = SqlServerDts::RawFile.new(raw_path)
    puts '=== BEGIN HEADER ==='
    puts raw_obj.header
    File.open("#{data_path+File.basename(raw_path, '.*')}_header.json",'wt') { |json_io|
      header_json = JSON.pretty_generate(raw_obj.header)
      json_io.write(header_json)
    }
    puts '=== END HEADER ==='
    # get current position into inner IO-stream object for further using
    init_pos = raw_obj.pos
    # need to close inner IO-stream object
    raw_obj.close
    #exit
    # show data of raw file in rows table and convert it into hash and save it as csv-file
    # signature: new(path,init_pos)
    # @param path [String] Path to raw file
    # @param init_pos [String] Init pos in raw file where data rows from
    # @return [ [SqlServerDts::RawFile,IO] ] block_given? == true
    SqlServerDts::RawFile.new(raw_path,init_pos) { |raw_obj, raw_io|
      puts '=== BEGIN DATA ==='
      i=0
      fields_arr = []
      raw_obj.header.each { |field_info| fields_arr << field_info[:name] }
      puts fields_arr.join("\t")
      CSV.open("#{data_path+File.basename(raw_io.path, '.*')}_data.csv", 'wb', {headers: fields_arr, write_headers: true, col_sep: "\t"}) { |csv|
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
  end
end
