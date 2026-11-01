# frozen_string_literal: true

class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :reward_types do |t|
      t.string :code, null: false
      t.string :metric, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string :name_es
      t.string :name_en
      t.string :name_pt
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :reward_types, :code, unique: true
    add_index :reward_types, :discarded_at

    create_table :reward_levels do |t|
      t.references :reward_type, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :threshold, null: false
      t.integer :position, null: false, default: 0
      t.string :name_es
      t.string :name_en
      t.string :name_pt
      t.string :description_es
      t.string :description_en
      t.string :description_pt
      t.string :color_primary
      t.string :color_secondary
      t.string :color_background
      t.string :ring_gradient
      t.boolean :active, null: false, default: true
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :reward_levels, %i[reward_type_id code], unique: true
    add_index :reward_levels, %i[reward_type_id threshold]
    add_index :reward_levels, :discarded_at

    create_table :user_rewards do |t|
      t.references :earner, polymorphic: true, null: false, index: false
      t.references :reward_level, null: false, foreign_key: true
      t.references :trigger_visit, foreign_key: { to_table: :visits }
      t.datetime :earned_at, null: false
      t.integer :count_at_earn, null: false
      t.datetime :seen_at
      t.timestamps
    end
    add_index :user_rewards, %i[earner_type earner_id reward_level_id], unique: true,
                                                                        name: 'index_user_rewards_on_earner_and_level'
  end
end
