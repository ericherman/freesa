#!/usr/bin/env ruby

# Run this from this directory with: 
# ruby -I /path/to/litbuild/lib build-toolchain.rb

require 'litbuild'

class ShuntExecutioner < Executioner
  def execute_in_dir(shell_command, output_file, cwd)
    puts "IN [#{cwd}] RUN [#{shell_command}] LOGGING TO [#{output_file}]"
  end
end

def load_misc(name)
  File.read(File.join("miscellany", "#{name}.txt"))
end
def package(name, version)
  text = File.read(File.join('packages', "#{name}.txt"))
  sourcedir = File.join("$HOME", "build", "#{name}-#{version}")
  Package.new(text, @exec, sourcedir, @logdir)
end

@logdir = File.join("$HOME", "build", "log")
@exec = ShuntExecutioner.new

cfg = {
  'KERNEL_ARCH' => '',
  'SYSROOT' => '/cross-tools/sysroot',
  'TARFILE_DIR' => '$HOME/work',
  'HOST' => 'i686-cross-linux-gnu',
  'PATCH_DIR' => '../patches',
  'TARGET' => 'i686-pc-linux-gnu',
  'TOOL_PREFIX' => '/cross-tools',
  'GLIBCFLAG' => '-march=i686 -mtune=generic -g -O2',
  'KERNEL_VERSION' => '2.6.28'
}

binutils = package('binutils', '2.19')
gcc = package('gcc', '4.3.2')
glibc = package('glibc', '2.9')
linux = package('linux', '2.6.28')
specs = Commands.new(load_misc('specs'), @exec, @logdir)

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
