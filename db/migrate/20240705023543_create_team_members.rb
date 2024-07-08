class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members do |t|
      t.references :user_account, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
