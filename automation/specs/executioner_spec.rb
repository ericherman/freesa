require File.join(File.dirname(__FILE__),'spec_helper')

require 'tempfile'
require 'executioner'

describe Executioner do

  before(:each) do
    @temp = Tempfile.new('severian')
    @exec = Executioner.new
  end

  after(:each) do
    @temp.close(true)
  end

  it 'is able to run a simple command' do
    @exec.execute("echo WOOT", @temp.path).should == 0
    File.read(@temp.path).should == "WOOT\n"
  end

  it 'copies stderr to output file' do
    @exec.execute("/bin/bash -c no_such_cmd", @temp.path).should_not == 0
    File.read(@temp.path).should ==
        "/bin/bash: no_such_cmd: command not found\n"
  end

  it 'combines stdout and stderr' do
     out = 'STDOUT.puts("OUT"); STDOUT.flush;'
     err = 'STDERR.puts("err"); STDERR.flush;'
     script = "ruby -e \'#{out} #{err} #{out} #{err}\'"
     @exec.execute(script, @temp.path).should == 0
     File.read(@temp.path).should == "OUT\nerr\nOUT\nerr\n"
  end

end
