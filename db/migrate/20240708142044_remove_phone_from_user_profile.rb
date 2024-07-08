class RemovePhoneFromUserProfile < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_profiles, :phone_number
  end
end
