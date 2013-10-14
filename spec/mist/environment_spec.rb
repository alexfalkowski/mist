require 'spec_helper'

describe Mist::Environment do
  context 'APP environment' do
    context 'with environment variables set' do
      Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
      Then { environment != Failure(RuntimeError) }
      Then { environment.eb_config[:access_key_id] == 'AWS_ACCESS_KEY_ID' }
      Then { environment.eb_config[:secret_key] == 'AWS_ACCESS_KEY_ID' }
      Then { environment.eb_config[:application_name] == 'test' }
      Then { environment.eb_config[:dev_tools_endpoint] == 'git.elasticbeanstalk.us-east-1.amazonaws.com' }
      Then { environment.eb_config[:environments] == [
        { name: 'test-QA-A',  uri: 'https://testqaa.com' },
        { name: 'test-QA-B', uri: 'https://testqab.com' }]
      }
      Then { environment.eb_config[:region] == 'us-east-1' }
      Then { environment.git_config[:repository_name] == 'test' }
      Then { environment.git_config[:repository_uri] == 'git@test/test.git' }
      Then { environment.git_config[:local_path] == '/tmp' }
    end

    context 'without environment variables set' do
      context 'without AWS_APP_ACCESS_KEY_ID variable' do
        Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = nil }
        When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
        Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_APP_ACCESS_KEY_ID') }
      end

      context 'without AWS_APP_SECRET_KEY variable' do
        Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = nil }
        When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
        Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_APP_SECRET_KEY') }
      end
    end
  end

  context 'DNS environment' do
    context 'with environment variables set' do
      Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
      Then { environment != Failure(RuntimeError) }
      Then { environment.dns_config[:access_key_id] == 'AWS_ACCESS_KEY_ID' }
      Then { environment.dns_config[:secret_key] == 'AWS_ACCESS_KEY_ID' }
      Then { environment.dns_config[:domain] == 'qa.test.com.' }
      Then { environment.dns_config[:hosted_zone] == 'test.com.' }
      Then { environment.dns_config[:endpoint] == 'https://qa.test.com' }
    end

    context 'without environment variables set' do
      context 'without AWS_DNS_ACCESS_KEY_ID variable' do
        Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = nil }
        When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
        Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_DNS_ACCESS_KEY_ID') }
      end

      context 'without AWS_DNS_SECRET_KEY variable' do
        Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'ACCESS_KEY_ID' }
        Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = nil }
        When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
        Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_DNS_SECRET_KEY') }
      end
    end
  end

  context 'NEWRELIC environment' do
    context 'with environment variables set' do
      Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::NEWRELIC_API_KEY] = 'NEWRELIC_API_KEY' }
      When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
      Then { environment != Failure(RuntimeError) }
      Then { environment.newrelic_config[:api_key] == 'NEWRELIC_API_KEY' }
      Then { environment.newrelic_config[:application_name] == 'test-QA' }
    end

    context 'without environment variables set' do
      Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
      Given { ENV[Mist::Environment::NEWRELIC_API_KEY] = nil }
      When(:environment) { Mist::Environment.new(name: 'qa', path: CONFIG_PATH) }
      Then { environment == Failure(RuntimeError, 'Please specify the environment variable NEWRELIC_API_KEY') }
    end
  end

  context 'Non existent stack' do
    Given { ENV[Mist::Environment::AWS_APP_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
    Given { ENV[Mist::Environment::AWS_APP_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
    Given { ENV[Mist::Environment::AWS_DNS_ACCESS_KEY_ID] = 'AWS_ACCESS_KEY_ID' }
    Given { ENV[Mist::Environment::AWS_DNS_SECRET_KEY] = 'AWS_ACCESS_KEY_ID' }
    Given { ENV[Mist::Environment::NEWRELIC_API_KEY] = 'NEWRELIC_API_KEY' }
    Given(:environment) { Mist::Environment.new(name: 'donkey', path: CONFIG_PATH) }
    When(:access_key_id) { environment.eb_config[:access_key_id] }
    Then { access_key_id == Failure(RuntimeError, "The stack 'donkey' does not exist!") }
  end
end
