# == Schema Information
#
# Table name: visits
#
#  id                           :bigint           not null, primary key
#  answers                      :jsonb
#  discarded_at                 :datetime
#  family_education_topics      :string           default([]), is an Array
#  host                         :string
#  inspection_quantity          :integer
#  inspection_with_eggs         :integer
#  inspection_with_larvae       :integer
#  inspection_with_pupae        :integer
#  notes                        :string
#  other_family_education_topic :string
#  questions                    :jsonb
#  status                       :string
#  visit_permission             :boolean          default(FALSE)
#  visit_status                 :integer
#  visited_at                   :datetime
#  was_offline                  :boolean
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  house_id                     :bigint           not null
#  questionnaire_id             :bigint           not null
#  team_id                      :bigint           not null
#  user_account_id              :bigint           not null
#
# Indexes
#
#  index_visits_on_discarded_at      (discarded_at)
#  index_visits_on_house_id          (house_id)
#  index_visits_on_questionnaire_id  (questionnaire_id)
#  index_visits_on_team_id           (team_id)
#  index_visits_on_user_account_id   (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (house_id => houses.id)
#  fk_rails_...  (questionnaire_id => questionnaires.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class Visit < ApplicationRecord
  include Discard::Model

  belongs_to :house
  belongs_to :user_account
  belongs_to :team
  belongs_to :questionnaire
  has_many :inspections, dependent: :destroy
  accepts_nested_attributes_for :inspections
  has_one_attached :upload_file

  default_scope -> { kept }
  has_paper_trail on: [:update]

  after_discard :discard_inspections

  private

  def discard_inspections
    inspections.kept.find_each(&:discard)
  end

  def undiscard_inspections
    inspections.discarded.find_each(&:undiscard)
  end
end
