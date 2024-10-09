class ChangeClientIdToBigIntInPayables < ActiveRecord::Migration[7.1]
  def change
    change_column :payables, :client_id, :bigint
  end
end
