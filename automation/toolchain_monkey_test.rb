require 'test/unit'
require 'toolchain_monkey'

class ToolchainMonkeyTest < Test::Unit::TestCase

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

  def setup
    @exec = MockExecutioner.new
    @monk = ToolchainMonkey.new(@exec)
  end

end
