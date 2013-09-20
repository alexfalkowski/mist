module Mist
  class Deployment
    def initialize(options = {})
      @environment = options.fetch(:environment, Mist::Environment.new(options[:stack]))
      @version_control = options.fetch(:version_control, Mist::VersionControl.new(environment: environment))
      @eb = options.fetch(:eb, Mist::ElasticBeanstalk.new(environment))
      @dns = options.fetch(:dns, Mist::Dns.new(environment))
      @logger = options.fetch(:logger, Mist.logger)
    end

    def deploy_latest_to_stack
      current_environment_name = website(environment.dns_config[:domain]).current_environment
      next_environment = environment.find_next_environment(current_environment_name)
      next_environment_name = next_environment[:name]
      next_environment_uri = next_environment[:uri]

      deploy(next_environment_name, next_environment_uri)
      dns.update_endpoint next_environment_name
      log_success(next_environment_name, next_environment_uri)
    end

    def deploy_latest_to_environment(name)
      current_environment = environment.find_environment(name)

      raise "Could not find environment with name '#{name}'" unless current_environment

      current_environment_uri = current_environment[:uri]
      deploy(name, current_environment_uri)
      log_success(name, current_environment_uri)
    end

    private

    attr_reader :environment, :version_control, :eb, :dns, :logger

    def deploy(name, uri)
      version_control.push_latest_version name
      eb.wait_for_environment name, current_time
      website(uri).warm
    end

    def log_success(name, uri)
      logger.info("Successfully deployed to environment '#{name}' with URL '#{uri}'")
    end

    def current_time
      Time.now.utc.iso8601
    end

    def website(uri)
      Mist::Website.new(uri)
    end
  end
end
