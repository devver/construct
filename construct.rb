require 'pathname'
require 'tmpdir'
require 'English'

module Construct

  module PathExtensions
    def directory(path)
      subdir = (self + path)
      subdir.mkpath
      yield subdir if block_given?
      subdir
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
