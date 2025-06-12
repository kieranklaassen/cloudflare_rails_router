# frozen_string_literal: true

require "faraday"
require "faraday/retry"

module CloudflareRailsRouter
  class Client
    BASE_URL = "https://api.cloudflare.com/client/v4"

    attr_reader :configuration

    def initialize(configuration = CloudflareRailsRouter.configuration)
      @configuration = configuration
    end

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.request :retry, {
          max: configuration.retry_count,
          interval: configuration.retry_delay,
          backoff_factor: 2,
          exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
        }
        
        configuration.auth_headers.each do |key, value|
          faraday.headers[key] = value
        end
        faraday.headers["Content-Type"] = "application/json"
        
        faraday.options.timeout = configuration.timeout
        faraday.options.open_timeout = configuration.open_timeout
        
        faraday.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      handle_response { connection.get(path, params) }
    end

    def post(path, body = {})
      handle_response { connection.post(path, body) }
    end

    def put(path, body = {})
      handle_response { connection.put(path, body) }
    end

    def patch(path, body = {})
      handle_response { connection.patch(path, body) }
    end

    def delete(path)
      handle_response { connection.delete(path) }
    end

    private

    def handle_response
      response = yield
      
      if response.success?
        response.body
      else
        error_message = parse_error_message(response)
        raise ApiError.new(error_message, response.status, response.body)
      end
    rescue Faraday::Error => e
      raise NetworkError, "Network error: #{e.message}"
    end

    def parse_error_message(response)
      if response.body.is_a?(Hash)
        errors = response.body["errors"] || []
        if errors.any?
          errors.map { |e| "#{e['code']}: #{e['message']}" }.join(", ")
        else
          response.body["message"] || "Unknown error"
        end
      else
        "HTTP #{response.status}: #{response.reason_phrase}"
      end
    end
  end

  class ApiError < StandardError
    attr_reader :status_code, :response_body

    def initialize(message, status_code, response_body)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  class NetworkError < StandardError; end
end