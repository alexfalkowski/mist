module Mist
  class SshKey
    def initialize(options = {})
      @email = options[:email]
      @home_path = options.fetch(:home_path, Dir.home)
      @file = options.fetch(:file, File)
      @system_command = options.fetch(:system_command) { SystemCommand.new }
    end

    def value
      generate_key unless file.exists?(ssh_public_key_path)
      @value ||= file.read(ssh_public_key_path)
    end

    private

    attr_reader :email, :home_path, :file, :system_command

    def generate_key
      system_command.run_command('ssh-keygen', '-q', '-t rsa', "-C #{email}", "-N ''", "-f #{ssh_private_key_path}")
    end

    def ssh_public_key_path
      @ssh_public_key_path ||= file.join(home_path, '/.ssh/id_rsa.pub')
    end

    def ssh_private_key_path
      @ssh_private_key_path ||= file.join(home_path, '/.ssh/id_rsa')
    end
  end
end
