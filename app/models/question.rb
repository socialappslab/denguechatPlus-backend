# == Schema Information
#
# Table name: questions
#
#  id               :bigint           not null, primary key
#  description_en   :string
#  description_es   :string
#  description_pt   :string
#  discarded_at     :datetime
#  next             :integer
#  notes_en         :string
#  notes_es         :string
#  notes_pt         :string
#  question_text_en :string
#  question_text_es :string
#  question_text_pt :string
#  required         :boolean          default(TRUE)
#  resource_name    :string
#  resource_type    :string
#  type_field       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  questionnaire_id :bigint           not null
#
# Indexes
#
#  index_questions_on_questionnaire_id  (questionnaire_id)
#
# Foreign Keys
#
#  fk_rails_...  (questionnaire_id => questionnaires.id)
#
class Question < ApplicationRecord
  has_one_attached :image
  belongs_to :questionnaire
  has_many :options, dependent: :destroy

  alias_attribute :question, :question_text
end
