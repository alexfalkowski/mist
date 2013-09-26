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

  context 'Start' do
    Given(:aws_eb_client) {
      double('AWS::Client',
             describe_environment_resources: {
               environment_resources: {
                 auto_scaling_groups: [
                   {name: 'group-name'}
                 ]
               }
             })
    }
    Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
    Given(:aws_asg) { double('AWS::AutoScaling::Group', update: nil) }
    Given(:aws_groups) { double('AWS::AutoScaling::GroupCollection') }
    Given { allow(aws_groups).to receive(:[]).with('group-name') { aws_asg } }
    Given(:aws_as) { double('AWS::AutoScaling', groups: aws_groups) }
    Given(:eb) {
      Mist::ElasticBeanstalk.new(environment: environment, beanstalk: aws_eb, asg: aws_as)
    }
    When(:result) { eb.start('test') }
    Then {
      expect(aws_asg).to have_received(:update).with(min_size: 1, max_size: 4, desired_capacity: 1)
    }
  end

  context 'Stop' do
    Given(:aws_eb_client) {
      double('AWS::Client',
             describe_environment_resources: {
               environment_resources: {
                 auto_scaling_groups: [
                   {name: 'group-name'}
                 ]
               }
             })
    }
    Given(:aws_eb) { double('AWS::ElasticBeanstalk', client: aws_eb_client) }
    Given(:aws_asg) { double('AWS::AutoScaling::Group', update: nil) }
    Given(:aws_groups) { double('AWS::AutoScaling::GroupCollection') }
    Given { allow(aws_groups).to receive(:[]).with('group-name') { aws_asg } }
    Given(:aws_as) { double('AWS::AutoScaling', groups: aws_groups) }
    Given(:eb) {
      Mist::ElasticBeanstalk.new(environment: environment, beanstalk: aws_eb, asg: aws_as)
    }
    When(:result) { eb.stop('test') }
    Then {
      expect(aws_asg).to have_received(:update).with(min_size: 0, max_size: 0)
    }
  end
end
