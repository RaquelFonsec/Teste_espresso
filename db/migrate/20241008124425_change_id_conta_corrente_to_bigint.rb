class ChangeIdContaCorrenteToBigint < ActiveRecord::Migration[7.1]
  def change
    change_column :notification_failures, :id_conta_corrente, :bigint
  end
end
