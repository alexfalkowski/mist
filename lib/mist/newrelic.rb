module Mist
  class Newrelic
    def initialize(options = {})
      @environment = options[:environment]
      @logger = options.fetch(:logger, Mist.logger)
      @newrelic = options.fetch(:newrelic, NewRelicApi)
      @newrelic_deployment = options.fetch(:newrelic_deployment, NewRelicApi::Deployment)
      @login_name = options.fetch(:login_name) { Etc.getlogin }

      newrelic.api_key = environment.newrelic_config[:api_key]
    end

    def mark_deployment(version)
      application_name = environment.newrelic_config[:application_name]
      description = "Updating application '#{application_name}' with version '#{version}'"

      newrelic_deployment.create app_name: environment.newrelic_config[:application_name],
                                 description: description,
                                 user: login_name,
                                 revision: version

      logger.info("Successfully updated application '#{application_name}' with version '#{version}'")
    end

    private

    attr_reader :environment, :logger, :newrelic, :newrelic_deployment, :login_name
  end
end
