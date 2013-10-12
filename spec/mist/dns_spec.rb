require 'spec_helper'

describe Mist::Dns do
  let(:environment) { Spec.environment }
  let(:options) {
    {
      hosted_zone_id: 'id',
      change_batch: {
        comment: "Changing host from 'test-QA-A' to 'test-QA-B'",
        changes: [
          {
            action: 'DELETE',
            resource_record_set:
              {
                name: 'qa.test.com.',
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  { value: 'testqaa.com' }
                ]
              }
          },
          {
            action: 'CREATE',
            resource_record_set:
              {
                name: 'qa.test.com.',
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  { value: 'testqab.com' }
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
             list_hosted_zones: { hosted_zones: [
               { id: 'id', name: 'test.com.' }
             ] },
             change_resource_record_sets: nil
      )
    }
    Given(:aws_route53) { double('AWS::Route53', client: aws_route53_client) }
    Given(:dns) { Mist::Dns.new(environment: environment, dns: aws_route53) }
    When(:result) { dns.update_endpoint('test-QA-B') }
    Then { expect(aws_route53_client).to have_received(:change_resource_record_sets).with(options) }
  end
end
