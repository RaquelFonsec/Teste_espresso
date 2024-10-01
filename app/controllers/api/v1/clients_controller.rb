module Api
    module V1
      class ClientsController < ApplicationController
        skip_before_action :verify_authenticity_token
        def create
          client = Client.new(client_params)
          
          if client.save
            # Agendar a validação das credenciais
            ValidateClientJob.perform_later(client.id)
            render json: { status: 'created', client_id: client.id }, status: :created
          else
            render json: { status: 'error', message: client.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        private
  
        def client_params
      params.require(:client).permit(:company_id, :erp, :erp_key, :erp_secret)
        end
      end
    end
  end
  