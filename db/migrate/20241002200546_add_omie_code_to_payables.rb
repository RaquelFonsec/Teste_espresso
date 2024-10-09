class AddOmieCodeToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :omie_code, :string
  end
end
