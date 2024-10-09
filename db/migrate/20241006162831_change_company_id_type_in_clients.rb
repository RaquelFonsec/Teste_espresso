class ChangeCompanyIdTypeInClients < ActiveRecord::Migration[7.1]
  def change
    change_column :clients, :company_id, :integer, using: 'company_id::integer'
  end
end
