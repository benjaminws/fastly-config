#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.setup(:default)
require 'fastly/configure'

# do getopts or equivalent for the args
cdn = Fastly::Configure::CDN.new(
  :settings_file => ARGV[0],
  :service_name => ARGV[1],
  :operation => ARGV[2],
  :output_directory => ARGV[3],
  :user => ARGV[4],
  :password => ARGV[5]
)

cdn.build
