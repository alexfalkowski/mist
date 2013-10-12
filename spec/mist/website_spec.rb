require 'spec_helper'

describe Mist::Website do
  let(:uri) { 'https://test.com' }

  context 'with credentials' do
    let(:environment) { Spec.environment }

    context 'successful warm up' do
      Given(:system_command) { double('SystemCommand', run_command_with_output: '200') }
      Given(:website) {
        Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
      }
      When { website.warm }
      Then {
        expect(system_command).to have_received(:run_command_with_output).
                                    with('curl',
                                         '--connect-timeout 300',
                                         '--insecure',
                                         "-u 'test_username:test_password'",
                                         "--write-out '%{http_code}'",
                                         '--silent',
                                         '--output /dev/null',
                                         "'https://test.com'").exactly(20).times
      }
    end

    context 'unsuccessful warm up' do
      Given(:system_command) { double('SystemCommand', run_command_with_output: '500') }
      Given(:website) {
        Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
      }
      When(:result) { website.warm }
      Then {
        result == Failure(RuntimeError, "Could not warm up website on URL 'https://test.com' as we got a status code of '500'")
      }
    end

    context 'current environment' do
      context 'has X-Environment-Name' do
        Given(:headers) {
          %q[
HTTP/1.1 200 OK
Cache-Control: must-revalidate, private, max-age=0
Content-length: 46218
Content-Type: text/html; charset=utf-8
Date: Sun, 29 Sep 2013 14:45:08 GMT
ETag: "ff31791c169e360e4676ce0a4156a6ea"
Status: 200
Strict-Transport-Security: max-age=31536000
X-Environment-Name: test-QA-A
X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.17
X-Rack-Cache: miss
X-Request-Id: f3623a2fa01385549d2e7a1a239ff5aa
X-Runtime: 0.392968
X-UA-Compatible: IE=Edge,chrome=1
Connection: keep-alive
        ]
        }
        Given(:system_command) { double('SystemCommand', run_command_with_output: headers.lstrip) }
        Given(:website) {
          Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
        }
        When(:current_environment) { website.current_environment }
        Then {
          expect(system_command).to have_received(:run_command_with_output).
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           "-u 'test_username:test_password'",
                                           '--silent',
                                           "-I 'https://test.com'")
        }
        Then { expect(current_environment).to eq('test-QA-A') }
      end

      context 'does not have X-Environment-Name' do
        Given(:headers) { '' }
        Given(:system_command) { double('SystemCommand', run_command_with_output: headers) }
        Given(:website) {
          Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
        }
        When(:current_environment) { website.current_environment }
        Then {
          expect(system_command).to have_received(:run_command_with_output).
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           "-u 'test_username:test_password'",
                                           '--silent',
                                           "-I 'https://test.com'")
        }
        Then {
          current_environment == Failure(RuntimeError, "Could not find the current environment in 'X-Environment-Name'")
        }
      end
    end
  end

  context 'without credentials' do
    let(:environment) { Spec.environment('live') }

    context 'successful warm up' do
      Given(:system_command) { double('SystemCommand', run_command_with_output: '200') }
      Given(:website) {
        Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
      }
      When { website.warm }
      Then {
        expect(system_command).to have_received(:run_command_with_output).
                                    with('curl',
                                         '--connect-timeout 300',
                                         '--insecure',
                                         '',
                                         "--write-out '%{http_code}'",
                                         '--silent',
                                         '--output /dev/null',
                                         "'https://test.com'").exactly(20).times
      }
    end

    context 'unsuccessful warm up' do
      Given(:system_command) { double('SystemCommand', run_command_with_output: '500') }
      Given(:website) {
        Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
      }
      When(:result) { website.warm }
      Then {
        result == Failure(RuntimeError, "Could not warm up website on URL 'https://test.com' as we got a status code of '500'")
      }
    end

    context 'current environment' do
      context 'has X-Environment-Name' do
        Given(:headers) {
          %q[
HTTP/1.1 200 OK
Cache-Control: must-revalidate, private, max-age=0
Content-length: 46218
Content-Type: text/html; charset=utf-8
Date: Sun, 29 Sep 2013 14:45:08 GMT
ETag: "ff31791c169e360e4676ce0a4156a6ea"
Status: 200
Strict-Transport-Security: max-age=31536000
X-Environment-Name: test-QA-A
X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.17
X-Rack-Cache: miss
X-Request-Id: f3623a2fa01385549d2e7a1a239ff5aa
X-Runtime: 0.392968
X-UA-Compatible: IE=Edge,chrome=1
Connection: keep-alive
        ]
        }
        Given(:system_command) { double('SystemCommand', run_command_with_output: headers.lstrip) }
        Given(:website) {
          Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
        }
        When(:current_environment) { website.current_environment }
        Then {
          expect(system_command).to have_received(:run_command_with_output).
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           '',
                                           '--silent',
                                           "-I 'https://test.com'")
        }
        Then { expect(current_environment).to eq('test-QA-A') }
      end

      context 'does not have X-Environment-Name' do
        Given(:headers) { '' }
        Given(:system_command) { double('SystemCommand', run_command_with_output: headers) }
        Given(:website) {
          Mist::Website.new(environment: environment, uri: uri, system_command: system_command)
        }
        When(:current_environment) { website.current_environment }
        Then {
          expect(system_command).to have_received(:run_command_with_output).
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           '',
                                           '--silent',
                                           "-I 'https://test.com'")
        }
        Then {
          current_environment == Failure(RuntimeError, "Could not find the current environment in 'X-Environment-Name'")
        }
      end
    end
  end
end
