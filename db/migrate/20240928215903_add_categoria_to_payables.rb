class AddCategoriaToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :categoria, :string
  end
end
