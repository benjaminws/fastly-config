require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Run library from within a Pry console'
task :console do
  require 'pry'
  require 'fastly/configure'
  ARGV.clear
  Pry.start
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task default: :test
