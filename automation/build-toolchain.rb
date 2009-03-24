#!/usr/bin/env ruby
# run with:
# ruby -I /path/to/litbuild/lib build-toolchain.rb

require 'litbuild'

@log = GlobalLogPolicy.new('/mnt/Build/logs')

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
  parent_dir = File.join("/mnt", "Build")
  Package.new(text, @exec, @log, parent_dir)
end

#@exec = ShuntExecutioner.new
@exec = Executioner.new

cfg = {
  'KERNEL_ARCH' => '',
  'SYSROOT' => '/cross-tools/sysroot',
  'TARFILE_DIR' => '/mnt/Sources',
  'HOST' => 'i686-cross-linux-gnu',
  'PATCH_DIR' => '/mnt/Freesa/patches',
  'TARGET' => 'i686-pc-linux-gnu',
  'TOOL_PREFIX' => '/cross-tools',
  'GLIBCFLAG' => '-march=i686 -mtune=generic -g -O2',
  'KERNEL_VERSION' => '2.6.28'
}

binutils = package('binutils')
gcc = package('gcc')
glibc = package('glibc')
linux = package('linux')
specs = Commands.new(load_misc('specs'), @exec, @log)

[ binutils, gcc, glibc, linux, specs ].each { |r| r.set(cfg) }

linux.build('sysroot headers')
binutils.build
glibc.build('headers')
gcc.build('bare compiler')
glibc.build('startup files')
gcc.build('libgcc')
glibc.build('full glibc')
gcc.build('full compiler')
linux.build('temporary tool headers')
glibc.build('temporary tool glibc')
specs.build

[ binutils, gcc, glibc, linux ].each { |r| r.cleanup }
