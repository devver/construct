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
      subdir
    end
    
    def file(filename)
      File.new(self+filename,'w')
    end

  end

  def within_construct
    path = (Pathname(Dir.tmpdir)+"construct_container#{$PROCESS_ID}")
    begin
      path.mkpath
      path.extend(PathExtensions)
      yield(path)
    ensure
      path.rmtree
    end
  end
  
end
