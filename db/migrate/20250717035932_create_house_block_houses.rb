class CreateHouseBlockHouses < ActiveRecord::Migration[7.1]
  def change
    create_table :house_block_houses do |t|
      t.references :house, null: false, foreign_key: true
      t.references :house_block, null: false, foreign_key: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO house_block_houses (house_id, house_block_id, created_at, updated_at)
          SELECT id AS house_id, house_block_id, NOW(), NOW()
          FROM houses
          WHERE house_block_id IS NOT NULL
        SQL
        execute <<~SQL
          UPDATE house_blocks
          SET block_type = 'frente_a_frente'
        SQL

        remove_reference :houses, :house_block, foreign_key: true
      end

      dir.down do
        add_reference :houses, :house_block, foreign_key: true

        execute <<~SQL
          UPDATE houses
          SET house_block_id = subquery.house_block_id
          FROM (
            SELECT house_id, MIN(house_block_id) AS house_block_id
            FROM house_block_houses
            GROUP BY house_id
          ) AS subquery
          WHERE houses.id = subquery.house_id
        SQL
      end
    end
  end
end
