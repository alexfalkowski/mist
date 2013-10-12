module Spec
  def self.environment(name = 'qa')
    ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_DNS_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_DNS_SECRET_KEY'
    ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_APP_ACCESS_KEY_ID'
    ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_APP_SECRET_KEY'
    ENV[Mist::Environment::NEWRELIC_API_KEY] = 'NEWRELIC_API_KEY'

    environment = Mist::Environment.new(name: name, path: CONFIG_PATH)
    environment.variables[:git][:local_path] = Dir.mktmpdir
    environment
  end
end
