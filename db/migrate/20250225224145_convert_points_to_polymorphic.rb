class ConvertPointsToPolymorphic < ActiveRecord::Migration[7.1]
  def change
    remove_index :points, :team_id if index_exists?(:points, :team_id)
    remove_index :points, :user_account_id if index_exists?(:points, :user_account_id)
    remove_index :points, %i[user_account_id team_id] if index_exists?(:points, %i[user_account_id team_id])

    remove_column :points, :team_id
    remove_column :points, :user_account_id
    remove_column :points, :house_id

    add_column :points, :pointable_type, :string
    add_column :points, :pointable_id, :bigint

    add_index :points, %i[pointable_type pointable_id]
  end
end
