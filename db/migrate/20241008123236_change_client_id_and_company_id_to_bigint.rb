class ChangeClientIdAndCompanyIdToBigint < ActiveRecord::Migration[7.1]
  def up
    change_column :notification_failures, :client_id, :bigint
    change_column :notification_failures, :company_id, :bigint
  end

  def down
    change_column :notification_failures, :client_id, :integer
    change_column :notification_failures, :company_id, :integer
  end
end
