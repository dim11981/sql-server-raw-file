# coding: utf-8
require "#{File.dirname(__FILE__)}/sql_server_dts_ns"

# SqlServerDts::RawFile class
class SqlServerDts::RawFile
  # Error class
  class Error < RuntimeError
  end

  # UnsupportedRawVersionError class
  class UnsupportedRawVersionError < Error
  end

  # UnknownDataTypeError class
  class UnknownDataTypeError < Error
  end

  # FieldsNotExistsError class
  class FieldsNotExistsError < Error
  end

  # default encoding of raw file: 'utf-16le'
  DEFAULT_RAW_FILE_ENCODING = 'utf-16le'

  # default encoding of module environment: 'utf-8'
  DEFAULT_ENCODING = 'utf-8'

  # supported versions of Raw File:
  #   00.90.00.00 => 9 (SQL Server: 9/10)
  #   00.10.01.00 => 10 (SQL Server: 11)
  SUPPORTED_RAW_VERSIONS = %w(00.10.01.00 00.90.00.00)

  # initialization
  #
  # @param io [String, IO] Path to raw file or io-stream
  # @param init_pos [Integer, nil] Initial position in raw file or nil
  # @return [SqlServerDts::RawFile, [SqlServerDts::RawFile,IO]] Within block it returns self and io-stream
  #   in other side returns self
  def initialize(io,init_pos=nil)
    if io.is_a?(IO)
      @raw_file = io
      @raw_file.binmode unless @raw_file.binmode?
      read_header
      @raw_file.seek(init_pos || @data_pos)
    else
      @raw_file = File.new(io,'rb')
      read_header
      @raw_file.seek(init_pos || @data_pos)
      if block_given?
        begin
          yield [self,@raw_file]
        ensure
          @raw_file.close
        end
      else
        self
      end
    end
  end

  # read metadata (header) raw file and fill inner array of metadata
  def read_header
    raise IOError, 'Stream is closed' if @raw_file.closed?
    begin
      @raw_file.rewind
      @version = @raw_file.read(4).unpack('H2H2H2H2').join('.')
      raise UnsupportedRawVersionError, "Version #{@version} unsupported " unless SUPPORTED_RAW_VERSIONS.include?(@version)
      @fields_info = []
      fields_count = @raw_file.read(4).unpack('I')[0]
      raise FieldsNotExistsError, 'Fields not exists (fields_count=0)' if fields_count==0
      @nil_mask_len = fields_count/8+(fields_count-fields_count/8*8>0?1:0)
      fields_count.times {
        name_len = @raw_file.read(4).unpack('I')[0]
        field_name = @raw_file.read(name_len*2).encode(DEFAULT_ENCODING,DEFAULT_RAW_FILE_ENCODING,{ invalid: :replace, undef: :replace })
        (@version == '00.10.01.00') ?
            values_arr = @raw_file.read(40).unpack('I4iI5') :
            values_arr = @raw_file.read(32).unpack('I4iI3')
        field_info = {
          name: field_name,
          data_type: values_arr[0],
          max_length: values_arr[1],
          p2: values_arr[2],
          p3: values_arr[3],
          p4: values_arr[4],
          precision: values_arr[5],
          scale: values_arr[6],
          code_page: values_arr[7],
          p8: values_arr[8],
          p9: values_arr[9]
        }
        @fields_info << field_info
      }
    rescue
      raise
    else
      @data_pos = @raw_file.pos
    end
  end

  # read line of raw data
  #
  # @return [Hash] Hash of converted raw data (one line)
  def read_line
    raise IOError, 'Stream is closed' if @raw_file.closed?
    begin
      nil_mask = @raw_file.read(@nil_mask_len).unpack('b*')[0].each_char.to_a
      data_row = []
      @fields_info.each_with_index { |field_info, index|
        field_value =
          if nil_mask[index] == '1'
            nil
          else
            case field_info[:data_type]
              when 3 # int, NULL w/o cast
                @raw_file.read(field_info[:max_length]).unpack('I')[0]
              when 5 # float
                @raw_file.read(field_info[:max_length]).unpack('D')[0]
              when 11 # bit
                (@raw_file.read(field_info[:max_length]).unpack('B')[0] == '1') ? true : false
              when 20 # bigint
                @raw_file.read(field_info[:max_length]).unpack('L')[0]
              when 129 # varchar, char
                data_len = @raw_file.read(4).unpack('I')[0]
                @raw_file.read(data_len).encode({invalid: :replace, undef: :replace})
              when 130 # nvarchar, nchar
                data_len = @raw_file.read(4).unpack('I')[0]
                @raw_file.read(data_len*2).encode(DEFAULT_ENCODING, DEFAULT_RAW_FILE_ENCODING, {invalid: :replace, undef: :replace})
              when 131 # numeric, decimal
                # precision, scale, sign, value
                values_arr = @raw_file.read(field_info[:max_length]).unpack('C3Q')
                "#{('-' if values_arr[2] == 0)}#{values_arr[3].to_s.insert((values_arr[3].to_s.length-values_arr[1]), '.')}"
              when 135 # datetime
                values_arr = @raw_file.read(field_info[:max_length]).unpack('S6I')
                Time.local(values_arr[0], values_arr[1], values_arr[2], values_arr[3], values_arr[4], values_arr[5], (values_arr[6].to_f/1000.0)).strftime('%F %T.%L')
              when 304 # datetime2
                values_arr = @raw_file.read(field_info[:max_length]).unpack('S6I')
                Time.local(values_arr[0], values_arr[1], values_arr[2], values_arr[3], values_arr[4], values_arr[5], (values_arr[6].to_f/1000.0)).strftime("%F %T.%#{field_info[:scale]}N")
              else
                raise UnknownDataTypeError, "Unknown data type #{field_info[:data_type]}"
            end
          end
        data_row << [ field_info[:name], field_value ]
      }
    rescue
      raise
    else
      data_row.to_h
    end
  end

  # get metadata (header) of raw file
  #
  # @return [Array] Array of hash of fields metadata
  def header
    @fields_info
  end

  # get version of raw file
  def version
    @version
  end
end
