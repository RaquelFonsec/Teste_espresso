Rails.application.routes.draw do
  # Rotas da raiz do aplicativo
  root to: 'home#index'
  get 'home/index', to: 'home#index'

  # Montagem do painel do Sidekiq
  mount Sidekiq::Web => '/sidekiq'

  # Rotas para os webhooks
  namespace :webhooks do
    get 'webhooks/receive_webhook'
    post 'receive_webhook', to: 'webhooks#receive_webhook'
    post 'client_validation', to: 'webhooks#client_validation'
    post 'reimbursements/notify_payment', to: 'reimbursements#notify_payment'
    
    # Rotas para os endpoints de webhook
    resources :webhook_endpoints, only: [:create, :index, :show, :update, :destroy] do
      member do
        post :activate
        post :deactivate
      end
    end

    # Rotas para os eventos de webhook
    resources :webhook_events, only: [:create]
  end
end
