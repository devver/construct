module Construct
  module PathExtensions
    
    attr_accessor :construct__chdir_default
    
    def directory(path,chdir=construct__chdir_default)
      subdir = (self + path)
      subdir.mkpath
      subdir.extend(PathExtensions)
      subdir.maybe_change_dir(chdir) do
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

    def maybe_change_dir(chdir, &block)
      if(chdir)
        self.chdir(&block)
      else
        block.call
      end
    end

    # Note: Pathname implements #chdir directly, but it is deprecated in favor
    # of Dir.chdir
    def chdir(&block)
      Dir.chdir(self, &block)
    end

    def destroy!
      rmtree
    end

  end
end
