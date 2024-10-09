class AddCodigoLancamentoIntegracaoToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :codigo_lancamento_integracao, :string
  end
end
