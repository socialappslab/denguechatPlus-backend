# == Schema Information
#
# Table name: questionnaires
#
#  id               :bigint           not null, primary key
#  current_form     :boolean
#  discarded_at     :datetime
#  final_question   :integer
#  initial_question :integer
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Questionnaire < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }

  has_many :questions
end
