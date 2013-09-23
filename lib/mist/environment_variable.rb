module Mist
  class EnvironmentVariable
    def initialize(key)
      @key = key
      raise error_message(key) unless value
    end

    def value
      ENV[key]
    end

    private

    attr_reader :key

    def error_message(variable)
      "Please specify the environment variable #{variable}"
    end
  end
end
