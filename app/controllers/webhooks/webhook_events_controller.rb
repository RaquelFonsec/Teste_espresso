class WebhookEventsController < ApplicationController
   
    def create
      webhook_event = WebhookEvent.new(webhook_event_params)
  
      if webhook_event.save
        render json: { message: 'Evento de webhook registrado com sucesso' }, status: :created
      else
        render json: { errors: webhook_event.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def webhook_event_params
      params.require(:webhook_event).permit(:event, :payload, :webhook_endpoint_id)
    end
  end
  