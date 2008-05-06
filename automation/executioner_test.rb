require 'test/unit'
require 'executioner'

class ExecutionerTest < Test::Unit::TestCase
  def setup
    @exec = Executioner.new
  end

  def test_run_simple_command
    assert_equal 0, @exec.execute("echo WOOT", '/tmp/foobar')
    assert_equal "WOOT\n", File.read('/tmp/foobar')
  end
end
