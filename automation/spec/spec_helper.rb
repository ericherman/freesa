lib_path = File.expand_path(File.join("#{File.dirname(__FILE__)}",'..','lib'))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'rubygems'
gem 'rspec'
require 'spec'        # explicitly required for autotest

gem 'ruby-debug'
require 'ruby-debug'
