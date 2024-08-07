class CreateHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :house_blocks do |t|
      t.datetime :discarded_at
      t.references :team, null: false, foreign_key: true
      t.references :user_profile, null: false, foreign_key: true
      t.timestamps
    end
  end
end
