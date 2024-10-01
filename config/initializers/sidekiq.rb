require 'sidekiq'
require 'sidekiq/web'

# Configurando o Sidekiq para usar Redis
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

# Configurando o Active Job para usar o Sidekiq
Rails.application.config.active_job.queue_adapter = :sidekiq
