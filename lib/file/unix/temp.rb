require 'ffi'
require 'tmpdir'

class File::Temp < File
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  # :stopdoc:

  private

  attach_function :fclose, [:pointer], :int
  attach_function :_fileno, :fileno, [:pointer], :int
  attach_function :strerror, [:int], :string
  attach_function :tmpfile, [], :pointer
  attach_function :tmpnam, [:pointer], :string
  attach_function :mktemp, [:pointer], :string

  private_class_method :mktemp, :strerror, :tmpfile
  private_class_method :tmpnam, :fclose, :_fileno

  public

  # :startdoc:

  # The temporary directory used on MS Windows or Unix by default.
  TMPDIR = ENV['TEMP'] || ENV['TMP'] || ENV['TMPDIR'] || Dir.tmpdir

  # The name of the temporary file. Set to nil if the +delete+ option to the
  # constructor is true.
  attr_reader :path

  # Creates a new, anonymous, temporary file in your File::Temp::TMPDIR
  # directory
  #
  # If the +delete+ option is set to true (the default) then the temporary file
  # will be deleted automatically as soon as all references to it are closed.
  # Otherwise, the file will live on in your File::Temp::TMPDIR path.
  #
  # If the +delete+ option is set to false, then the file is not deleted. In
  # addition, you can supply a string +template+ that the system replaces with
  # a unique filename. This template should end with 3 to 6 'X' characters.
  # The default template is 'rb_file_temp_XXXXXX'. In this case the temporary
  # file lives in the directory where it was created.
  #
  # The +template+ argument is ignored if the +delete+ argument is true.
  #
  # Example:
  #
  #    fh = File::Temp.new(true, 'rb_file_temp_XXXXXX') => file
  #    fh.puts 'hello world'
  #    fh.close
  #
  def initialize(delete: true, template: 'rb_file_temp_XXXXXX', directory: TMPDIR)
    @fptr = nil

    if delete
      @fptr = tmpfile()
      fd = _fileno(@fptr)
    else
      begin
        omask = File.umask(077)
        ptr = FFI::MemoryPointer.from_string(template)
        str = mktemp(ptr)

        if str.nil? || str.empty?
          raise SystemCallError.new('mktemp', FFI.errno)
        end

        @path = File.join(directory, ptr.read_string)
      ensure
        File.umask(omask)
      end
    end

    if delete
      super(fd, 'wb+')
    else
      super(@path, 'wb+')
    end
  end

  # The close method was overridden to ensure the internal file pointer we
  # created in the constructor is closed. It is otherwise identical to the
  # File#close method.
  #
  def close
    super
    fclose(@fptr) if @fptr
  end

  # Generates a unique file name.
  #
  # Note that a file is not actually generated on the filesystem.
  #
  def self.temp_name
    tmpnam(nil) << '.tmp'
  end
end
