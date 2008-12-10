$LOAD_PATH << '/home/random/litbuild/lib'
require 'executioner'
require 'package'
config = {
  'KERNEL_ARCH' => '',
  'SYSROOT' => '/tmp/sysroot',
  'HOST' => 'i686-cross-linux-gnu',
  'TARGET' => 'i686-pc-linux-gnu'
}
class ShuntExecutioner < Executioner
  def execute_in_dir(shell_command, output_file, cwd)
    puts "IN [#{cwd}] RUN [#{shell_command}] LOGGING TO [#{output_file}]"
  end
end
e = ShuntExecutioner.new
[ 'linux', 'binutils' ].each { |package|
  desc = File.read("#{package}.txt")
  p = Package.new(desc, e, "/usr/local/rnd/toolchain/#{package}", '/tmp/log')
  p.set(config)
  p.build
}
