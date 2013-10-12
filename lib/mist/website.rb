module Mist
  class Website
    ENVIRONMENT_NAME_HEADER = 'X-Environment-Name'

    def initialize(options = {})
      @environment = options[:environment]
      @uri = URI.parse(options[:uri])
      @system_command = options.fetch(:system_command) { SystemCommand.new }
      @logger = options.fetch(:logger, Mist.logger)
    end

    def warm
      logger.info("About to warm up the the website at URL '#{uri}'")

      (1..20).each {
        status_code = system_command.run_command_with_output('curl',
                                                             '--connect-timeout 300',
                                                             '--insecure',
                                                             credentials_parameter,
                                                             "--write-out '%{http_code}'",
                                                             '--silent',
                                                             '--output /dev/null',
                                                             "'#{uri}'")

        redo if timeout?(status_code)
        raise "Could not warm up website on URL '#{uri}' as we got a status code of '#{status_code}'" unless status_code == '200'
      }

      logger.info("Successfully warmed up website at URL '#{uri}'")
    end

    def current_environment
      environment = headers.split(/\r?\n/).select { |line| line.start_with?(ENVIRONMENT_NAME_HEADER) }.first

      unless environment
        raise "Could not find the current environment in '#{ENVIRONMENT_NAME_HEADER}'"
      end

      environment.split(':').last.strip.tap { |env|
        logger.info("Current environment is '#{env}'")
      }
    end

    private

    attr_reader :environment, :uri, :system_command, :logger

    def timeout?(status_code)
      status_code == '000' || status_code == '408' || status_code == '504'
    end

    def headers
      system_command.run_command_with_output('curl',
                                             '--connect-timeout 300',
                                             '--insecure',
                                             credentials_parameter,
                                             '--silent',
                                             "-I '#{uri}'")
    end

    def credentials_parameter
      basic_auth = environment.basic_auth_config
      if basic_auth
        "-u '#{basic_auth[:username]}:#{basic_auth[:password]}'"
      else
        ''
      end
    end
  end
end
