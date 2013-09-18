require 'spec_helper'

describe Mist::Dns do
  let(:variables) { TestEnvironment.variables }
  let(:options) {
    {
        hosted_zone_id: 'id',
        change_batch: {
            comment: "Changing host from 'PINCHme-US-QA-A' to 'PINCHme-US-QA-B'",
            changes: [
                {
                    action: 'DELETE',
                    resource_record_set:
                        {
                            name: 'qa.pinchme.com.',
                            type: 'CNAME',
                            ttl: 300,
                            resource_records: [
                                {value: 'pinchme-us-qa-a-jn9wvp4tew.elasticbeanstalk.com'}
                            ]
                        }
                },
                {
                    action: 'CREATE',
                    resource_record_set:
                        {
                            name: 'qa.pinchme.com.',
                            type: 'CNAME',
                            ttl: 300,
                            resource_records: [
                                {value: 'pinchme-us-qa-b-ghruzpydi6.elasticbeanstalk.com'}
                            ]
                        }
                }
            ]
        }
    }
  }

  context 'successful change' do
    Given(:aws_route53_client) {
      double('AWS::Client',
             list_hosted_zones: {hosted_zones: [
                 {id: 'id', name: 'pinchme.com.'}
             ]},
             change_resource_record_sets: nil
      )
    }
    Given(:aws_route53) { double('AWS::Route53', client: aws_route53_client) }
    Given(:dns) { Mist::Dns.new(variables, aws_route53) }
    When(:result) { dns.update_endpoint('PINCHme-US-QA-B') }
    Then { expect(aws_route53_client).to have_received(:change_resource_record_sets).with(options) }
  end
end
