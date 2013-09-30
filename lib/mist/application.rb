module Mist
  class Application < Thor
    class << self
      def stack_alias
        '-s'
      end

      def stack_message
        'Deploy a stack, e.g QA|UAT|LIVE'
      end

      def environment_message
        'Deploy an environment, e.g PINCHme-US-QA-A|PINCHme-US-QA-B'
      end

      def environment_alias
        '-e'
      end
    end

    desc 'deploy', 'Deploy a specific stack or an environment within a stack.'
    method_option :stack, aliases: stack_alias, desc: stack_message, required: true
    method_option :environment, aliases: environment_alias, desc: environment_message
    def deploy
      deployment = deployment(options.stack)

      if options.environment?
        deployment.deploy_latest_to_environment options.environment
      else
        deployment.deploy_latest_to_stack
      end
    end

    desc 'swap', 'Swaps the DNS endpoint.'
    method_option :stack, aliases: stack_alias, desc: stack_message, required: true
    method_option :environment, aliases: environment_alias, desc: environment_message, required: true
    def swap
      deployment = deployment(options.stack)

      if options.environment?
        deployment.update_environment_endpoint options.environment
      else
        deployment.update_stack_endpoint
      end
    end

    desc 'warm', 'Warms a specific environment.'
    method_option :stack, aliases: stack_alias, desc: stack_message, required: true
    method_option :environment, aliases: environment_alias, desc: environment_message, required: true
    def warm
      deployment = deployment(options.stack)
      deployment.warm_environment options.environment
    end

    desc 'version', 'The version of specific stack or an environment within a stack.'
    method_option :stack, aliases: stack_alias, desc: stack_message, required: true
    method_option :environment, aliases: environment_alias, desc: environment_message
    def version
      deployment = deployment(options.stack)

      if options.environment?
        deployment.environment_version options.environment
      else
        deployment.stack_version
      end
    end

    desc 'mark', 'Mark a version with newrelic of a specific stack or an environment within a stack.'
    method_option :stack, aliases: stack_alias, desc: stack_message, required: true
    method_option :environment, aliases: environment_alias, desc: environment_message
    def mark
      deployment = deployment(options.stack)

      if options.environment?
        deployment.mark_environment_version options.environment
      else
        deployment.mark_stack_version
      end
    end

    desc 'setup', 'Setup the mist.'
    method_option :email, desc: 'Your email address.', required: true
    def setup
      prerequisites(options.email).setup
    end

    desc 'cleanup', 'Cleanup the mist.'
    def cleanup
      prerequisites.cleanup
    end

    private

    def deployment(stack)
      @deployment ||= Mist::Deployment.new(stack: stack)
    end

    def prerequisites(email = nil)
      @prerequisites ||= Mist::Prerequisites.new(email: email)
    end
  end
end
