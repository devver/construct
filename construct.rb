require 'pathname'
require 'tmpdir'
require 'English'

module Construct

  module PathExtensions
    
    attr_accessor :files
    
    def directory(path,chdir=false)
      subdir = (self + path)
      subdir.mkpath
      subdir.extend(PathExtensions)
      maybe_change_dir(chdir,subdir) do
        yield(subdir) if block_given?
      end
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

    def maybe_change_dir(chdir,path,&block)
      if(chdir)
        Dir.chdir(path,&block)
      else
        block.call
      end
    end

  end

  def within_construct(chdir=false)
    path = (Pathname(tmpdir)+"construct_container-#{$PROCESS_ID}-#{rand(1_000_000_000)}")
    begin
      path.mkpath
      path.extend(PathExtensions)
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
  
end
