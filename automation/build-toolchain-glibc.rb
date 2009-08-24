#!/usr/bin/env ruby
# run with:
# ruby -I /path/to/litbuild/lib build-toolchain.rb
# REMEMBER TO SET PATH TO INCLUDE /path/to/cross-tools/bin
# and set LC_ALL=POSIX and unset CFLAGS, CXXFLAGS

require 'litbuild'

@log = GlobalLogPolicy.new('/tmp/Build/logs')

class ShuntExecutioner < Executioner
  def execute_in_dir(shell_command, output_file, cwd)
    puts "IN [#{cwd}] RUN [#{shell_command}] LOGGING TO [#{output_file}]"
  end
end

def load_misc(name)
  File.read(File.join("miscellany", "#{name}.txt"))
end
def package(name)
  text = File.read(File.join('packages', "#{name}.txt"))
  parent_dir = File.join("/tmp", "Build")
  Package.new(text, @exec, @log, parent_dir)
end

#@exec = ShuntExecutioner.new
@exec = Executioner.new

cfg_x86 = {
  'KERNEL_ARCH' => '',
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'i686-pc-linux-gnu',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'GLIBCFLAG' => '-march=i686 -g -O2',
  'KERNEL_VERSION' => '2.6.29',
  'TMPTOOLS' => '/tmp/tools'
}

cfg_mips = {
  'KERNEL_ARCH' => 'ARCH=mips',
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'mipsel-unknown-linux-gnu',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'GLIBCFLAG' => '-g -O2',
  'KERNEL_VERSION' => '2.6.25',
  'TMPTOOLS' => '/tmp/tools'
}

cfg = cfg_mips

binutils = package('binutils')
gcc = package('gcc')
glibc = package('glibc')
linux = package('linux')
specs = Commands.new(load_misc('specs'), @exec, @log)

[ binutils, gcc, glibc, linux, specs ].each { |r| r.set(cfg) }

linux.build('sysroot headers')
binutils.build
gcc.build('static compiler')
glibc.build('sysroot glibc')
gcc.build('full compiler')
linux.build('temporary tool headers')
glibc.build('temporary tool glibc')
specs.build

[ binutils, gcc, glibc, linux ].each { |r| r.cleanup }
