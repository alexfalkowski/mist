module Mist
  class Application < Thor
    desc 'deploy', 'The mist deployment tool.'
    method_option :stack, aliases: '-s', desc: 'Deploy a stack, e.g QA|UAT|LIVE', default: 'QA'
    def deploy
      deployment(options.stack).deploy_latest
    end

    private

    def deployment(stack)
      @deployment ||= Mist::Deployment.new({stack: stack})
    end
  end
end
