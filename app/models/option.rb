# == Schema Information
#
# Table name: options
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  required     :boolean
#  text_area    :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :bigint           not null
#
# Indexes
#
#  index_options_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
class Option < ApplicationRecord
  belongs_to :question
end
