module Mist
  class Website
    ENVIRONMENT_NAME_HEADER = 'X-Environment-Name'

    attr_reader :uri, :command

    def initialize(uri, command = SystemCommand.new)
      @uri = URI.parse(uri)
      @command = command
    end

    def warm
      Mist.logger.info("About to warm up the the website at URL '#{uri}'")

      (1..20).each {
        curl_command = "curl --connect-timeout 300 --digest -u 'pinchmebeta:pinchmenyc' --write-out '%{http_code}' --silent --output /dev/null '#{uri}'"
        status_code = command.run_command_with_output(curl_command)

        raise "Could not warm up website on URL '#{uri}' as we got a status code of '#{status_code}'" unless status_code == '200'
      }

      Mist.logger.info("Successfully warmed up website at URL '#{uri}'")
    end

    def current_environment
      environment = headers.split(/\r?\n/).select { |line| line.start_with?(ENVIRONMENT_NAME_HEADER)}.first

      unless environment
        raise "Could not find the current environment in '#{ENVIRONMENT_NAME_HEADER}'"
      end

      environment.split(':').last.strip
    end

    private

    def headers
      curl_command = "curl --connect-timeout 300 --silent -I '#{uri}'"
      command.run_command_with_output(curl_command)
    end
  end
end
