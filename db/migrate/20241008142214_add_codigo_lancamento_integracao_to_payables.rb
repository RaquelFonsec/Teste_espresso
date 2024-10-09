class AddCodigoLancamentoIntegracaoToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :codigo_lancamento_integracao, :string
  end
end
