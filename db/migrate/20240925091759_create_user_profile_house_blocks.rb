class CreateUserProfileHouseBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :user_profile_house_blocks do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.references :house_block, null: false, foreign_key: true

      t.timestamps
    end
  end
end
