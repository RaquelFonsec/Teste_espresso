class CreatePayables < ActiveRecord::Migration[7.1]
  def change
    create_table :payables do |t|
      t.string :account_code
      t.string :category_code
      t.string :client_code
      t.string :client_id
      t.decimal :cost
      t.date :due_date

      t.timestamps
    end
  end
end
