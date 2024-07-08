# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmed_at         :datetime
#  discarded_at         :datetime
#  email                :string
#  locked               :boolean          default(FALSE), not null
#  locked_at            :datetime
#  password_digest      :string
#  phone                :string
#  status               :boolean          default(FALSE)
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_profile_id      :bigint
#
# Indexes
#
#  index_user_accounts_on_discarded_at     (discarded_at)
#  index_user_accounts_on_email            (email) UNIQUE
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

  has_secure_password

  belongs_to :user_profile, optional: true
  has_many :team_members

  delegate :first_name,
           :last_name,
           :gender,
           :slug,
           :points,
           :country,
           :city,
           :language,
           :timezone, to: :user_profile
end
