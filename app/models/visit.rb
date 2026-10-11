# frozen_string_literal: true

# == Schema Information
#
# Table name: visits
#
#  id                           :bigint           not null, primary key
#  answers                      :jsonb
#  discarded_at                 :datetime
#  family_education_topics      :string           default([]), is an Array
#  host                         :string
#  notes                        :string
#  other_family_education_topic :string
#  status                       :string
#  visit_permission_other       :string
#  visited_at                   :datetime
#  was_offline                  :boolean
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  house_id                     :bigint           not null
#  questionnaire_id             :bigint           not null
#  team_id                      :bigint           not null
#  user_account_id              :bigint           not null
#  visit_permission_option_id   :bigint
#
# Indexes
#
#  index_visits_on_discarded_at                (discarded_at)
#  index_visits_on_house_id                    (house_id)
#  index_visits_on_latest_active_per_house     (house_id,visited_at DESC NULLS LAST,created_at DESC,id DESC) WHERE (discarded_at IS NULL)
#  index_visits_on_questionnaire_id            (questionnaire_id)
#  index_visits_on_team_id                     (team_id)
#  index_visits_on_user_account_id             (user_account_id)
#  index_visits_on_visit_permission_option_id  (visit_permission_option_id)
#
# Foreign Keys
#
#  fk_rails_...  (house_id => houses.id)
#  fk_rails_...  (questionnaire_id => questionnaires.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#  fk_rails_...  (visit_permission_option_id => options.id)
#
class Visit < ApplicationRecord
  include Discard::Model
  include HasRiskColor

  attr_accessor :point_awards

  belongs_to :house
  belongs_to :user_account
  belongs_to :team
  belongs_to :questionnaire
  belongs_to :visit_permission_option, class_name: 'Option', optional: true
  risk_color_enum :status
  has_many :inspections, dependent: :destroy
  accepts_nested_attributes_for :inspections
  has_many :duplicate_candidates, class_name: 'VisitDuplicateCandidate', dependent: :destroy, inverse_of: :visit
  has_many :possible_duplicate_visits, through: :duplicate_candidates, source: :duplicate_visit
  has_many :reverse_duplicate_candidates, class_name: 'VisitDuplicateCandidate', foreign_key: :duplicate_visit_id,
                                          dependent: :destroy, inverse_of: :duplicate_visit
  has_one_attached :upload_file

  default_scope -> { kept }
  scope :latest_first, -> { reorder(Arel.sql(Visit.latest_first_order)) }
  has_paper_trail on: [:update]

  def self.latest_first_order(table: table_name)
    "#{table}.visited_at DESC NULLS LAST, #{table}.created_at DESC, #{table}.id DESC"
  end

  def possible_duplicate_visit_ids
    direct_duplicates = duplicate_ids(duplicate_candidates, :duplicate_visit_id, :duplicate_visit)
    reverse_duplicates = duplicate_ids(reverse_duplicate_candidates, :visit_id, :visit)

    (direct_duplicates + reverse_duplicates).compact.uniq
  end

  def visit_permission_granted?
    visit_permission_option&.value.to_i == 1
  end

  after_discard :discard_inspections
  after_undiscard :undiscard_inspections
  after_create_commit :reconcile_duplicate_candidates_after_create
  after_update_commit :reconcile_duplicate_candidates_after_update, if: :duplicate_group_changed?

  private

  def duplicate_ids(candidates, id_column, association)
    if candidates.loaded? && candidates.all? { |candidate| candidate.association(association).loaded? }
      return candidates.filter_map { |candidate| candidate.public_send(association)&.id }
    end

    candidates.joins(association).merge(Visit.kept).distinct.pluck(id_column)
  end

  def duplicate_group_changed?
    %w[house_id visited_at discarded_at].any? do |attribute|
      previous_changes.key?(attribute) || previous_changes.key?(attribute.to_sym)
    end
  end

  def reconcile_duplicate_candidates_after_create
    Services::VisitDuplicateCandidateReconciler.call!(visit: self)
  rescue StandardError => error
    Rails.logger.error("Visit #{id} duplicate reconciliation failed: #{error.message}")
  end

  def reconcile_duplicate_candidates_after_update
    Services::VisitDuplicateCandidateReconciler.call!(visit: self, previous_changes:)
  rescue StandardError => error
    Rails.logger.error("Visit #{id} duplicate reconciliation failed: #{error.message}")
  end

  def discard_inspections
    Inspection.kept.where(visit_id: id).find_each(&:discard)
  end

  def undiscard_inspections
    Inspection.discarded.where(visit_id: id).find_each(&:undiscard)
  end
end
