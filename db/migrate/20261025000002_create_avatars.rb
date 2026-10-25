# frozen_string_literal: true

class CreateAvatars < ActiveRecord::Migration[7.1]
  def change
    create_table :avatars do |t|
      t.string :base_code, null: false
      t.references :reward_level, foreign_key: true
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :avatars, %i[base_code reward_level_id], unique: true
    add_index :avatars, :base_code, unique: true, where: 'reward_level_id IS NULL',
                                    name: 'index_avatars_on_base_code_without_skin'

    add_reference :user_profiles, :avatar, foreign_key: true
    add_reference :user_profiles, :equipped_reward_level, foreign_key: { to_table: :reward_levels }
    add_column :user_profiles, :skin_manually_chosen, :boolean, null: false, default: false
  end
end
