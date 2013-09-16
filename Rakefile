$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'mist'
require 'rspec/core/rake_task'

namespace :mist do
  RSpec::Core::RakeTask.new(:spec)

  desc 'Deploy to an environment (to specify environment pass in env=qa|uat|live, defaults to qa'
  task :deploy do
    environment = Mist::Environment.new(ENV['env'] || 'qa')
    version_control = Mist::VersionControl.new(environment.variables)
    version_control.deploy_latest_version
  end
end
