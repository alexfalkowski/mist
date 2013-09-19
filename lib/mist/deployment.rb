module Mist
  class Deployment
    def initialize(options = {})
      @environment = options.fetch(:environment, Mist::Environment.new(ENV['env'] || 'qa'))
      @version_control = options.fetch(:version_control, Mist::VersionControl.new(environment))
      @eb = options.fetch(:eb, Mist::ElasticBeanstalk.new(environment))
      @dns = options.fetch(:dns, Mist::Dns.new(environment))
      @logger = options.fetch(:logger, Mist.logger)
    end

    def deploy_latest
      current_environment_name = website(environment.dns_config[:domain]).current_environment
      other_environment = environment.find_other_environment(current_environment_name)
      other_environment_name = other_environment[:name]
      other_environment_uri = other_environment[:uri]

      version_control.push_latest_version other_environment_name
      eb.wait_for_environment other_environment_name, Time.now.utc.iso8601
      website(other_environment_uri).warm

      dns.update_endpoint other_environment_name

      logger.info("Successfully deployed to environment '#{other_environment_name}' with URL '#{other_environment_uri}'")
    end

    private

    attr_reader :environment, :version_control, :eb, :dns, :logger

    def website(uri)
      Mist::Website.new(uri)
    end
  end
end
