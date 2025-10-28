# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_duplicate_candidates
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  duplicate_visit_id :bigint           not null
#  visit_id           :bigint           not null
#
# Indexes
#
#  idx_visit_duplicate_candidates_unique                   (visit_id,duplicate_visit_id) UNIQUE
#  index_visit_duplicate_candidates_on_duplicate_visit_id  (duplicate_visit_id)
#  index_visit_duplicate_candidates_on_visit_id            (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (duplicate_visit_id => visits.id)
#  fk_rails_...  (visit_id => visits.id)
#
class VisitDuplicateCandidate < ApplicationRecord
  belongs_to :visit
  belongs_to :duplicate_visit, class_name: 'Visit'

  validates :visit_id, presence: true
  validates :duplicate_visit_id, presence: true
  validates :duplicate_visit_id, uniqueness: { scope: :visit_id }
end
