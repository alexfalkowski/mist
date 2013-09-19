module Mist
  class Dns
    attr_reader :environment, :dns, :logger

    def initialize(environment, dns = nil, logger = Mist.logger)
      @environment = environment
      @dns = dns || AWS::Route53.new(access_key_id: environment.dns_config[:access_key_id],
                                     secret_access_key: environment.dns_config[:secret_key])
      @logger = logger
    end

    def update_endpoint(environment_name)
      current_environment = environment.find_other_environment(environment_name)
      other_environment = environment.find_environment(environment_name)

      options = {
          hosted_zone_id: zone[:id],
          change_batch: {
              comment: "Changing host from '#{current_environment[:name]}' to '#{other_environment[:name]}'",
              changes: [
                  {
                      action: 'DELETE',
                      resource_record_set: {
                          name: environment.dns_config[:domain],
                          type: 'CNAME',
                          ttl: 300,
                          resource_records: [{value: strip_protocol(current_environment[:uri])}]
                      }
                  },
                  {
                      action: 'CREATE',
                      resource_record_set: {
                          name: environment.dns_config[:domain],
                          type: 'CNAME',
                          ttl: 300,
                          resource_records: [{value: strip_protocol(other_environment[:uri])}]
                      }
                  }
              ]
          }
      }

      dns.client.change_resource_record_sets(options)
      logger.info("Changed host from '#{current_environment[:name]}' to '#{other_environment[:name]}'")
    end

    private

    def zone
      dns.client.list_hosted_zones[:hosted_zones].select { |z|
        z[:name] == environment.dns_config[:hosted_zone]
      }.first
    end

    def strip_protocol(url)
      url.sub!(/https\:\/\//, '') if url.include?('https://')
      url.sub!(/http\:\/\//, '') if url.include?('http://')

      url
    end
  end
end
