module Spec
  def self.environment
    ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_DNS_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_DNS_SECRET_KEY'
    ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_APP_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_APP_SECRET_KEY'

    environment = Mist::Environment.new('qa')
    environment.variables[:git][:local_path] = Dir.mktmpdir
    environment.variables[:git][:repository_uri] = 'git@github.com:railstutorial/sample_app.git'
    environment
  end
end
