#!/usr/bin/env ruby
# run with:
# ruby -I /path/to/litbuild/lib build-toolchain.rb
# REMEMBER TO SET PATH TO INCLUDE /path/to/cross-tools/bin
# and set LC_ALL=POSIX and unset CFLAGS, CXXFLAGS

require 'litbuild'

@log = GlobalLogPolicy.new('/tmp/Build/logs')

def load_misc(name)
  File.read(File.join("miscellany", "#{name}.txt"))
end
def package(name)
  text = File.read(File.join('packages', "#{name}.txt"))
  parent_dir = File.join("/tmp", "Build")
  Package.new(text, @log, parent_dir)
end

cfg_base = {
  'SYSROOT' => '/tmp/cross-tools/sysroot',
  'HOST' => 'i686-cross-linux-gnu',
  'TOOL_PREFIX' => '/tmp/cross-tools',
  'KERNEL_VERSION' => '3.10.9',
  'TMPTOOLS' => '/tmp/tools',
  'TARFILE_DIR' => '/home/random/toolchain-sources',
  'PATCH_DIR' => '/home/random/gits/freesa/patches'
}

cfg_x86 = {
  'KERNEL_ARCH' => '',
  'TARGET' => 'i686-pc-linux-gnu',
  'GLIBCFLAG' => '-march=i686 -g -O2'
}

cfg_mips = {
  'KERNEL_ARCH' => 'ARCH=mips',
  'KERNEL_VERSION' => '3.6',
  'TARGET' => 'mips64el-unknown-linux-gnu',
  'GLIBCFLAG' => '-g -O2 -march=mips64 -mabi=64'
}

if ARGV[0] == 'mips'
  puts "Building glibc/mips toolchain"
  cfg = cfg_base.merge(cfg_mips)
else
  puts "Building glibc/x86 toolchain"
  cfg = cfg_base.merge(cfg_x86)
end

binutils = package('binutils')
gcc = package('gcc')
glibc = package('glibc')
linux = package('linux')
specs = Commands.new(load_misc('specs'), @log)

[ binutils, gcc, glibc, linux, specs ].each { |r| r.set(cfg) }

File.open("/tmp/01-linux-sysroot-headers.sh",'w') { |f| 
  f.puts(linux.to_bash_script('sysroot headers')) 
}
File.open("/tmp/02-binutils.sh", 'w') { |f| 
  f.puts(binutils.to_bash_script) 
}
File.open("/tmp/03-gcc-static.sh", 'w') { |f| 
  f.puts(gcc.to_bash_script('static compiler')) 
}
File.open("/tmp/04-glibc-sysroot.sh", 'w') { |f| 
  f.puts(glibc.to_bash_script('sysroot glibc')) 
}
File.open("/tmp/05-gcc-full.sh", 'w') { |f| 
  f.puts(gcc.to_bash_script('full compiler')) 
}
File.open("/tmp/06-linux-tools-headers.sh", 'w') { |f| 
  f.puts(linux.to_bash_script('temporary tool headers')) 
}
File.open("/tmp/07-glibc-tools.sh", 'w') { |f| 
  f.puts(glibc.to_bash_script('temporary tool glibc')) 
}
File.open("/tmp/08-specs.sh", 'w') { |f| 
  f.puts(specs.to_bash_script) 
}
