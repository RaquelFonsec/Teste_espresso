class ModifyResponseInWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    change_column_default :webhook_events, :response, {}
  end
end