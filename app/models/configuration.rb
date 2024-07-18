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

end
