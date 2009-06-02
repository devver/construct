require 'test_helper'
require 'tmpdir'
require 'English'
require 'construct'

class ConstructTest < Test::Unit::TestCase
  include Construct

  # add boolean flag to determine whether to switch into construct dir or not
  # possible have user-supplied identifier for creating multiple containers (would help with test isolation as well)
  # #directory should return object that can have #directory called on it again

  testing "creating a construct container" do

    test "should exist" do
      within_construct do
        assert File.directory?(File.join(Dir.tmpdir, "construct_container#{$PROCESS_ID}"))
      end
    end

    test "should yield to its block" do
      sensor = "no yield"
      within_construct do
        sensor = "yielded"
      end
      assert_equal "yielded", sensor
    end

    test "block argument should be container directory Pathname" do
      within_construct do |container_path|
        assert_equal((Pathname(Dir.tmpdir)+"construct_container#{$PROCESS_ID}"), container_path)
      end
    end

    test "should not exist afterwards" do
      path = nil
      within_construct do |container_path|
        path = container_path
      end
      assert !path.exist?
    end

    test "should remove entire tree afterwards" do
      path = nil
      within_construct do |container_path|
        path = container_path
        (container_path + "foo").mkdir
      end
      assert !path.exist?
    end

    test "should remove dir if block raises exception" do
      path = nil
      begin
        within_construct do |container_path|
          path = container_path
          raise "something bad happens here"
        end 
      rescue
      end
      assert !path.exist?
    end

    test "should not capture exceptions raised in block" do
      err = RuntimeError.new("an error")
      begin 
        within_construct do
          raise err
        end
      rescue RuntimeError => e
        assert_same err, e
      end
    end
    
  end

  testing "creating a subdirectory in container" do
    
    test "should exist within construct block" do
      within_construct do |construct|
        construct.directory 'foo'
        assert (construct+'foo').directory?
      end
    end

    test "should not exist after construct block" do
      subdir = "unset"
      within_construct do |construct|
        construct.directory 'foo'
        subdir = construct + 'foo'
      end
      assert !subdir.directory?
    end

    test "returns the new path name" do
      within_construct do |construct|
        assert_equal((construct+'foo'), construct.directory('foo'))
      end
    end

    test "yield to block" do
      sensor = "unset"
      within_construct do |construct|
        construct.directory('bar') do
          sensor = "yielded"
        end
      end
      assert_equal "yielded", sensor
    end

    test "block argument is subdirectory path" do
      within_construct do |construct|
        construct.directory('baz') do |dir|
          assert_equal((construct+'baz'),dir)
        end
      end
    end

  end

end
