#!/usr/bin/env ruby
# run with:
# ruby -I /path/to/litbuild/lib build-toolchain.rb

# REMEMBER TO SET PATH TO INCLUDE /path/to/cross-tools/bin
# and set LC_ALL=POSIX and unset CFLAGS, CXXFLAGS
# These things should be done in the Section being built.

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

cfg_mipsel = {
  'KERNEL_ARCH' => 'ARCH=mips',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'mipsel-unknown-linux-uclibc',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'TMPTOOLS' => '/tmp/tools',
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'UCLIBC_CONFIG' => "#{ENV['HOME']}/gits/freesa/config/uclibc-config-mips",
  'UCLIBC_CROSS_PARAM' => 'CROSS=mipsel-unknown-linux-uclibc-',
  'ENDIANNESS' => 'LITTLE',
  'NOT_ENDIANNESS' => 'BIG'
}

cfg_x86 = {
  'KERNEL_ARCH' => '',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'i686-pc-linux-gnu',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'TMPTOOLS' => '/tmp/tools',
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'UCLIBC_CONFIG' => "#{ENV['HOME']}/gits/freesa/config/uclibc-config-x86",
  'UCLIBC_CROSS_PARAM' => '',
  'ENDIANNESS' => 'little',
  'NOT_ENDIANNESS' => 'big'
}

if ARGV[0] == 'mips'
  puts "Building uClibc/mips toolchain"
  cfg = cfg_mipsel
else
  puts "Building uClibc/x86 toolchain"
  cfg = cfg_x86
end

# UCLIBC_CROSS_PARAM is CROSS=PARAM[TARGET]- when cross-compiling
# This can probably be moved to .config CROSS_COMPILER_PREFIX!!

binutils = package('binutils')
gcc = package('gcc')
uclibc = package('uclibc')
linux = package('linux')
specs = Commands.new(load_misc('specs'), @exec, @log)

[ binutils, gcc, uclibc, linux ].each { |r| r.set(cfg) }

linux.build('sysroot headers')
binutils.build
gcc.build('static compiler')
uclibc.build('full library')
gcc.build('full compiler')
uclibc.build('utilities')

[ binutils, gcc, uclibc, linux ].each { |r| r.cleanup }
