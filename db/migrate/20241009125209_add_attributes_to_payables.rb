class AddAttributesToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :erp_key, :string
    add_column :payables, :erp_secret, :string
  end
end
