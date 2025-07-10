class CreateHouseBlockWedgesAndRemoveWedgeId < ActiveRecord::Migration[7.1]
  def up
    create_table :house_block_wedges do |t|
      t.references :house_block, null: false, foreign_key: true
      t.references :wedge, null: false, foreign_key: true
      t.timestamps
    end

    add_index :house_block_wedges, %i[house_block_id wedge_id], unique: true

    execute <<-SQL
      INSERT INTO house_block_wedges (house_block_id, wedge_id, created_at, updated_at)
      SELECT id, wedge_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM house_blocks
      WHERE wedge_id IS NOT NULL
    SQL

    remove_reference :house_blocks, :wedge, foreign_key: true
  end

  def down
    add_reference :house_blocks, :wedge, foreign_key: true

    execute <<-SQL
      UPDATE house_blocks
      SET wedge_id = (
        SELECT wedge_id#{' '}
        FROM house_block_wedges#{' '}
        WHERE house_block_wedges.house_block_id = house_blocks.id#{' '}
        LIMIT 1
      )
    SQL

    drop_table :house_block_wedges
  end
end
