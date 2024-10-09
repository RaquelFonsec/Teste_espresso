class AddDescriptionToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :description, :string
  end
end
