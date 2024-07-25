# == Schema Information
#
# Table name: visit_param_versions
#
#  id         :bigint           not null, primary key
#  name       :string
#  version    :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class VisitParamVersion < ApplicationRecord
end
