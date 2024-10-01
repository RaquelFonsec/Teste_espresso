class CreateReimbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :reimbursements do |t|
      t.integer :company_id
      t.decimal :value, precision: 10, scale: 2
      t.string :description
      t.date :due_date
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
