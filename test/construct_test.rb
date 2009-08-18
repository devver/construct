require File.join(File.dirname(__FILE__), %w[test_helper])
require 'tmpdir'
require 'English'
require 'construct'
require 'ruby-debug'
require 'mocha'

class ConstructTest < Test::Unit::TestCase
  include Construct

  testing 'creating a construct container' do

    test 'should exist' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do
        assert File.directory?(File.join(Dir.tmpdir, "construct_container-#{$PROCESS_ID}-#{num}"))
      end
    end
    
    test 'should yield to its block' do
      sensor = 'no yield'
      within_construct do
        sensor = 'yielded'
      end
      assert_equal 'yielded', sensor
    end
    
    test 'block argument should be container directory Pathname' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do |container_path|
        assert_equal((Pathname(Construct.tmpdir)+"construct_container-#{$PROCESS_ID}-#{num}"), container_path)
      end
    end

    test 'should not exist afterwards' do
      path = nil
      within_construct do |container_path|
        path = container_path
      end
      assert !path.exist?
    end

    test 'should remove entire tree afterwards' do
      path = nil
      within_construct do |container_path|
        path = container_path
        (container_path + 'foo').mkdir
      end
      assert !path.exist?
    end

    test 'should remove dir if block raises exception' do
      path = nil
      begin
        within_construct do |container_path|
          path = container_path
          raise 'something bad happens here'
        end 
      rescue
      end
      assert !path.exist?
    end

    test 'should not capture exceptions raised in block' do
      err = RuntimeError.new('an error')
      begin 
        within_construct do
          raise err
        end
      rescue RuntimeError => e
        assert_same err, e
      end
    end
    
  end

  testing 'creating a file in a container' do
    
    test 'should exist while in construct block' do
      within_construct do |construct|
        construct.file('foo.txt')
        assert File.exists?(construct+'foo.txt')
      end
    end

    test 'should not exist after construct block' do
      filepath = 'unset'
      within_construct do |construct|
        filepath = construct.file('foo.txt')
      end
      assert !File.exists?(filepath)
    end

    test 'writes contents to file' do
      within_construct do |construct|
        construct.file('foo.txt','abcxyz')
        assert_equal 'abcxyz', File.read(construct+'foo.txt')
      end
    end
    
    test 'contents can be given in a block' do
      within_construct do |construct|
        construct.file('foo.txt') do
          <<-EOS
File
Contents
          EOS
        end
        assert_equal "File\nContents\n", File.read(construct+'foo.txt')
      end
    end

    test 'contents block overwrites contents argument' do
      within_construct do |construct|
        construct.file('foo.txt','abc') do
          'xyz'
        end
        assert_equal 'xyz', File.read(construct+'foo.txt')
      end
    end

    test 'block is passed File object' do
      within_construct do |construct|
        construct.file('foo.txt') do |file|
          assert_equal((construct+'foo.txt').to_s, file.path)
        end
      end
    end

    test 'can write to File object passed to block' do
      within_construct do |construct|
        construct.file('foo.txt') do |file|
          file << 'abc'
        end
        assert_equal 'abc', File.read(construct+'foo.txt')
      end
    end

    test 'file is closed after block ends' do
      within_construct do |construct|
        construct_file = nil
        construct.file('foo.txt') do |file|
          construct_file = file
        end
        assert construct_file.closed?
      end
    end

    test 'block return value not used as content if passed File object' do
      within_construct do |construct|
        construct.file('foo.txt') do |file|
          file << 'abc'
          'xyz'
        end
        assert_equal 'abc', File.read(construct+'foo.txt')
      end
    end

    test 'contents argument is ignored if block takes File arg' do
       within_construct do |construct|
        construct.file('foo.txt','xyz') do |file|
          file << 'abc'
        end
        assert_equal 'abc', File.read(construct+'foo.txt')
      end
    end

    test 'returns file path' do
      within_construct do |construct|
        assert_equal(construct+'foo.txt', construct.file('foo.txt'))
      end
    end

    test 'can create file including path in one call' do
      within_construct do |construct|
        construct.file('foo/bar/baz.txt')
        assert (construct+'foo/bar/baz.txt').exist?
      end
    end

    test 'can create file including path in one call when directories exists' do
      within_construct do |construct|
        construct.directory('foo/bar')
        construct.file('foo/bar/baz.txt')
        assert (construct+'foo/bar/baz.txt').exist?
      end
    end

    test 'can create file including path with chained calls' do
      within_construct do |construct|
        construct.directory('foo').directory('bar').file('baz.txt')
        assert (construct+'foo/bar/baz.txt').exist?
      end
    end

  end

  testing 'creating a subdirectory in container' do
    
    test 'should exist while in construct block' do
      within_construct do |construct|
        construct.directory 'foo'
        assert (construct+'foo').directory?
      end
    end

    test 'should not exist after construct block' do
      subdir = 'unset'
      within_construct do |construct|
        construct.directory 'foo'
        subdir = construct + 'foo'
      end
      assert !subdir.directory?
    end

    test 'returns the new path name' do
      within_construct do |construct|
        assert_equal((construct+'foo'), construct.directory('foo'))
      end
    end

    test 'yield to block' do
      sensor = 'unset'
      within_construct do |construct|
        construct.directory('bar') do
          sensor = 'yielded'
        end
      end
      assert_equal 'yielded', sensor
    end

    test 'block argument is subdirectory path' do
      within_construct do |construct|
        construct.directory('baz') do |dir|
          assert_equal((construct+'baz'),dir)
        end
      end
    end

    test 'can create nested directory in one call' do
      within_construct do |construct|
        construct.directory('foo/bar')
        assert (construct+'foo/bar').directory?
      end
    end
    
    test 'can create a nested directory in two calls' do
      within_construct do |construct|
        construct.directory('foo').directory('bar')
        assert (construct+'foo/bar').directory?
      end
    end

  end

  testing "subdirectories changing the working directory" do

    test 'can force directory stays the same' do
      within_construct do |construct|
        old_pwd = Dir.pwd
        construct.directory('foo',false) do
          assert_equal old_pwd, Dir.pwd
        end
      end
    end

    test 'defaults chdir setting from construct' do
      within_construct(false) do |construct|
        old_pwd = Dir.pwd
        construct.directory('foo') do
          assert_equal old_pwd, Dir.pwd
        end
      end
    end

    test 'can override construct default' do
      within_construct(false) do |construct|
        old_pwd = Dir.pwd
        construct.directory('foo', true) do |dir|
          assert_equal dir.to_s, Dir.pwd
        end
      end
    end
    
    test 'current working directory is within subdirectory' do
      within_construct do |construct|
        construct.directory('foo') do |dir|
          assert_equal dir.to_s, Dir.pwd
        end
      end
    end

    test 'current working directory is unchanged outside of subdirectory' do
      within_construct do |construct|
        old_pwd = Dir.pwd
        construct.directory('foo')
        assert_equal old_pwd, Dir.pwd
      end
    end

    test 'current working directory is unchanged after exception' do
      within_construct do |construct|
        old_pwd = Dir.pwd
        begin
          construct.directory('foo') do
            raise 'something bad happens here'
          end
        rescue
        end
        assert_equal old_pwd, Dir.pwd          
      end
    end
    
    test 'should not capture exceptions raised in block' do
      within_construct do |construct|
        error = assert_raises RuntimeError do
          construct.directory('foo') do
            raise 'fail!'
          end
        end
        assert_equal 'fail!', error.message
      end
    end

    test 'checking for a file is relative to subdirectory' do
      within_construct do |construct|
        construct.directory('bar')  do |dir|
          dir.file('foo.txt')
          assert File.exists?('foo.txt')
        end
      end
    end

    test 'checking for a directory is relative to subdirectory' do
      within_construct do |construct|
        construct.directory('foo') do |dir|
          dir.directory('mydir')
          assert File.directory?('mydir')
        end
      end
    end
    
  end

  testing "changing the working directory" do
    
    test 'can force directory stays the same' do
      old_pwd = Dir.pwd
      within_construct(false) do |construct|
        assert_equal old_pwd, Dir.pwd
      end
    end
    
    test 'current working directory is within construct' do
      within_construct do |construct|
        assert_equal construct.to_s, Dir.pwd
      end
    end

    test 'current working directory is unchanged outside of construct' do
      old_pwd = Dir.pwd
      within_construct do |construct|
      end
      assert_equal old_pwd, Dir.pwd
    end

    test 'current working directory is unchanged after exception' do
      old_pwd = Dir.pwd
      begin
        within_construct do |construct|
          raise 'something bad happens here'
        end
      rescue
      end
      assert_equal old_pwd, Dir.pwd
    end
    
    test 'should not capture exceptions raised in block' do
      error = assert_raises RuntimeError do
        within_construct do
          raise 'fail!'
        end
      end
      assert_equal 'fail!', error.message
    end

    test 'checking for a file is relative to container' do
      within_construct do |construct|
        construct.file('foo.txt')
        assert File.exists?('foo.txt')
      end
    end

    test 'checking for a directory is relative to container' do
      within_construct do |construct|
        construct.directory('mydir')
        assert File.directory?('mydir')
      end
    end
    
  end

end
