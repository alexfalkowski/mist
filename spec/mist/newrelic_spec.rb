require 'spec_helper'

describe Mist::Newrelic do
  let(:environment) { Spec.environment }

  context 'mark a deployment' do
    Given(:newrelic) { double('NewRelicApi', :api_key= => nil) }
    Given(:newrelic_deployment) { double('NewRelicApi::Deployment', create: nil) }
    Given(:nr) {
      Mist::Newrelic.new(environment: environment,
                         newrelic: newrelic,
                         newrelic_deployment: newrelic_deployment,
                         login_name: 'username')
    }
    When { nr.mark_deployment('1.0') }
    Then { expect(newrelic).to have_received(:api_key=).with('NEWRELIC_API_KEY') }
    Then {
      expect(newrelic_deployment).to have_received(:create).with(
                                       {
                                         app_name: 'PINCHme-US-QA',
                                         description: "Updating application 'PINCHme-US-QA' with version '1.0'",
                                         user: 'username',
                                         revision: '1.0'
                                       })
    }
  end
end
