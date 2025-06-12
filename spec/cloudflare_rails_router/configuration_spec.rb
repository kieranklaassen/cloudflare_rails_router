# frozen_string_literal: true

RSpec.describe CloudflareRailsRouter::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(10)
      expect(config.retry_count).to eq(3)
      expect(config.retry_delay).to eq(1)
    end
  end

  describe "#credentials_configured?" do
    context "with api_token" do
      it "returns true when api_token is present" do
        config.api_token = "test-token"
        expect(config.credentials_configured?).to be true
      end
    end

    context "with api_key and api_email" do
      it "returns true when both are present" do
        config.api_key = "test-key"
        config.api_email = "test@example.com"
        expect(config.credentials_configured?).to be true
      end

      it "returns false when only api_key is present" do
        config.api_key = "test-key"
        expect(config.credentials_configured?).to be false
      end

      it "returns false when only api_email is present" do
        config.api_email = "test@example.com"
        expect(config.credentials_configured?).to be false
      end
    end

    context "without credentials" do
      it "returns false" do
        expect(config.credentials_configured?).to be false
      end
    end
  end

  describe "#auth_headers" do
    context "with api_token" do
      it "returns Bearer authorization header" do
        config.api_token = "test-token"
        expect(config.auth_headers).to eq({ "Authorization" => "Bearer test-token" })
      end
    end

    context "with api_key and api_email" do
      it "returns X-Auth headers" do
        config.api_key = "test-key"
        config.api_email = "test@example.com"
        expect(config.auth_headers).to eq({
          "X-Auth-Key" => "test-key",
          "X-Auth-Email" => "test@example.com"
        })
      end
    end

    context "without credentials" do
      it "raises ConfigurationError" do
        expect { config.auth_headers }.to raise_error(
          CloudflareRailsRouter::ConfigurationError,
          /credentials not configured/
        )
      end
    end

    context "with both api_token and api_key" do
      it "prefers api_token" do
        config.api_token = "test-token"
        config.api_key = "test-key"
        config.api_email = "test@example.com"
        expect(config.auth_headers).to eq({ "Authorization" => "Bearer test-token" })
      end
    end
  end
end