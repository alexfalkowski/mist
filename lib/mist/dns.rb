module Mist
  class Dns
    def initialize(options = {})
      @environment = options[:environment]
      @dns = options.fetch(:dns) {
        AWS::Route53.new(access_key_id: environment.dns_config[:access_key_id],
                         secret_access_key: environment.dns_config[:secret_key])
      }
      @logger = options.fetch(:logger, Mist.logger)
    end

    def update_endpoint(environment_name)
      current_environment = environment.find_next_environment(environment_name)
      next_environment = environment.find_environment(environment_name)

      options = {
          hosted_zone_id: zone[:id],
          change_batch: {
              comment: "Changing host from '#{current_environment[:name]}' to '#{next_environment[:name]}'",
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
                          resource_records: [{value: strip_protocol(next_environment[:uri])}]
                      }
                  }
              ]
          }
      }

      response = dns.client.change_resource_record_sets(options)
      logger.info("Changed host from '#{current_environment[:name]}' to '#{next_environment[:name]}', with response '#{response.inspect}'")
    end

    private

    attr_reader :environment, :dns, :logger

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
