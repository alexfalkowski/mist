$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'mist'
require 'rspec/core/rake_task'

namespace :mist do
  RSpec::Core::RakeTask.new(:spec)

  desc 'Deploy the latest to an environment (to specify environment pass in env=qa|uat|live, defaults to qa'
  task :deploy_latest do
    Mist::Deployment.new.deploy_latest
  end
end
