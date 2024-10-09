class CreateWebhookSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_subscriptions do |t|
      t.references :client, null: false, foreign_key: true
      t.references :webhook_endpoint, null: false, foreign_key: true
      t.string :event, null: false
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
