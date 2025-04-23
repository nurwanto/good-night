class Rack::Attack
  # Throttle requests to 20 requests per second per IP for all endpoints
  throttle('req/ip', limit: 20, period: 1.second) do |req|
    req.ip
  end

  # # Throttle requests to 20 requests per second per IP for a specific endpoint
  # throttle('req/ip/user/relations', limit: 2, period: 1.second) do |req|
  #   req.ip if req.path == '/api/v1/user/relations' && req.post?
  # end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Rate limit exceeded' }.to_json]]
  end

  # Blocklist abusive IPs if needed
  # This is a placeholder. You can implement your own logic to identify abusive IPs.
  # For example, you might want to block IPs that have made too many failed login attempts.
  # You can use a database or an external service to maintain the list of blocked IPs.
  blocklist('block abusive IPs') do |req|
    # Add logic to block abusive IPs
    false
  end
end
