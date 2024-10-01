class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:notify_payment]

  def notify_payment
    payable = Payable.find_by(id: params.dig(:payment, :id))

    unless payable
      render json: { error: 'Payable account not found.' }, status: :not_found and return
    end

    reimbursement = Reimbursement.find_by(payable_id: payable.id)
    if reimbursement.nil? || reimbursement.status == "paid"
      render json: { error: 'Reimbursement not found or already paid.' }, status: :unprocessable_entity and return
    end
    # Process the payment
    begin
      process_payment(reimbursement)
      
      # Notify the webhook
      notify_webhook(reimbursement)

      render json: { message: "Payment registered for reimbursement ID: #{reimbursement.id}" }, status: :ok
    rescue StandardError => e
      Rails.logger.error("Error processing payment for reimbursement ID #{reimbursement.id}: #{e.message}")
      render json: { error: 'An error occurred while processing the payment.' }, status: :internal_server_error
    end
  end

  private

  def process_payment(reimbursement)
    reimbursement.update!(status: "paid", payment_date: Time.current)
  end

  def notify_webhook(reimbursement)
    webhook_url = "0a12-2a02-a474-b1c4-1-c97d-bd11-cecd-4945.ngrok-free.app/webhooks/subscribe"
    payload = {
      success: true,
      client_id: reimbursement.client_id,
      message: "Reimbursement of #{reimbursement.value} has been paid.",
      credentials: {
        username: ENV['APP_KEY'],  # Your app key
        password: ENV['APP_SECRET'] # Your app secret
      }
    }

    response = HTTParty.post(webhook_url, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
    
    if response.code == 200
      Rails.logger.info("Webhook notification sent successfully for reimbursement ID #{reimbursement.id}")
    else
      Rails.logger.error("Failed to send webhook notification: #{response.body}")
    end
  end
end
