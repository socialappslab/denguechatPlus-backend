# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id              :bigint           not null, primary key
#  discarded_at    :datetime
#  password_digest :string
#  phone           :string
#  status          :integer          default("pending")
#  username        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_profile_id :bigint
#
# Indexes
#
#  index_user_accounts_on_discarded_at     (discarded_at)
#  index_user_accounts_on_phone            (phone) UNIQUE
#  index_user_accounts_on_user_profile_id  (user_profile_id)
#  index_user_accounts_on_username         (username) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class UserAccount < ApplicationRecord
  include Discard::Model

  rolify
  has_secure_password

  belongs_to :user_profile, optional: true
  has_many :teams, through: :user_profile
  has_many :permissions, through: :roles

  delegate :first_name,
           :last_name,
           :gender,
           :email,
           :points,
           :city_id,
           :neighborhood_id,
           :organization_id,
           :language,
           :timezone, to: :user_profile

  enum status: { pending: 0, active: 1, inactive: 2, locked: 3 }



  def can?(name, resource)
    roles.joins(:permissions).exists?(permissions: { name:, resource: })
  end
end
