require 'rails_helper'

RSpec.describe NotificationService do
  describe '.send_notification' do
    context 'quando enviando para Omie' do
      it 'registra uma mensagem de erro quando a solicitação falha' do
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("Erro de rede"))

        expect(Rails.logger).to receive(:error).with(/Erro ao tentar enviar notificação/)
        expect(Rails.logger).to receive(:error).with(/Falha ao enviar notificação: Internal Server Error/)

        NotificationService.send_notification({ key: 'value' }, :omie)
      end

      it 'registra a resposta de falha' do
        response = double(success?: false, code: 500, body: "Erro interno")
        allow(HTTParty).to receive(:post).and_return(response)

        expect(Rails.logger).to receive(:error).with(/Falha ao enviar notificação: 500 - Erro interno/)

        NotificationService.send_notification({ key: 'value' }, :omie)
      end

      it 'registra uma mensagem de sucesso' do
        response = double(success?: true)
        allow(HTTParty).to receive(:post).and_return(response)

        expect(Rails.logger).to receive(:info).with(/Notificação enviada com sucesso./)

        NotificationService.send_notification({ key: 'value' }, :omie)
      end
    end

    context 'quando enviando para Pipedream' do
      it 'registra uma mensagem de erro quando a solicitação falha' do
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("Erro de rede"))

        expect(Rails.logger).to receive(:error).with(/Erro ao tentar enviar notificação/)
        expect(Rails.logger).to receive(:error).with(/Falha ao enviar notificação: Internal Server Error/)

        NotificationService.send_notification({ key: 'value' }, :pipedream)
      end

      it 'registra a resposta de falha' do
        response = double(success?: false, code: 500, body: "Erro interno")
        allow(HTTParty).to receive(:post).and_return(response)

        expect(Rails.logger).to receive(:error).with(/Falha ao enviar notificação: 500 - Erro interno/)

        NotificationService.send_notification({ key: 'value' }, :pipedream)
      end

      it 'registra uma mensagem de sucesso' do
        response = double(success?: true)
        allow(HTTParty).to receive(:post).and_return(response)

        expect(Rails.logger).to receive(:info).with(/Notificação enviada com sucesso./)

        NotificationService.send_notification({ key: 'value' }, :pipedream)
      end
    end
  end
end
