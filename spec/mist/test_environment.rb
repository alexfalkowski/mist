module TestEnvironment
  def self.variables
    ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_DNS_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_DNS_SECRET_KEY'
    ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_APP_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_APP_SECRET_KEY'

    Mist::Environment.new('qa').variables.tap { |v|
      v[:git][:local_path] = Dir.mktmpdir
      v[:git][:repository_uri] = 'git@github.com:railstutorial/sample_app.git'
    }
  end
end
