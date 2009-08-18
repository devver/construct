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
end
