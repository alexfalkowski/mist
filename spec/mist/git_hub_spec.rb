require 'spec_helper'

describe Mist::GitHub do
  context 'adds a github key' do
    Given(:access_token) { 'access_token' }
    Given(:email) { 'test@test.com' }
    Given(:client) {
      double('Octokit::Client', keys: [ {title: 'donkey'} ], add_key: nil)
    }
    Given(:ssh_key) { double('Mist::SshKey', value: 'test') }
    Given(:github) {
      Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
    }
    When(:value) { github.register_deployment_key }
    Then {
      expect(client).to have_received(:add_key).with('PINCHme US Deployment', 'test')
    }
  end

  context 'does not add a github key' do
    Given(:access_token) { 'access_token' }
    Given(:email) { 'test@test.com' }
    Given(:client) {
      double('Octokit::Client', keys: [ {title: 'PINCHme US Deployment'} ], add_key: nil)
    }
    Given(:ssh_key) { double('Mist::SshKey', value: 'test') }
    Given(:github) {
      Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
    }
    When(:value) { github.register_deployment_key }
    Then {
      expect(client).to_not have_received(:add_key).with('PINCHme US Deployment', 'test')
    }
  end
end
