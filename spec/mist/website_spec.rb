require 'spec_helper'

describe Mist::Website do
  let(:uri) { 'http://test.com' }

  context 'successful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '200') }
    Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
    When { website.warm }
    Then {
      expect(system_command).to have_received(:run_command_with_output).
                                    with('curl',
                                         '--connect-timeout 300',
                                         '--digest',
                                         "-u 'pinchmebeta:pinchmenyc'",
                                         "--write-out '%{http_code}'",
                                         '--silent',
                                         '--output /dev/null',
                                         "'http://test.com'").exactly(20).times
    }
  end

  context 'unsuccessful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '500') }
    Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
    When(:result) { website.warm }
    Then {
      result == Failure(RuntimeError, "Could not warm up website on URL 'http://test.com' as we got a status code of '500'")
    }
  end

  context 'current environment' do
    context 'has X-Environment-Name' do
      Given(:headers) {
        %q[
HTTP/1.1 401 Unauthorized
Cache-Control: no-cache
Content-Type: text/html; charset=utf-8
Date: Wed, 18 Sep 2013 19:53:57 GMT
Server: nginx/1.2.3 + Phusion Passenger 3.0.17 (mod_rails/mod_rack)
Status: 401
WWW-Authenticate: Digest realm="Application", qop="auth", algorithm=MD5, nonce="MTM3OTUzNDAzNzphZWUxNzkyMjJhMjAzYjgxNzM0YTY5ZGMwMTY4ZGQ2NA==", opaque="dc6407147ba394856230f1fd3447c7fc"
X-Environment-Name: PINCHme-US-QA-A
X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.17
X-Rack-Cache: miss
X-Request-Id: eb5a13eea71107cbe319431d42cd3380
X-Runtime: 0.005832
X-UA-Compatible: IE=Edge,chrome=1
Connection: keep-alive
        ]
      }
      Given(:system_command) { double('SystemCommand', run_command_with_output: headers.lstrip) }
      Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
      When(:current_environment) { website.current_environment }
      Then {
        expect(system_command).to have_received(:run_command_with_output).
                                      with('curl', '--connect-timeout 300', '--silent', "-I 'http://test.com'")
      }
      Then { expect(current_environment).to eq('PINCHme-US-QA-A')}
    end

    context 'does not have X-Environment-Name' do
      Given(:headers) { '' }
      Given(:system_command) { double('SystemCommand', run_command_with_output: headers) }
      Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
      When(:current_environment) { website.current_environment }
      Then {
        expect(system_command).to have_received(:run_command_with_output).
                                      with('curl', '--connect-timeout 300', '--silent', "-I 'http://test.com'")
      }
      Then {
        current_environment == Failure(RuntimeError, "Could not find the current environment in 'X-Environment-Name'")
      }
    end
  end
end
