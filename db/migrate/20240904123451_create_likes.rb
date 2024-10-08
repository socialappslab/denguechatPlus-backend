class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :likeable, polymorphic: true, null: false
      t.references :user_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
