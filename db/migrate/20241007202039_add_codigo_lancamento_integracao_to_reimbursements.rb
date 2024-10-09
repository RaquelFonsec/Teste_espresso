class AddCodigoLancamentoIntegracaoToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :codigo_lancamento_integracao, :string
  end
end
