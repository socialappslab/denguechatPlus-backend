# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :bigint           not null, primary key
#  city         :string
#  country      :string
#  first_name   :string
#  gender       :integer
#  language     :string
#  last_name    :string
#  phone_number :string
#  points       :integer
#  slug         :string
#  timezone     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class UserProfile < ApplicationRecord
  has_one :user_profiles_role, dependent: :destroy
  has_one :role, through: :user_profiles_role
  has_one :user_account, dependent: :destroy, autosave: true

  delegate :email, :confirmed_at, to: :user_account, allow_nil: true
  delegate :name, to: :role, prefix: true, allow_nil: true
end
