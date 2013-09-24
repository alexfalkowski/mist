require 'spec_helper'

describe Mist::GitHub do
  context 'set up' do
    context 'by key name' do
      context 'adds a github key' do
        Given(:access_token) { 'access_token' }
        Given(:email) { 'test@test.com' }
        Given(:client) {
          double('Octokit::Client', keys: [{title: 'donkey', key: 'donkey'}], add_key: nil)
        }
        Given(:ssh_key) { double('Mist::SshKey', value: 'test alexrfalkowski@gmail.com') }
        Given(:github) {
          Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
        }
        When(:value) { github.register_deployment_key }
        Then {
          expect(client).to have_received(:add_key).with('PINCHme US Deployment', 'test alexrfalkowski@gmail.com')
        }
      end

      context 'does not add a github key' do
        Given(:access_token) { 'access_token' }
        Given(:email) { 'test@test.com' }
        Given(:client) {
          double('Octokit::Client', keys: [{title: 'PINCHme US Deployment', key: 'donkey'}], add_key: nil)
        }
        Given(:ssh_key) { double('Mist::SshKey', value: 'test alexrfalkowski@gmail.com') }
        Given(:github) {
          Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
        }
        When(:value) { github.register_deployment_key }
        Then {
          expect(client).to_not have_received(:add_key).with('PINCHme US Deployment', 'test alexrfalkowski@gmail.com')
        }
      end
    end

    context 'by key value' do
      context 'does not add a github key' do
        Given(:access_token) { 'access_token' }
        Given(:email) { 'test@test.com' }
        Given(:client) {
          double('Octokit::Client', keys: [{title: 'PINCHme', key: 'test'}], add_key: nil)
        }
        Given(:ssh_key) { double('Mist::SshKey', value: 'test alexrfalkowski@gmail.com') }
        Given(:github) {
          Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
        }
        When(:value) { github.register_deployment_key }
        Then {
          expect(client).to_not have_received(:add_key).with('PINCHme US Deployment', 'test alexrfalkowski@gmail.com')
        }
      end
    end
  end

  context 'clean up' do
    context 'removes a github key' do
      Given(:access_token) { 'access_token' }
      Given(:email) { 'test@test.com' }
      Given(:client) {
        double('Octokit::Client', keys: [{id: 1, title: 'PINCHme US Deployment'}], remove_key: nil)
      }
      Given(:ssh_key) { double('Mist::SshKey', value: 'test alexrfalkowski@gmail.com') }
      Given(:github) {
        Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
      }
      When(:value) { github.unregister_deployment_key }
      Then {
        expect(client).to have_received(:remove_key).with(1)
      }
    end

    context 'does not remove a github key' do
      Given(:access_token) { 'access_token' }
      Given(:email) { 'test@test.com' }
      Given(:client) {
        double('Octokit::Client', keys: [{id: 1, title: 'donkey'}], remove_key: nil)
      }
      Given(:ssh_key) { double('Mist::SshKey', value: 'test') }
      Given(:github) {
        Mist::GitHub.new(access_token: access_token, email: email, client: client, ssh_key: ssh_key)
      }
      When(:value) { github.unregister_deployment_key }
      Then {
        expect(client).to_not have_received(:remove_key).with(1)
      }
    end
  end
end
