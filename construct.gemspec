# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{construct}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Brinckerhoff (ben@devver.net) and Avdi Grimm (avdi@devver.net)"]
  s.date = %q{2009-09-09}
  s.default_executable = %q{construct}
  s.description = %q{}
  s.email = %q{ben@devver.net, avdi@devver.net}
  s.executables = ["construct"]
  s.extra_rdoc_files = ["History.txt", "bin/construct"]
  s.files = ["History.txt", "README.markdown", "Rakefile", "bin/construct", "construct.gemspec", "geminstaller.yml", "lib/construct.rb", "lib/construct/helpers.rb", "lib/construct/path_extensions.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "tasks/zentest.rake", "test/construct_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/devver/construct}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{construct}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Construct is a DSL for creating temporary files and directories during testing.}
  s.test_files = ["test/construct_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
      s.add_development_dependency(%q<jeremymcanally-pending>, ["~> 0.1"])
    else
      s.add_dependency(%q<bones>, [">= 2.5.1"])
      s.add_dependency(%q<jeremymcanally-pending>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<bones>, [">= 2.5.1"])
    s.add_dependency(%q<jeremymcanally-pending>, ["~> 0.1"])
  end
end
