module Mist
  class Dns
    attr_reader :env_variables, :dns

    def initialize(env_variables, dns = nil)
      @env_variables = env_variables
      @dns = dns || AWS::Route53.new(access_key_id: dns_config[:access_key_id],
                                     secret_access_key: dns_config[:secret_key])
    end

    def update_endpoint(environment_name)
      current_environment = eb_config[:environments].select { |e| e[:name] != environment_name }.first
      other_environment = eb_config[:environments].select { |e| e[:name] == environment_name }.first

      options = {
          hosted_zone_id: zone[:id],
          change_batch: {
              comment: "Changing host from '#{current_environment[:name]}' to '#{other_environment[:name]}'",
              changes: [
                  {
                      action: 'DELETE',
                      resource_record_set: {
                          name: dns_config[:domain],
                          type: 'CNAME',
                          ttl: 300,
                          resource_records: [ {value: strip_protocol(current_environment[:uri])} ]
                      }
                  },
                  {
                      action: 'CREATE',
                      resource_record_set: {
                          name: dns_config[:domain],
                          type: 'CNAME',
                          ttl: 300,
                          resource_records: [ {value: strip_protocol(other_environment[:uri])} ]
                      }
                  }
              ]
          }
      }

      dns.client.change_resource_record_sets(options)
      Mist.logger.info("Changed host from '#{current_environment[:name]}' to '#{other_environment[:name]}'")
    end

    private

    def zone
      dns.client.list_hosted_zones[:hosted_zones].select { |z| z[:name] == dns_config[:hosted_zone] }.first
    end

    def eb_config
      env_variables[:aws][:eb]
    end

    def dns_config
      env_variables[:aws][:dns]
    end

    def strip_protocol(url)
      url.sub!(/https\:\/\//, '') if url.include?('https://')
      url.sub!(/http\:\/\//, '') if url.include?('http://')

      url
    end
  end
end
