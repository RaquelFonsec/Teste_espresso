require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApiApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_job.queue_adapter = :sidekiq

    # Adicione middleware para habilitar sessões
    config.middleware.use ActionDispatch::Session::CookieStore, {
      key: '_your_app_session',
      expire_after: 1.day,
      secure: Rails.env.production?,
      same_site: :lax
    }

    # Ignorar diretórios específicos no autoload
    config.autoload_lib(ignore: %w[assets tasks])
    config.active_job.queue_adapter = :sidekiq

    # Configurações adicionais para API
    config.api_only = true
  end
end
