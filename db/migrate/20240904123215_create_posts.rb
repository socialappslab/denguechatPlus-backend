class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.text :content
      t.integer :likes_count
      t.datetime :deleted_at
      t.references :user_account, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :neighborhood, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
