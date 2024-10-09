Rails.application.routes.draw do
  root to: 'pages#home'
  get 'home/index', to: 'home#index'
  mount Sidekiq::Web => '/sidekiq'

  namespace :webhooks do
    post 'receive_webhook', to: 'webhooks#receive_webhook'
    post 'reimbursements/notify_payment', to: 'reimbursements#notify_payment'
  end
end
