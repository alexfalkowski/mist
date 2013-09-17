module Mist
  class Website
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
  end
end
