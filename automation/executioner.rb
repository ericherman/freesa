class Executioner
  def execute_in_dir(shell_command, output_file, cwd)
    # maybe check if output_file is writable?
    child_pid = Process.fork
    if child_pid # this is the parent
      Process.waitpid(child_pid)
      return $?
    else # this is the child
      Dir.chdir(cwd) if cwd
      $stdout.reopen(output_file)
      $stderr = $stdout
      exec(shell_command)
    end
  end

  def execute(shell_command, output_path)
    execute_in_dir(shell_command, output_path, nil)
  end
end
