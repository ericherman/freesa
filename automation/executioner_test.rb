require 'tempfile'
require 'test/unit'
require 'executioner'

class ExecutionerTest < Test::Unit::TestCase
  def setup
    @temp = Tempfile.new('severian')
    @exec = Executioner.new
  end

  def teardown
    @temp.close(true)
  end

  def test_run_simple_command
    assert_equal 0, @exec.execute("echo WOOT", @temp.path)
    assert_equal "WOOT\n", File.read(@temp.path)
  end

  def test_run_command_with_stderr
    assert_not_equal 0, @exec.execute("/bin/bash -c no_such_cmd", @temp.path)
    assert_equal "/bin/bash: no_such_cmd: command not found\n", 
        File.read(@temp.path)
  end

  def test_run_command_with_mingled_out_and_err
    out = 'STDOUT.puts("OUT"); STDOUT.flush;'
    err = 'STDERR.puts("err"); STDERR.flush;'
    script = "ruby -e \'#{out} #{err} #{out} #{err}\'"
    assert_equal 0, @exec.execute(script, @temp.path)
    assert_equal "OUT\nerr\nOUT\nerr\n", File.read(@temp.path)
  end
end
