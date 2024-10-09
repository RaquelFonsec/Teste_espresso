class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events do |t|
      t.references :webhook_endpoint, null: false, foreign_key: true # Referência ao webhook endpoint
      t.string :event, null: false
      t.jsonb :payload, null: false # Usando JSONB para armazenar o payload
      t.jsonb :response, default: {} # Armazena a resposta do evento (se necessário)
      t.timestamps
    end
  end
end
