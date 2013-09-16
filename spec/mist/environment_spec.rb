require 'spec_helper'

describe Mist::Environment do
  context 'with environment variables set' do
    Given { ENV['AWS_ACCESS_KEY_ID'] = 'AWS_ACCESS_KEY_ID' }
    Given { ENV['AWS_SECRET_KEY'] = 'AWS_ACCESS_KEY_ID' }
    When(:environment) { Mist::Environment.new('qa') }
    Then { environment != Failure(RuntimeError) }
    Then { environment.variables[:aws][:access_key_id] ==  'AWS_ACCESS_KEY_ID'}
    Then { environment.variables[:aws][:secret_key] ==  'AWS_ACCESS_KEY_ID'}
  end

  context 'without environment variables set' do
    context 'without AWS_ACCESS_KEY_ID variable' do
      Given { ENV['AWS_ACCESS_KEY_ID'] = nil }
      When(:environment) { Mist::Environment.new('qa') }
      Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_ACCESS_KEY_ID') }
    end

    context 'without AWS_SECRET_KEY variable' do
      Given { ENV['AWS_ACCESS_KEY_ID'] = 'ACCESS_KEY_ID' }
      Given { ENV['AWS_SECRET_KEY'] = nil }
      When(:environment) { Mist::Environment.new('qa') }
      Then { environment == Failure(RuntimeError, 'Please specify the environment variable AWS_SECRET_KEY') }
    end
  end
end
