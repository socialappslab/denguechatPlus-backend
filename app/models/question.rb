# == Schema Information
#
# Table name: questions
#
#  id               :bigint           not null, primary key
#  additional_data  :jsonb            not null
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
#  visible          :boolean          default(TRUE), not null
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
  include Discard::Model
  default_scope -> { kept }

  has_one_attached :image
  belongs_to :questionnaire
  has_many :options, dependent: :destroy
  belongs_to :parent, class_name: 'Question', optional: true, inverse_of: :children
  has_many :children, class_name: 'Question', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :parent

  alias_attribute :question, :question_text

  def format_service_url
    url = URI(self.image.attachment.key)
    "#{url.scheme}://#{url.host}/#{self.file.attachment.key}"
  end
end
