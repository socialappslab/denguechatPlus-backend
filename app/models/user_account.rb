# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id                    :bigint           not null, primary key
#  code_recovery_sent_at :datetime
#  discarded_at          :datetime
#  failed_attempts       :integer          default(0)
#  password_digest       :string
#  phone                 :string
#  status                :integer          default("pending")
#  username              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_profile_id       :bigint
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

  belongs_to :user_profile, optional: true, dependent: :destroy
  has_many :teams, through: :user_profile
  has_and_belongs_to_many :roles,  join_table: :user_accounts_roles
  has_many :permissions, through: :roles
  has_many :user_code_recoveries
  accepts_nested_attributes_for :user_profile,  update_only: true
  before_save :downcase_username_and_password!

  default_scope { where(discarded_at: nil) }


  delegate :first_name,
           :last_name,
           :gender,
           :email,
           :points,
           :city_id,
           :neighborhood_id,
           :organization_id,
           :language,
           :house_blocks,
           :timezone, to: :user_profile

  enum status: { pending: 0, active: 1, inactive: 2, locked: 3 }


  def normalized_phone
    return "" unless phone
    return  phone.prepend('+') unless phone.start_with?('+')
    return phone
  end

  def can?(name, resource)
    roles.joins(:permissions).exists?(permissions: { name:, resource: })
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def teams_under_leadership
    return [] unless has_role?(:team_leader)

    teams.pluck(:id)
  end

  def last_recovery_code_sent_at
    user_code_recoveries.last&.created_at
  end

  private
  def downcase_username_and_password!
    self.password = password.downcase.gsub(/\s+/, '') if password.present?
    self.username = username.downcase.gsub(/\s+/, '') if username.present?
    self.phone = phone.gsub(/\s+/, '') if phone.present?
  end
end
