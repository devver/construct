require 'construct/path_extensions'

module Construct
  module Helpers
    include PathExtensions
    extend self

    def within_construct(chdir=true)
      container = create_construct(chdir)
      container.maybe_change_dir(chdir) do
        yield(container)
      end
    ensure
      container.destroy!
    end

    def create_construct(chdir=true)
      path = (Pathname(Construct.tmpdir) + 
        "#{CONTAINER_PREFIX}-#{$PROCESS_ID}-#{rand(1_000_000_000)}")
      path.mkpath
      path.extend(PathExtensions)
      path.construct__chdir_default = chdir
      path
    end

  end
  
  extend Helpers
end
