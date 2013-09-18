module Mist
  class Deployment
    attr_reader :environment, :version_control, :eb

    def initialize(options = {})
      @environment = options.fetch(:environment, Mist::Environment.new(ENV['env'] || 'qa'))
      @version_control = options.fetch(:version_control, Mist::VersionControl.new(environment.variables))
      @eb = options.fetch(:eb, Mist::ElasticBeanstalk.new(environment.variables))
    end

    def deploy_latest
      first_environment = environment.variables[:aws][:eb][:environments].first
      environment_name = first_environment[:name]
      environment_uri = first_environment[:uri]

      version_control.push_latest_version environment_name
      eb.wait_for_environment environment_name, Time.now.utc.iso8601
      website(environment_uri).warm

      Mist.logger.info("Successfully deployed to environment '#{environment_name}' with URL '#{environment_uri}'")
    end

    private

    def website(uri)
      Mist::Website.new(uri)
    end
  end
end
