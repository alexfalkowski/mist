module Mist
  class ElasticBeanstalk
    def initialize(environment, beanstalk = nil, logger = Mist.logger)
      @environment = environment
      @beanstalk = beanstalk || AWS::ElasticBeanstalk.new(access_key_id: environment.eb_config[:access_key_id],
                                                          secret_access_key: environment.eb_config[:secret_key])
      @logger = logger
    end

    def wait_for_environment(environment, deploy_date)
      options = {
          environment_name: environment,
          start_time: deploy_date
      }

      logger.info("Sending elastic beanstalk the following information '#{options}'")

      while (result = validate_events(beanstalk.client.describe_events(options)[:events])) == :continue
        logger.info('Waiting for elastic beanstalk to indicate whether the deployment is a success or failure, will wait for 10 seconds.')
        sleep 10
      end

      result
    end

    private

    attr_reader :environment, :beanstalk, :logger

    def validate_events(events)
      errors = events.select { |e| e[:severity] == 'ERROR' }

      if errors.count == 0
        successful = events.select { |e| e[:message] == 'Environment update completed successfully.' }

        if successful.count == 1
          :success
        else
          :continue
        end
      else
        :failure
      end
    end
  end
end
