class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :erp
      t.string :erp_key
      t.string :erp_secret

      t.timestamps
    end
  end
end
