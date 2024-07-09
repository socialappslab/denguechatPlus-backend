class AddRelationsToUserProfile < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_profiles, :country
    remove_column :user_profiles, :city
    add_reference :user_profiles, :city, foreign_key: true
    add_reference :user_profiles, :neighborhood, foreign_key: true
    add_reference :user_profiles, :organization, foreign_key: true
  end
end
