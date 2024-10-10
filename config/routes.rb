Rails.application.routes.draw do
  get 'webhooks/client_validation'
  get 'webhooks/receive_webhook'
  root to: 'home#index'
  get 'home/index', to: 'home#index'
  mount Sidekiq::Web => '/sidekiq'

  namespace :webhooks do
    post 'receive_webhook', to: 'webhooks#receive_webhook'
    post '/webhooks/client_validation', to: 'webhooks#client_validation'
    post 'reimbursements/notify_payment', to: 'reimbursements#notify_payment'
  end
end
