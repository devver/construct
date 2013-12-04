## THIS GEM IS DEPRECATED

The successor RubyGem (with a more consistent gem name) is [TestConstruct](https://github.com/bhb/test_construct). Please report all issues there.

Construct
=========
    by Ben Brinckerhoff and Avdi Grimm
    http://github.com/devver/construct

DESCRIPTION:
============

"This is the construct. It's our loading program. We can load anything, from clothing to equipment, weapons, and training simulations, anything we need" -- Morpheus

Construct is a DSL for creating temporary files and directories during testing.

SYNOPSIS:
========

    class ExampleTest < Test::Unit::TestCase
      include Construct::Helpers

      def test_example
        within_construct do |c|
          c.directory 'alice/rabbithole' do |d|
            d.file 'white_rabbit.txt', "I'm late!"
            
            assert_equal "I'm late!", File.read('white_rabbit.txt')
          end
        end
      end

    end

USAGE
=====

To use Construct, you need to include the Construct module in your class like so:

    include Construct::Helpers

Using construct is as simple as calling `within_construct` and providing a block. All files and directories that are created within that block are created within a temporary directory. The temporary directory is always deleted before `within_construct` finishes.

There is nothing special about the files and directories created with Construct, so you can use plain old Ruby IO methods to interact with them.

Creating files
--------------

The most basic use of Construct is creating an empty file with the:

    within_construct do |construct|
      construct.file('foo.txt')
    end

Note that the working directory is, by default, automatically change to the temporary directory created by Construct, so the following assertion will pass:

    within_construct do |construct|
      construct.file('foo.txt')
      assert File.exist?('foo.txt')
    end

You can also provide content for the file, either with an optional argument or using the return value of a supplied block:

    within_construct do |construct|
      construct.file('foo.txt','Here is some content')
      construct.file('bar.txt') do
      <<-EOS
      The block will return this string, which will be used as the content.
      EOS
      end
    end

If you provide block that accepts a parameter, construct will pass you the IO object. In this case, you are responsible for writing content to the file yourself - the return value of the block will not be used:

    within_construct do |construct|
      construct.file('foo.txt') do |file|
        file << "Some content\n"
        file << "Some more content"
      end
    end

Finally, you can provide the entire path to a file and the parent directories will be created automatically:

    within_construct do |construct|
      construct.file('foo/bar/baz.txt')
    end

Creating directories
--------------

It is easy to create a directory:

    within_construct do |construct|
      construct.directory('foo')
    end

You can also provide a block. The object passed to the block can be used to create nested files and directories (it's just a [Pathname](http://www.ruby-doc.org/stdlib/libdoc/pathname/rdoc/index.html) instance with some extra functionality, so you can use it to get the path of the current directory).

Again, note that the working directory is automatically changed while in the block:

    within_construct do |construct|
      construct.directory('foo') do |dir|
        dir.file('bar.txt')
        assert File.exist?('bar.txt') # This assertion will pass
      end
    end

Again, you can provide paths and the necessary directories will be automatically created:

    within_construct do |construct|
      construct.directory('foo/bar/') do |dir|
        dir.directory('baz')
        dir.directory('bazz')
      end
    end

Please read test/construct_test.rb for more examples.

INSTALL
=======

gem install devver-construct --source http://gems.github.com

LICENSE
=======

(The MIT License)

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
