# == Schema Information
#
# Table name: states
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :bigint           not null
#
# Indexes
#
#  index_states_on_country_id                   (country_id)
#  index_states_on_country_id_and_discarded_at  (country_id,discarded_at) UNIQUE
#  index_states_on_name_and_discarded_at        (name,discarded_at) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class State < ApplicationRecord
  include Discard::Model

  belongs_to :country
  has_many :cities, dependent: :destroy
end
