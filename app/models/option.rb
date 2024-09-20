# == Schema Information
#
# Table name: options
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  group_en     :string
#  group_es     :string
#  group_pt     :string
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  next         :integer
#  required     :boolean          default(FALSE)
#  status_color :string
#  type_option  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :bigint           not null
#  resource_id  :integer
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
  has_one_attached :image
  belongs_to :question
end
