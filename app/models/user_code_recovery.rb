# == Schema Information
#
# Table name: user_code_recoveries
#
#  id              :bigint           not null, primary key
#  code            :string
#  expired_at      :datetime
#  used_at         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_account_id :integer
#
class UserCodeRecovery < ApplicationRecord
  belongs_to :user_account
  before_create :set_expired_at

  KEY = [ENV.fetch('ENCRYPTION_KEY', nil)].pack('H*')
  ENCRYPTOR = ActiveSupport::MessageEncryptor.new(KEY)

  def code=(value)
    self[:code] = ENCRYPTOR.encrypt_and_sign(value)
  end

  def code
    ENCRYPTOR.decrypt_and_verify(self[:code]) if self[:code].present?
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def self.decode(code)
    ENCRYPTOR.decrypt_and_verify(code) if code.present?
  end

  private

  def set_expired_at
    self.expired_at = 15.minutes.from_now
  end
end
