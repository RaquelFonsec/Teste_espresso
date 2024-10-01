Rails.application.routes.draw do
  root to: "pages#home"

  # Interface do Sidekiq
  mount Sidekiq::Web => '/sidekiq'

  # Rotas de Integração
  post 'integrations/validate_credentials', to: 'integrations#validate_credentials'  # Validação de credenciais do cliente
  post 'api/v1/geral/clientes', to: 'integrations#validate_client'  # Validação de cliente (integrador)

  # Rotas de Pagamentos
  post 'payments/create', to: 'payments#create'  # Criação de contas a pagar
  post 'payments/notify_payment', to: 'payments#notify_payment'  # Notificação de pagamento
  get 'payments/notify_payment', to: 'payments#notify_payment'  # Receber notificações de pagamento (GET)

  # Rotas de Webhooks
  post 'webhooks', to: 'webhooks#receive_webhook'  # Receber webhooks
  post 'webhooks/subscribe', to: 'webhooks#subscribe'  # Assinaturas de webhooks
  post 'webhooks/notify_payment', to: 'webhooks#notify_payment'  # Notificação de pagamento via webhook
  post 'webhooks/notify_client_validity', to: 'webhooks#notify_client_validity'  # Notificação da validade do cliente
  post 'webhooks/reimbursements', to: 'webhooks#reimbursements'  # Notificação de reembolsos
  post 'webhooks/create_refund', to: 'webhooks#create_refund'  # Criação de reembolso via webhook

  # Namespace API para organização das rotas de clientes e finanças
  namespace :api do
    namespace :v1 do
      resources :clients, only: [:create]  # Criação de cliente
      resources :configure_clients, only: [:create]  # Configuração do cliente

      # Rotas para reembolsos
      resources :reimbursements, only: [:create]  # Criação de reembolsos

      # Rotas para contas a pagar dentro de finanças
      resources :finances, only: [] do
        collection do
          post 'contapagar', to: 'finances#create_account_payable'  # Criação de contas a pagar
        end
      end
    end
  end
end
