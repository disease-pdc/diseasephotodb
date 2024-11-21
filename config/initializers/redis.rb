Rails.application.config.tfimagerydb_redis = {
  url: ENV['REDIS_URL'].present? ? ENV[ENV['REDIS_URL']] || ENV['REDIS_URL'] : nil,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

REDIS_POOL = ConnectionPool.new(size: 5) do
  Redis.new Rails.application.config.tfimagerydb_redis
end

