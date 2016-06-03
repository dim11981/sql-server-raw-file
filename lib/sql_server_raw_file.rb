# coding: utf-8

require(File.expand_path('../../lib/version.rb',__FILE__))

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
  #   00.90.00.00 => 9 (SQL Server: 9,10)
  #   00.10.01.00 => 10 (SQL Server: 11,12)
  SUPPORTED_RAW_VERSIONS = %w(00.10.01.00 00.90.00.00)

  # initialization
  #
  # @param io [String, IO] Path to raw file or io-stream
  # @param init_pos [Integer, nil] Initial position in raw file or nil
  # @return [SqlServerDts::RawFile, [SqlServerDts::RawFile,IO]] Within block it returns self and io-stream
  #   in other side returns self
  def initialize(io,init_pos=nil)
    if io.is_a?(IO)
      @raw_io = io
      @raw_io.binmode unless @raw_io.binmode?
      read_header
      @raw_io.seek(init_pos || @data_pos)
    else
      @raw_io = File.new(io,'rb')
      read_header
      @raw_io.seek(init_pos || @data_pos)
      if block_given?
        begin
          yield [self,@raw_io]
        ensure
          @raw_io.close
        end
      else
        self
      end
    end
  end

  # read metadata (header) raw file and fill inner array of metadata
  def read_header
    raise IOError, 'Stream is closed' if @raw_io.closed?
    begin
      @raw_io.rewind
      @version = @raw_io.read(4).unpack('H2H2H2H2').join('.')
      raise UnsupportedRawVersionError, "Version #{@version} unsupported " unless SUPPORTED_RAW_VERSIONS.include?(@version)
      @fields_info = []
      fields_count = @raw_io.read(4).unpack('I')[0]
      raise FieldsNotExistsError, 'Fields not exists (fields_count=0)' if fields_count==0
      @nil_mask_len = fields_count/8+(fields_count-fields_count/8*8>0?1:0)
      fields_count.times {
        name_len = @raw_io.read(4).unpack('I')[0]
        field_name = @raw_io.read(name_len*2).encode(DEFAULT_ENCODING,DEFAULT_RAW_FILE_ENCODING,{ invalid: :replace, undef: :replace })
        (@version == '00.10.01.00') ?
            values_arr = @raw_io.read(40).unpack('I4iI5') :
            values_arr = @raw_io.read(32).unpack('I4iI3')
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
      @data_pos = @raw_io.pos
    end
  end

  # read line of raw data
  #
  # @return [Hash] Hash of converted raw data (one line)
  def read_line
    raise IOError, 'Stream is closed' if @raw_io.closed?
    begin
      nil_mask = @raw_io.read(@nil_mask_len).unpack('b*')[0].each_char.to_a
      data_row = []
      @fields_info.each_with_index { |field_info, index|
        field_value =
          if nil_mask[index] == '1'
            nil
          else
            case field_info[:data_type]
              when 2 # smallint
                @raw_io.read(get_len(field_info)).unpack('s')[0]
              when 3 # int, NULL w/o cast
                @raw_io.read(get_len(field_info)).unpack('i')[0]
              when 4 # real (float(24))
                @raw_io.read(get_len(field_info)).unpack('f')[0]
              when 5 # float
                @raw_io.read(get_len(field_info)).unpack('d')[0]
              when 6 # money (decimal(19,4)), smallmoney ((decimal(10,4)))
                values_arr = @raw_io.read(get_len(field_info)).unpack('q')
                "#{values_arr[0].to_s.insert((values_arr[0].to_s.length-4), '.')}"
              when 11 # bit
                (@raw_io.read(get_len(field_info)).unpack('B')[0] == '1') ? true : false
              when 17 # tinyint
                @raw_io.read(get_len(field_info)).unpack('C')[0]
              when 20 # bigint
                @raw_io.read(get_len(field_info)).unpack('q')[0]
              when 72 # uniqueidentifier
                uid_arr = @raw_io.read(get_len(field_info)).unpack('H2'*get_len(field_info))
                uid_arr[0..3].reverse.join+'-'+uid_arr[4..5].reverse.join+'-'+uid_arr[6..7].reverse.join+'-'+uid_arr[8..9].join+'-'+uid_arr[10..-1].join
              when 128 # varbinary, binary, timestamp
                data_len = get_len
                @raw_io.read(data_len).unpack('H2'*data_len).join
              when 129 # varchar, char
                data_len = get_len
                @raw_io.read(data_len).encode({invalid: :replace, undef: :replace})
              when 130 # nvarchar, nchar
                @raw_io.read(get_len*2).encode(DEFAULT_ENCODING, DEFAULT_RAW_FILE_ENCODING, {invalid: :replace, undef: :replace})
              when 131 # numeric, decimal
                # precision, scale, sign, value
                values_arr = @raw_io.read(get_len(field_info)).unpack('C3Q')
                "#{('-' if values_arr[2] == 0)}#{values_arr[3].to_s.insert((values_arr[3].to_s.length-values_arr[1]), '.')}"
              when 133 # date
                values_arr = @raw_io.read(get_len(field_info)).unpack('S3')
                Date.new(values_arr[0], values_arr[1], values_arr[2])
              when 135 # datetime, smalldatetime
                values_arr = @raw_io.read(get_len(field_info)).unpack('S6I')
                Time.local(values_arr[0], values_arr[1], values_arr[2], values_arr[3], values_arr[4], "#{values_arr[5]}.#{values_arr[6]}".to_f).strftime('%F %T.%L')
              when 145 # time
                values_arr = @raw_io.read(10).unpack('S3I')
                Time.local(Time.now.year, Time.now.month, Time.now.day, values_arr[0], values_arr[1], "#{values_arr[2]}.#{values_arr[3]}".to_f).strftime("%T.%#{field_info[:scale]}N")
              when 146 # datetimeoffset
                values_arr = @raw_io.read(get_len(field_info)).unpack('S6Is2')
                Time.new(values_arr[0], values_arr[1], values_arr[2], values_arr[3], values_arr[4], "#{values_arr[5]}.#{values_arr[6]}".to_f,format('%+03d:%02d',values_arr[7],values_arr[8].abs)).strftime("%F %T.%#{field_info[:scale]}N%:z")
              when 304 # datetime2
                values_arr = @raw_io.read(get_len(field_info)).unpack('S6I')
                Time.local(values_arr[0], values_arr[1], values_arr[2], values_arr[3], values_arr[4], "#{values_arr[5]}.#{values_arr[6]}".to_f).strftime("%F %T.%#{field_info[:scale]}N")
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

  # get field data len by metadata or from stream
  def get_len(field_info=nil)
    if field_info.nil?
      @raw_io.read(4).unpack('I')[0]
    else
      field_info[:max_length]
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

  # close io-stream
  def close
    @raw_io.close unless @raw_io.closed?
  end

  # check io-stream eof
  def eof?
    @raw_io.eof?
  end

  # get current position in inner io-stream object
  def pos
    @raw_io.pos
  end

  private :get_len
end
