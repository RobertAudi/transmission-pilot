module TransmissionPilot
  class Pilot
    CONFIG_FILE = File.expand_path(File.join(ENV["HOME"], ".pilotrc"))

    attr_reader :client

    def initialize
      @client ||= TransmissionPilot::Client.new(host: self.config[:host], port: self.config[:port])
    end

    def config
      unless @config
        @config = {
          host: "127.0.0.1",
          port: "9091"
        }

        if File.readable?(CONFIG_FILE)
          user_config = Psych.load(File.read(CONFIG_FILE))

          if user_config.is_a?(Hash)
            # Symbolize keys
            user_config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

            @config.merge(user_config)
            @config.gsub!(/\Ahttps?:\/\//, "")
          end
        end
      end

      @config
    end

    def method_missing(method_name, *arguments, &block)
      if self.client.respond_to?(method_name)
        self.client.send(method_name, *arguments)
      else
        super
      end
    end
  end
end
