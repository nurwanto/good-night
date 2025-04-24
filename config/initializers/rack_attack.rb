class Rack::Attack
  # # Throttle requests to 20 requests per second per IP for all endpoints
  # throttle('req/ip', limit: 20, period: 1.second) do |req|
  #   req.ip
  # end

  # # # Throttle requests to 20 requests per second per IP for a specific endpoint
  # # throttle('req/ip/user/relations', limit: 2, period: 1.second) do |req|
  # #   req.ip if req.path == '/api/v1/user/relations' && req.post?
  # # end

  # # Custom response for throttled requests
  # self.throttled_responder = lambda do |_env|
  #   [429, { 'Content-Type' => 'application/json' }, [{ error: 'Rate limit exceeded' }.to_json]]
  # end
end
