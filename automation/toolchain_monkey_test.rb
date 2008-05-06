require 'test/unit'
require 'toolchain_monkey'

class ToolchainMonkeyTest < Test::Unit::TestCase

  class MockExecutioner
    def run(shell_command)
    end
  
    def validate
    end
  end

  def setup
    @exec = MockExecutioner.new
    @monk = ToolchainMonkey.new(@exec)
  end

end
