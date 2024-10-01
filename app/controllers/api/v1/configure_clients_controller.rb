# app/controllers/api/v1/configure_clients_controller.rb
class Api::V1::ConfigureClientsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
  
    def create
      client_params = params.require(:configure_client).permit(:company_id, :erp, :erp_key, :erp_secret)
  
      # Enfileira o job para validação das credenciais
      ValidateCredentialsJob.perform_later(client_params[:company_id], client_params[:erp], client_params[:erp_key], client_params[:erp_secret])
  
      # Responde imediatamente com um status de sucesso
      render json: { message: 'Cadastro recebido. A validação das credenciais está sendo processada.' }, status: :accepted
    end
  end
  