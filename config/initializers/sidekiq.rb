require 'sidekiq'
require 'sidekiq/web'

# Configurando o Sidekiq para usar Redis
Sidekiq.configure_server do |config|
  # Use a variável de ambiente para o Redis no Heroku
  config.redis = { url: ENV['REDIS_URL'], namespace: 'my_app' }
end

Sidekiq.configure_client do |config|
  # Use a variável de ambiente para o Redis no Heroku
  config.redis = { url: ENV['REDIS_URL'], namespace: 'my_app' }
end

# Configurando o Active Job para usar o Sidekiq
Rails.application.config.active_job.queue_adapter = :sidekiq
