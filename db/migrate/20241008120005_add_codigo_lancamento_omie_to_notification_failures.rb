class AddCodigoLancamentoOmieToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :codigo_lancamento_omie, :string
  end
end
