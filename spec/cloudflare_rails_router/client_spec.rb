# frozen_string_literal: true

RSpec.describe CloudflareRailsRouter::Client do
  let(:configuration) do
    config = CloudflareRailsRouter::Configuration.new
    config.api_token = "test-token"
    config
  end
  
  subject(:client) { described_class.new(configuration) }

  describe "#initialize" do
    it "uses the provided configuration" do
      expect(client.configuration).to eq(configuration)
    end

    it "uses the global configuration by default" do
      CloudflareRailsRouter.configuration.api_token = "global-token"
      client = described_class.new
      expect(client.configuration).to eq(CloudflareRailsRouter.configuration)
    end
  end

  describe "#get" do
    it "makes a GET request" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test")
        .with(headers: { "Authorization" => "Bearer test-token" })
        .to_return(status: 200, body: { success: true, result: { data: "test" } }.to_json)

      response = client.get("/test")
      expect(response["success"]).to be true
      expect(response["result"]["data"]).to eq("test")
    end

    it "handles query parameters" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test?page=1&per_page=50")
        .to_return(status: 200, body: { success: true }.to_json)

      client.get("/test", page: 1, per_page: 50)
    end
  end

  describe "#post" do
    it "makes a POST request with body" do
      stub_request(:post, "https://api.cloudflare.com/client/v4/test")
        .with(
          body: { name: "test" }.to_json,
          headers: { "Authorization" => "Bearer test-token", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: { success: true }.to_json)

      response = client.post("/test", { name: "test" })
      expect(response["success"]).to be true
    end
  end

  describe "#put" do
    it "makes a PUT request with body" do
      stub_request(:put, "https://api.cloudflare.com/client/v4/test/123")
        .with(body: { name: "updated" }.to_json)
        .to_return(status: 200, body: { success: true }.to_json)

      response = client.put("/test/123", { name: "updated" })
      expect(response["success"]).to be true
    end
  end

  describe "#patch" do
    it "makes a PATCH request with body" do
      stub_request(:patch, "https://api.cloudflare.com/client/v4/test/123")
        .with(body: { status: "active" }.to_json)
        .to_return(status: 200, body: { success: true }.to_json)

      response = client.patch("/test/123", { status: "active" })
      expect(response["success"]).to be true
    end
  end

  describe "#delete" do
    it "makes a DELETE request" do
      stub_request(:delete, "https://api.cloudflare.com/client/v4/test/123")
        .to_return(status: 200, body: { success: true }.to_json)

      response = client.delete("/test/123")
      expect(response["success"]).to be true
    end
  end

  describe "error handling" do
    it "raises ApiError for 4xx responses" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test")
        .to_return(
          status: 400,
          body: {
            success: false,
            errors: [{ code: 7000, message: "Bad request" }]
          }.to_json
        )

      expect { client.get("/test") }.to raise_error(CloudflareRailsRouter::ApiError) do |error|
        expect(error.message).to include("7000: Bad request")
        expect(error.status_code).to eq(400)
      end
    end

    it "raises ApiError for 5xx responses" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test")
        .to_return(status: 500, body: { message: "Internal server error" }.to_json)

      expect { client.get("/test") }.to raise_error(CloudflareRailsRouter::ApiError) do |error|
        expect(error.message).to include("Internal server error")
        expect(error.status_code).to eq(500)
      end
    end

    it "raises NetworkError for connection failures" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test")
        .to_raise(Faraday::ConnectionFailed.new("Connection failed"))

      expect { client.get("/test") }.to raise_error(CloudflareRailsRouter::NetworkError, /Network error/)
    end

    it "retries failed requests" do
      stub_request(:get, "https://api.cloudflare.com/client/v4/test")
        .to_timeout
        .then
        .to_return(status: 200, body: { success: true }.to_json)

      response = client.get("/test")
      expect(response["success"]).to be true
    end
  end
end