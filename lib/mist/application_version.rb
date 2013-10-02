module Mist
  class ApplicationVersion
    attr_reader :version_control, :sha, :stamp

    def initialize(options = {})
      version = options[:version]
      values = parse_values(version)

      @version_control = values[0]
      @sha = values[1]
      @stamp = values[2]
    end

    private

    def parse_values(version)
      unless version
        raise 'The specified version is invalid.'
      end

      version.split('-').tap { |values|
        unless values.length == 3
          raise "The specified version '#{version}' is invalid."
        end
      }
    end
  end
end
