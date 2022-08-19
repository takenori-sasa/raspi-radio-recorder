require 'yaml'
sidekiq_config = YAML.load_file('config/sidekiq.yml')
# Sidekiq.logger = ::Logger.new(sidekiq_config[:logfile])
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1") }
  # config.logger = ::Logger.new(sidekiq_config[:logfile])
end
