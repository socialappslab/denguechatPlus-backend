class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :likes_count
      t.references :post, null: false, foreign_key: true
      t.references :user_account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
