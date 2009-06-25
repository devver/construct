require 'pathname'
require 'tmpdir'
require 'English'

module Construct

  module PathExtensions
    
    attr_accessor :files
    
    def directory(path)
      subdir = (self + path)
      subdir.mkpath
      yield subdir if block_given?
      subdir.extend(PathExtensions)
      subdir
    end
    
    def file(filename,contents=nil)
      path = (self+filename)
      File.open(path,'w') do |f|
        contents = yield if block_given?
        f << contents
      end
      path
    end

  end

  def within_construct(chdir=false)
    path = (Pathname(tmpdir)+"construct_container-#{$PROCESS_ID}-#{rand(1_000_000_000)}")
    begin
      path.mkpath
      path.extend(PathExtensions)
      return_to_current_working_directory do
        Dir.chdir(path)
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

  private
  
  def return_to_current_working_directory
    pwd = Dir.pwd
    begin
      yield
    ensure
      Dir.chdir(pwd)
    end
  end

  extend(self)
  
end
