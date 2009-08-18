require 'pathname'
require 'tmpdir'
require 'English'

module Construct

  # :stopdoc:
  VERSION = '1.0.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
                                   ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  module PathExtensions
    
    attr_accessor :construct__chdir_default
    
    def directory(path,chdir=construct__chdir_default)
      subdir = (self + path)
      subdir.mkpath
      subdir.extend(PathExtensions)
      maybe_change_dir(chdir,subdir) do
        yield(subdir) if block_given?
      end
      subdir
    end
    
    def file(filepath,contents=nil,&block)
      path = (self+filepath)
      path.dirname.mkpath
      File.open(path,'w') do |f|
        if(block)
          if(block.arity==1)
            block.call(f)
          else
            f << block.call
          end
        else
          f << contents
        end
      end
      path
    end

    def maybe_change_dir(chdir,path,&block)
      if(chdir)
        Dir.chdir(path,&block)
      else
        block.call
      end
    end

  end

  def within_construct(chdir=true)
    path = (Pathname(tmpdir)+"construct_container-#{$PROCESS_ID}-#{rand(1_000_000_000)}")
    begin
      path.mkpath
      path.extend(PathExtensions)
      path.construct__chdir_default = chdir
      maybe_change_dir(chdir,path) do
        yield(path)
      end
    ensure
      path.rmtree
    end
  end

  def tmpdir
    dir = nil
    Dir.chdir Dir.tmpdir do dir = Dir.pwd end # HACK FOR OSX
    dir
  end

  extend(self)
  include(PathExtensions)
  
end  # module Construct

Construct.require_all_libs_relative_to(__FILE__)

# EOF
