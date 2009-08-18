# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'construct'

task :default => 'test'

PROJ.name = 'construct'

PROJ.authors = 'Ben Brinckerhoff (ben@devver.net) and Avdi Grimm (avdi@devver.net)'
PROJ.email = 'ben@devver.net, avdi@devver.net'
PROJ.url = 'http://github.com/devver/construct'
PROJ.version = Construct::VERSION
PROJ.rubyforge.name = 'construct'
PROJ.test.files =  FileList['test/**/*_test.rb']
PROJ.ruby_opts = []
PROJ.readme_file = "README.markdown"
PROJ.summary = "Construct is a DSL for creating temporary files and directories during testing."

PROJ.gem.development_dependencies << ["jeremymcanally-pending", "~> 0.1"]

# EOF
