module Mist
  class ElasticBeanstalk
    def initialize(options = {})
      @environment = options[:environment]
      @beanstalk = options.fetch(:beanstalk) {
        AWS::ElasticBeanstalk.new(access_key_id: environment.eb_config[:access_key_id],
                                  secret_access_key: environment.eb_config[:secret_key])
      }
      @asg = options.fetch(:asg) {
        AWS::AutoScaling.new(access_key_id: environment.eb_config[:access_key_id],
                             secret_access_key: environment.eb_config[:secret_key])
      }
      @logger = options.fetch(:logger, Mist.logger)
    end

    def wait_for_environment(name, deploy_date)
      options = {
        environment_name: name,
        start_time: deploy_date
      }

      logger.info("Sending elastic beanstalk the following information '#{options}'")

      while (result = validate_events(beanstalk.client.describe_events(options)[:events])) == :continue
        logger.info('Waiting for elastic beanstalk to indicate whether the deployment is a success or failure, will wait for 10 seconds.')
        sleep 10
      end

      raise 'There was an error with elastic beanstalk, please consult the logs.' if result == :failure
    end

    def version(name)
      options = {
        application_name: environment.eb_config[:application_name],
        environment_names: [name]
      }

      beanstalk.client.describe_environments(options)[:environments].first[:version_label].tap { |version|
        logger.info("The current version for environment '#{name}' is '#{version}'")
      }
    end

    def start(name)
      options =  {
        min_size: 1,
        max_size: 4,
        desired_capacity: 1
      }

      update_auto_scaling_group name, options
      logger.info("Successfully started environment '#{name}'")
    end

    def stop(name)
      options = {
        min_size: 0,
        max_size: 0
      }

      update_auto_scaling_group name, options
      logger.info("Successfully stopped environment '#{name}'")
    end

    private

    attr_reader :environment, :beanstalk, :asg, :logger

    def update_auto_scaling_group(name, update_options)
      options = {
        environment_name: name,
      }

      resources = beanstalk.client.describe_environment_resources(options)[:environment_resources]
      auto_scaling_group = resources[:auto_scaling_groups].first

      if auto_scaling_group
        group = asg.groups[auto_scaling_group[:name]]
        group.update(update_options)
      end
    end

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
