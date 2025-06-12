# frozen_string_literal: true

module CloudflareRailsRouter
  class PageRules
    attr_reader :client, :zone_id

    def initialize(zone_id: nil, client: nil)
      @zone_id = zone_id || CloudflareRailsRouter.configuration.zone_id
      @client = client || Client.new
      
      raise ConfigurationError, "zone_id must be configured" if @zone_id.nil?
    end

    # List all page rules for the zone
    def list(status: nil, order: "priority")
      params = { order: order }
      params[:status] = status if status
      
      response = client.get("/zones/#{zone_id}/pagerules", params)
      response["result"] || []
    end

    # Create a new page rule
    def create(targets:, actions:, priority: nil, status: "active")
      body = {
        targets: Array(targets).map { |t| normalize_target(t) },
        actions: Array(actions).map { |a| normalize_action(a) },
        status: status
      }
      body[:priority] = priority if priority
      
      response = client.post("/zones/#{zone_id}/pagerules", body)
      response["result"]
    end

    # Get a specific page rule
    def get(rule_id)
      response = client.get("/zones/#{zone_id}/pagerules/#{rule_id}")
      response["result"]
    end

    # Update a page rule
    def update(rule_id, targets: nil, actions: nil, priority: nil, status: nil)
      body = {}
      body[:targets] = Array(targets).map { |t| normalize_target(t) } if targets
      body[:actions] = Array(actions).map { |a| normalize_action(a) } if actions
      body[:priority] = priority if priority
      body[:status] = status if status
      
      response = client.patch("/zones/#{zone_id}/pagerules/#{rule_id}", body)
      response["result"]
    end

    # Delete a page rule
    def delete(rule_id)
      response = client.delete("/zones/#{zone_id}/pagerules/#{rule_id}")
      response["success"]
    end

    # Update the priority of page rules
    def update_priorities(rule_priorities)
      # rule_priorities should be an array of {id: "rule_id", priority: 1}
      body = rule_priorities.map do |rp|
        { id: rp[:id], priority: rp[:priority] }
      end
      
      response = client.patch("/zones/#{zone_id}/pagerules", body)
      response["result"]
    end

    private

    def normalize_target(target)
      if target.is_a?(String)
        { target: "url", constraint: { operator: "matches", value: target } }
      else
        target
      end
    end

    def normalize_action(action)
      if action.is_a?(Hash) && action[:id] && !action.key?(:value)
        action
      elsif action.is_a?(Hash)
        action
      else
        raise ArgumentError, "Invalid action format"
      end
    end
  end
end