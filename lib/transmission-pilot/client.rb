require "faraday"
require "oj"

module TransmissionPilot
  class Client
    RPC_PATH = "transmission/rpc"

    def initialize(host:,port:)
      @connection = Faraday.new url: "http://#{host}:#{port}" do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def torrents(names = Array.new)
      arguments = Hash.new
      arguments[:fields] = %w( name startDate doneDate eta isFinished name
        percentDone priorities rateDownload rateUpload totalSize )

      arguments[:ids] = find_ids_for(names) if names.present?

      response = request"/torrent-get", arguments: arguments

      torrents = Array.new

      return torrents unless response.success?

      Oj.load(response.body).fetch("arguments", Hash.new).fetch("torrents", Array.new).each { |t| torrents << TransmissionPilot::Torrent.new(t) }

      torrents
    end

    def find_ids_for(names)
      ids = Array.new

      return ids unless names.is_a?(Array)

      response = request"/torrent-get", arguments: { fields: %w( id name ) }

      return ids unless response.success?

      response.body["arguments"]["torrents"].each do |t|
        ids << t["id"] if names.grep(/#{t["name"]}/i).any?
      end

      ids
    end

    def priority(torrents: Array.new, level: nil)

    end

    def request(endpoint, headers: Hash.new, body: String.new, arguments: Hash.new, params: Hash.new)
      endpoint.gsub!(/\A\//, "")

      if body.blank?
        body = body_for(endpoint, arguments: arguments)
      end

      response = @connection.post "/#{RPC_PATH}/#{endpoint}" do |req|
        req.headers["X-Transmission-Session-Id"] = @session_id if @session_id
        req.headers["Content-Type"] = "application/json"
        req.body = body

        headers.each { |k, v| req.headers[k] = v }
        params.each  { |k, v| req.params[k]  = v }
      end

      if response.status === 409
        unless retried?
          retried!
          @session_id = response.headers["x-transmission-session-id"]
          response = request(endpoint, headers: headers, body: body, params: params)
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

    def body_for(endpoint, arguments: Hash.new)
      body = { "method" => endpoint }
      body["arguments"] = arguments.stringified if arguments.present?

      Oj.dump(body)
    end
  end
end
