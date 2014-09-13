require "faraday"

module TransmissionPilot
  class Client
    RPC_PATH = "transmission/rpc"

    def initialize(host:,port:)
      @connection = Faraday.new url: "http://#{host}:#{port}" do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    def request(endpoint, &block)
      response = @connection.post "/#{RPC_PATH}/#{endpoint.gsub(/\A\//, "")}" do |req|
        req.headers["X-Transmission-Session-Id"] = @session_id if @session_id
        block.call(req) if block_given?
      end

      if response.status === 409
        unless retried?
          retried!
          @session_id = response.headers["x-transmission-session-id"]
          response = request(endpoint, &block)
        end
      end

      response
    end

    def retried?
      if !!@retried
        @retried = false
        true
      else
        false
      end
    end

    def retried!
      @retried = true
    end
  end
end
