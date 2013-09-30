require 'spec_helper'

describe Mist::Website do
  let(:uri) { 'https://test.com' }

  context 'successful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '200') }
    Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
    When { website.warm }
    Then {
      expect(system_command).to have_received(:run_command_with_output).
                                    with('curl',
                                         '--connect-timeout 300',
                                         '--insecure',
                                         "-u 'pinchmebeta:pinchmenyc'",
                                         "--write-out '%{http_code}'",
                                         '--silent',
                                         '--output /dev/null',
                                         "'https://test.com'").exactly(20).times
    }
  end

  context 'unsuccessful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '500') }
    Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
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
Server: nginx/1.2.3 + Phusion Passenger 3.0.17 (mod_rails/mod_rack)
Set-Cookie: _PinchMe_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFRkkiJTVkZjcxODFiZWEyOTczYzUwOTI5MjQxNjQxYjRiMDQyBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMVhhM1BXVUVSL1V1Sk9XalNHRllxK0xqM1lvSThpbXFLNVNnMmo4bTFlRnc9BjsARg%3D%3D--c51a2e45c089a3bc18d926d3c18225dff9a3afb5; path=/; secure; HttpOnly
Status: 200
Strict-Transport-Security: max-age=31536000
X-Environment-Name: PINCHme-US-QA-A
X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.17
X-Rack-Cache: miss
X-Request-Id: f3623a2fa01385549d2e7a1a239ff5aa
X-Runtime: 0.392968
X-UA-Compatible: IE=Edge,chrome=1
Connection: keep-alive
        ]
      }
      Given(:system_command) { double('SystemCommand', run_command_with_output: headers.lstrip) }
      Given(:website) { Mist::Website.new(uri: uri, system_command: system_command) }
      When(:current_environment) { website.current_environment }
      Then {
        expect(system_command).to have_received(:run_command_with_output).
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           "-u 'pinchmebeta:pinchmenyc'",
                                           '--silent',
                                           "-I 'https://test.com'")
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
                                      with('curl',
                                           '--connect-timeout 300',
                                           '--insecure',
                                           "-u 'pinchmebeta:pinchmenyc'",
                                           '--silent',
                                           "-I 'https://test.com'")
      }
      Then {
        current_environment == Failure(RuntimeError, "Could not find the current environment in 'X-Environment-Name'")
      }
    end
  end
end
