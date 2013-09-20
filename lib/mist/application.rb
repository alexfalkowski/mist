module Mist
  class Application < Thor
    desc 'deploy', 'The mist deployment tool.'
    method_option :stack, aliases: '-s', desc: 'Deploy a stack, e.g QA|UAT|LIVE', default: 'QA'
    method_option :environment, aliases: '-e', desc: 'Deploy an environment, e.g PINCHme-US-QA-A|PINCHme-US-QA-B'
    def deploy
      deployment = deployment(options.stack)

      if options.environment?
        deployment.deploy_latest_to_environment options.environment
      else
        deployment.deploy_latest_to_stack
      end
    end

    desc 'swap', 'Swaps the DNS endpoint.'
    method_option :stack, aliases: '-s', desc: 'Deploy a stack, e.g QA|UAT|LIVE', default: 'QA'
    def swap
      deployment = deployment(options.stack)
      deployment.update_endpoint
    end

    private

    def deployment(stack)
      @deployment ||= Mist::Deployment.new({stack: stack})
    end
  end
end
