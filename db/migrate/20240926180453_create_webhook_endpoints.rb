class CreateWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_endpoints do |t|
      t.string :url, null: false
      t.jsonb :subscriptions, default: ['*'], null: false # Permite armazenar múltiplas inscrições
      t.boolean :enabled, default: true # Ativa/desativa o endpoint
      t.timestamps
    end
  end
end
