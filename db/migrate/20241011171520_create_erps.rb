class CreateErps < ActiveRecord::Migration[7.1]
  def change
    create_table :erps do |t|
      t.string :key
      t.string :secret

      t.timestamps
    end
  end
end
