# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'semver'

def s_version
  SemVer.find.format "%M.%m.%p%s"
end
require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "rzmq-enhancement"
  gem.homepage = "http://github.com/flajann2/rzmq-enhancement"
  gem.license = "MIT"
  gem.summary = %Q{Wrapper for the ffi-rzmq wrapper for ZeroMQ}
  gem.description = %Q{
  The ffi-rzmq wraps ZeroMQ nicely, but not in a Ruby-friendly manner.
  here, we take that one step further to present a mor Ruby-Friendy
  interface.}
  gem.email = "frederick.mitchell@sensorberg.com"
  gem.authors = ["Fred Mitchell", "Sensorberg GmbH"]
  gem.version = s_version

  # dependencies defined in Gemfile
end

Juwelier::RubygemsDotOrgTasks.new
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
