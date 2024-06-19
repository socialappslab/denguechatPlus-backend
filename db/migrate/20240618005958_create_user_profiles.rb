class CreateUserProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_profiles do |t|
      t.string :first_name
      t.string :last_name
      t.integer :gender
      t.string :phone_number
      t.string :slug
      t.integer :points
      t.string :country
      t.string :city
      t.string :language
      t.string :timezone

      t.timestamps
    end
  end
end
