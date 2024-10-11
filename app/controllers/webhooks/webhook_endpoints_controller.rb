require 'net/http'
require 'uri'
require 'json'

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


  def receive_webhook
    webhook_event = params[:webhook_event]

    # Verifique o tipo de evento
    if webhook_event[:event_type] == 'create_payable'
      # Extrai os dados necessários
      data = webhook_event[:data]
      
    # verificar se 'company_id' está presente
      if data[:company_id].nil?
        return render json: { error: "company_id must be present" }, status: :unprocessable_entity
      end

      # lógica para criar um registro de "payable"
      payable = Payable.new(data)
      
      if payable.save
        # Notificar a Omie após a criação bem-sucedida
        notify_omie(payable)

        render json: { message: 'Payable created successfully' }, status: :created
      else
        render json: { errors: payable.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Unsupported event type' }, status: :bad_request
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
  
  def webhook_endpoint_params
    params.require(:webhook_endpoint).permit(:url, :event_type, :client_id, :company_id, :subscriptions, :enabled, :erp)
  end
  
  # Método para notificar o Omie
  def notify_omie(payable)
    uri = URI.parse("https://app.omie.com.br/api/v1/financas/contapagar/")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    
    
    request.body = JSON.dump({
      
      company_id: payable.company_id,         
      cost: payable.cost,                     
      due_date: payable.due_date,              
      account_code: payable.account_code,      
      category_code: payable.category_code,    
      client_id: payable.client_id             
      
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Notificação enviada ao Omie: #{response.body}")
    else
      Rails.logger.error("Falha ao enviar notificação ao Omie: #{response.body}")
    end
  end
end
