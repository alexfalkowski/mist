module Mist
  class Deployment
    def initialize(options = {})
      @environment = options.fetch(:environment) { Mist::Environment.new(options[:stack]) }
      @version_control = options.fetch(:version_control) { Mist::VersionControl.new(environment: environment) }
      @eb = options.fetch(:eb) { Mist::ElasticBeanstalk.new(environment: environment) }
      @dns = options.fetch(:dns, Mist::Dns.new(environment: environment))
      @logger = options.fetch(:logger, Mist.logger)
      @newrelic = options.fetch(:newrelic) { Mist::Newrelic.new(environment: environment) }
    end

    def deploy_latest_to_stack
      next_environment = environment.find_next_environment(current_environment_name)
      next_environment_name = next_environment[:name]
      next_environment_uri = next_environment[:uri]

      deploy(next_environment_name, next_environment_uri)
      dns.update_endpoint next_environment_name
      newrelic.mark_deployment environment_version(next_environment_name)
      log_success(next_environment_name, next_environment_uri)
    end

    def deploy_latest_to_environment(name)
      current_environment = find_environment(name)
      current_environment_uri = current_environment[:uri]

      deploy(name, current_environment_uri)
      log_success(name, current_environment_uri)
    end

    def update_stack_endpoint
      next_environment = environment.find_next_environment(current_environment_name)

      dns.update_endpoint next_environment[:name]
    end

    def update_environment_endpoint(name)
      current_environment = find_environment(name)

      dns.update_endpoint current_environment[:name]
    end

    def warm_environment(name)
      current_environment = find_environment(name)
      warm current_environment[:uri]
    end

    def stack_version
      eb.version current_environment_name
    end

    def environment_version(name)
      current_environment = find_environment(name)
      eb.version current_environment[:name]
    end

    def mark_stack_version
      newrelic.mark_deployment stack_version
    end

    def mark_environment_version(name)
      newrelic.mark_deployment environment_version(name)
    end

    def start_stack
      environment.eb_config[:environments].each { |e|
        start_environment e[:name]
      }
    end

    def start_environment(name)
      current_environment = find_environment(name)
      eb.start current_environment[:name]
    end

    def stop_stack
      environment.eb_config[:environments].each { |e|
        stop_environment e[:name]
      }
    end

    def stop_environment(name)
      current_environment = find_environment(name)
      eb.stop current_environment[:name]
    end

    private

    attr_reader :environment, :version_control, :eb, :dns, :logger, :newrelic

    def current_environment_name
      @current_environment_name ||= website(environment.dns_config[:endpoint]).current_environment
    end

    def deploy(name, uri)
      version_control.push_latest_version name
      eb.wait_for_environment name, current_time
      warm uri
    end

    def warm(uri)
      website(uri).warm
    end

    def find_environment(name)
      environment.find_environment(name).tap { |env|
        raise "Could not find environment with name '#{name}'" unless env
      }
    end

    def log_success(name, uri)
      logger.info("Successfully deployed to environment '#{name}' with URL '#{uri}'")
    end

    def current_time
      Time.now.utc.iso8601
    end

    def website(uri)
      Mist::Website.new(uri: uri)
    end
  end
end
