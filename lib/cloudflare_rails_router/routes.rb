# frozen_string_literal: true

module CloudflareRailsRouter
  class Routes
    attr_reader :client, :zone_id

    def initialize(zone_id: nil, client: nil)
      @zone_id = zone_id || CloudflareRailsRouter.configuration.zone_id
      @client = client || Client.new
      
      raise ConfigurationError, "zone_id must be configured" if @zone_id.nil?
    end

    # List all routes for the zone
    def list(page: 1, per_page: 50)
      response = client.get("/zones/#{zone_id}/workers/routes", {
        page: page,
        per_page: per_page
      })
      
      {
        routes: response["result"] || [],
        total_count: response["result_info"]["total_count"],
        page: response["result_info"]["page"],
        per_page: response["result_info"]["per_page"]
      }
    end

    # Create a new worker route
    def create(pattern:, script: nil, enabled: true)
      body = {
        pattern: pattern,
        enabled: enabled
      }
      body[:script] = script if script
      
      response = client.post("/zones/#{zone_id}/workers/routes", body)
      response["result"]
    end

    # Get a specific route
    def get(route_id)
      response = client.get("/zones/#{zone_id}/workers/routes/#{route_id}")
      response["result"]
    end

    # Update a route
    def update(route_id, pattern: nil, script: nil, enabled: nil)
      body = {}
      body[:pattern] = pattern unless pattern.nil?
      body[:script] = script unless script.nil?
      body[:enabled] = enabled unless enabled.nil?
      
      response = client.put("/zones/#{zone_id}/workers/routes/#{route_id}", body)
      response["result"]
    end

    # Delete a route
    def delete(route_id)
      response = client.delete("/zones/#{zone_id}/workers/routes/#{route_id}")
      response["success"]
    end

    # Validate a route pattern
    def validate_pattern(pattern)
      # Basic pattern validation
      return false if pattern.nil? || pattern.empty?
      
      # Check for valid pattern format
      # Patterns should include protocol and domain
      pattern.match?(%r{^https?://[^/]+/.*$})
    end
  end
end