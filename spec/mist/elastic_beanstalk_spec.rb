require 'spec_helper'

describe Mist::ElasticBeanstalk do
  let(:variables) {
    {
        aws: {
            access_key_id: 'access_key_id',
            secret_key: 'secret_key',

            eb: {
                application_name: 'application_name',
                dev_tools_endpoint: 'dev_tools_endpoint',
                environments: [
                    {name: 'environment-1'},
                    {name: 'environment-2'},
                ],
                region: 'region'
            }
        }
    }
  }

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
