require 'spec_helper'

describe Mist::ElasticBeanstalk do
  let(:variables) { TestEnvironment.variables }

  context 'failure event' do
    Given(:aws_eb_client) { double('AWS::Client',
                                   describe_events: {
                                       events: [
                                           {severity: 'ERROR', message: 'Failed to deploy application.'}
                                       ]
                                   })
    }
    Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
    Given(:eb) { Mist::ElasticBeanstalk.new(variables, aws_eb) }
    When(:result) { eb.wait_for_environment('TEST-ENV', Time.now.utc.iso8601) }
    Then { result == :failure }
  end

  context 'success event' do
    Given(:aws_eb_client) { double('AWS::Client',
                                   describe_events: {
                                       events: [
                                           {severity: 'INFO', message: 'Environment update completed successfully.'}
                                       ]
                                   })
    }
    Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
    Given(:eb) { Mist::ElasticBeanstalk.new(variables, aws_eb) }
    When(:result) { eb.wait_for_environment('TEST-ENV', Time.now.utc.iso8601) }
    Then { result == :success }
  end
end
