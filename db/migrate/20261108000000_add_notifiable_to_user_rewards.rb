# frozen_string_literal: true

class AddNotifiableToUserRewards < ActiveRecord::Migration[7.1]
  def change
    add_column :user_rewards, :notifiable, :boolean, null: false, default: false
  end
end
