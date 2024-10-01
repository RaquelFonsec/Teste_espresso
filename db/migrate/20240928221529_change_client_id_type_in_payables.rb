class ChangeClientIdTypeInPayables < ActiveRecord::Migration[7.1]
  def up
    # Altera o tipo da coluna client_id para integer
    execute <<-SQL
      ALTER TABLE payables
      ALTER COLUMN client_id TYPE integer USING client_id::integer
    SQL
  end

  def down
    # Para reverter a migração, você pode voltar ao tipo original, que provavelmente é string
    execute <<-SQL
      ALTER TABLE payables
      ALTER COLUMN client_id TYPE varchar USING client_id::varchar
    SQL
  end
end