#!/usr/bin/env ruby
# run with:
# ruby -I /path/to/litbuild/lib build-toolchain.rb
# REMEMBER TO SET PATH TO INCLUDE /path/to/cross-tools/bin
# and set LC_ALL=POSIX and unset CFLAGS, CXXFLAGS

require 'litbuild'

@log = GlobalLogPolicy.new('/media/ramfs')

class ShuntExecutioner < Executioner
  def execute_in_dir(shell_command, output_file, cwd)
    puts "IN [#{cwd}] RUN [#{shell_command}] LOGGING TO [#{output_file}]"
  end
end

def package(name)
  text = File.read(File.join('packages', "#{name}.txt"))
  parent_dir = File.join("/tmp", "Build")
  Package.new(text, @exec, @log, parent_dir)
end

@exec = ShuntExecutioner.new
#@exec = Executioner.new

cfg = {
  'KERNEL_ARCH' => '',
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'i686-pc-linux-gnu',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'GLIBCFLAG' => '-march=i686 -g -O2',
  'KERNEL_VERSION' => '2.6.29',
  'TMPTOOLS' => '/tmp/tools',
  'PATCH_DIR' => '/patches',
  'TARFILE_DIR' => '/sources',
  'UCLIBC_CONFIG' => '/path/to/uclibc.config'
}

uclibc = package('uclibc')
uclibc.set(cfg)

uclibc.build('headers')
