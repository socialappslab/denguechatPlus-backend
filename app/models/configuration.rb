# == Schema Information
#
# Table name: configurations
#
#  id         :bigint           not null, primary key
#  field_name :string           not null
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Configuration < ApplicationRecord
  include Discard::Model


  def self.attempts_number
    Rails.cache.fetch('attempts_number', expires_in: 12.hours) do
      Configuration.find_by(field_name: 'attempts_number')&.value&.to_i || 5
    end
  end

  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end

  def self.time_locked
    Rails.cache.fetch('time_locked', expires_in: 12.hours) do
      Configuration.find_by(field_name: 'time_locked')&.value&.to_i || 10
    end
  end

end
