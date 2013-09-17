require 'spec_helper'

describe Mist::Website do
  let(:uri) { 'http://test.com' }

  context 'successful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '200') }
    Given(:website) { Mist::Website.new(uri, system_command) }
    When { website.warm }
    Then {
      expect(system_command).to have_received(:run_command_with_output).
                                    with("curl --connect-timeout 300 --digest -u 'pinchmebeta:pinchmenyc' --write-out '%{http_code}' --silent --output /dev/null 'http://test.com'").
                                    exactly(20).times
    }
  end

  context 'unsuccessful warm up' do
    Given(:system_command) { double('SystemCommand', run_command_with_output: '500') }
    Given(:website) { Mist::Website.new(uri, system_command) }
    When(:result) { website.warm }
    Then {
      result == Failure(RuntimeError, "Could not warm up website on URL 'http://test.com' as we got a status code of '500'")
    }
  end
end
