class AddRetryAttemptsToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :retry_attempts, :integer
  end
end
