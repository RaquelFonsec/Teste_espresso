
class Webhooks::WebhookEndpointsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_webhook_endpoint, only: [:show, :update, :destroy, :activate, :deactivate]
  
    
    def create
      webhook_endpoint = WebhookEndpoint.new(webhook_endpoint_params)
  
      if webhook_endpoint.save
        render json: { message: 'Webhook inscrito com sucesso' }, status: :created
      else
        render json: { errors: webhook_endpoint.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    
    def index
      webhook_endpoints = WebhookEndpoint.all
      render json: webhook_endpoints
    end
  
    
    def show
      render json: @webhook_endpoint
    end
  
    
    def update
      if @webhook_endpoint.update(webhook_endpoint_params)
        render json: { message: 'Webhook atualizado com sucesso' }, status: :ok
      else
        render json: { errors: @webhook_endpoint.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    
    def destroy
      @webhook_endpoint.destroy
      render json: { message: 'Webhook removido com sucesso' }, status: :no_content
    end
  
    
    def activate
      @webhook_endpoint.activate!
      render json: { message: 'Webhook ativado com sucesso' }, status: :ok
    end
  
    
    def deactivate
      @webhook_endpoint.deactivate!
      render json: { message: 'Webhook desativado com sucesso' }, status: :ok
    end
  
    private
  
    def set_webhook_endpoint
      @webhook_endpoint = WebhookEndpoint.find(params[:id])
    end
  
    private

def webhook_endpoint_params
  params.require(:webhook_endpoint).permit(:url, :event_type, :client_id, :company_id, :subscriptions, :enabled, :erp)
end
end
  