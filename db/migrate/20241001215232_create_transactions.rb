class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_id
      t.string :status
      t.decimal :amount

      t.timestamps
    end
  end
end
