class CreatePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :points do |t|
      t.integer :user_account_id
      t.integer :team_id
      t.integer :house_id
      t.integer :value
      t.timestamps

      t.index :user_account_id
      t.index :team_id
      t.index %i[user_account_id team_id]
    end
  end
end
