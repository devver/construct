require 'pathname'
require 'tmpdir'
require 'English'

module Construct

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
  
end
