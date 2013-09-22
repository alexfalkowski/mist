require 'spec_helper'

describe Mist::ElasticBeanstalk do
  let(:environment) { Spec.environment }

  context 'Waiting for the environment' do
    context 'failure event' do
      Given(:aws_eb_client) { double('AWS::Client',
                                     describe_events: {
                                         events: [
                                             {severity: 'ERROR', message: 'Failed to deploy application.'}
                                         ]
                                     })
      }
      Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
      Given(:eb) { Mist::ElasticBeanstalk.new(environment: environment, beanstalk: aws_eb) }
      When(:result) { eb.wait_for_environment('TEST-ENV', Time.now.utc.iso8601) }
      Then {
        result == Failure(RuntimeError, 'There was an error with elastic beanstalk, please consult the logs.')
      }
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
      Given(:eb) { Mist::ElasticBeanstalk.new(environment: environment, beanstalk: aws_eb) }
      When(:result) { eb.wait_for_environment('TEST-ENV', Time.now.utc.iso8601) }
      Then {
        result != Failure(RuntimeError)
      }
    end
  end

  context 'Version' do
    Given(:aws_eb_client) { double('AWS::Client',
                                   describe_environments: {environments: [{version_label: '1.1'}]})
    }
    Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
    Given(:eb) { Mist::ElasticBeanstalk.new(environment: environment, beanstalk: aws_eb) }
    When(:result) { eb.version('test') }
    Then {
      expect(aws_eb_client).to have_received(:describe_environments).with(application_name: 'PINCHme-US',
                                                                          environment_names: %w(test))
    }
    Then { result == '1.1' }
  end
end
