# == Schema Information
#
# Table name: permissions
#
#  id         :bigint           not null, primary key
#  name       :string
#  resource   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Permission < ApplicationRecord
  has_and_belongs_to_many :roles
end
