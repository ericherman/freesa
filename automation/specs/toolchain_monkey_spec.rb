require File.join(File.dirname(__FILE__),'spec_helper')

require 'toolchain_monkey'

class MockExecutioner
  def initialize
    @expected = []
    @actual = []
  end
  def expect(shell_command); @xpected << shell_command; end

  def run(shell_command); @actual << shell_command; end

  def validate
    assert_equal @expected, @actual
  end
end

describe ToolchainMonkey do

  before(:each) do
    @exec = MockExecutioner.new
    @monk = ToolchainMonkey.new(@exec)
  end

  it 'is tested' do
  end

end
