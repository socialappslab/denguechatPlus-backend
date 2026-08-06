# frozen_string_literal: true

class AddLatestActiveVisitIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_visits_on_latest_active_per_house

  def up
    execute <<~SQL.squish
      CREATE INDEX CONCURRENTLY #{INDEX_NAME}
      ON visits (house_id, visited_at DESC NULLS LAST, created_at DESC, id DESC)
      INCLUDE (status, team_id)
      WHERE discarded_at IS NULL
    SQL
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS #{INDEX_NAME}"
  end
end
