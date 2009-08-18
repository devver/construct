require 'construct/path_extensions'

module Construct
  module Helpers
    include PathExtensions
    extend self

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

  end
end
