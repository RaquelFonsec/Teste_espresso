module Api
  module V1
    class ReimbursementsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        reimbursement_params = params.require(:reimbursement).permit(
          :client_id,
          :payable_id,  # ID do payable, se necessário
          :value,
          :description,
          :payment_method,
          :due_date,
          :status,
          :company_id,  # ID da empresa, se necessário
          :erp_identifier,  # Identificador do ERP
          :app_key,  # Chave do aplicativo
          :app_secret,  # Segredo do aplicativo
          :category_code,  # Novo parâmetro para category_code
          :account_code  # Novo parâmetro para account_code
        )

        client = Client.find_by(id: reimbursement_params[:client_id])

        unless client
          return render json: { status: 'error', message: 'Cliente não encontrado.' }, status: :unprocessable_entity
        end

        # Verifique se a data de vencimento não está vazia
        if reimbursement_params[:due_date].blank?
          return render json: { status: 'error', message: 'Data de vencimento não pode estar em branco.' }, status: :unprocessable_entity
        end

        # Enfileirar o job para criar a conta a pagar
        CreateAccountJob.perform_later(
          reimbursement_params[:client_id],
          reimbursement_params[:account_code],
          reimbursement_params[:category_code],
          reimbursement_params[:erp_identifier],  # ou cliente_id, se necessário
          reimbursement_params[:due_date],
          reimbursement_params[:value]
        )

        render json: { status: 'success' }, status: :created
      end
    end
  end
end
