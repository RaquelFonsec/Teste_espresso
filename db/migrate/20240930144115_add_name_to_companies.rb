class AddNameToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :name, :string
  end
end
