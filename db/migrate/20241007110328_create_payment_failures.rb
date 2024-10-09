class CreatePaymentFailures < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_failures do |t|
      t.references :reimbursement, null: false, foreign_key: true
      t.string :error_message

      t.timestamps # Isso já cria created_at e updated_at automaticamente
    end
  end
end
