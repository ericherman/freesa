require File.join(File.dirname(__FILE__),'spec_helper')

require 'package'

SIMPLE = <<PACKAGE_END
name: a simple package
version: 1.0

Here is some sample text describing a simple package.  There
might be any amount of text here, and it might be arranged in any
number of paragraphs.

The goal of the package structure is to have a simple format that
is easy to read as a plain text file and can be used in a variety
of ways.  The literate build system must be able to use the
package files to copmile the packages from a source bundle, but,
even more importantly, it should be able to compile the package
files into a book (or set of HTML pages) describing the entire
build system.  As far as that goes, it should be possible for
people to read the package file if they want to learn about the
package, what its purpose is, and how to build it.

We know we have come to the end of the descriptive text block
when we see a line that consists of lowercase alphabetic
characters and hyphens, terminated with a colon.  Or, as in the
case of this simple package, when we come to the end of the file.
PACKAGE_END

describe Package, ' (simple)' do

  before(:each) do
    @p = Package.new(SIMPLE)
  end

  it 'knows its name' do
    @p.name.should == 'a simple package'
  end

  it 'knows its version' do
    @p.version.should == '1.0'
  end

  it 'has a basic configure command' do
    @p.configure.should == [ './configure --prefix=/usr' ]
  end

  it 'has a basic make command' do
    @p.make.should == [ 'make' ]
  end

  it 'has a basic test command' do
    @p.test.should == [ 'make check' ]
  end

  it 'has a basic install command' do
    @p.install.should == [ 'make install' ]
  end

end

