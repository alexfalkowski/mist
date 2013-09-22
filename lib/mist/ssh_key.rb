module Mist
  class SshKey
    def initialize(options = {})
      @email = options[:email]
      @home_path = options.fetch(:home_path, Dir.home)
      @file = options.fetch(:file, File)
      @system_command = options.fetch(:system_command) { SystemCommand.new }

      generate_key unless file.exists?(path)
    end

    def value
      file.read(path)
    end

    private

    attr_reader :email, :home_path, :file, :system_command

    def generate_key
      system_command.run_command('ssh-keygen', '-q', '-t rsa', "-C #{email}", "-N ''", "-f #{path}")
    end

    def path
      @path ||= file.join(home_path, '/.ssh/id_rsa.pub')
    end
  end
end
