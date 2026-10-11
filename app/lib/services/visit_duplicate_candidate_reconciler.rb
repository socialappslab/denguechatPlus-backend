# frozen_string_literal: true

module Services
  class VisitDuplicateCandidateReconciler
    DUPLICATE_TIME_ZONE = 'America/Lima'
    Group = Struct.new(:house_id, :date, keyword_init: true)

    def self.call!(...)
      new(...).call!
    end

    def self.rebuild_house!(house_id:)
      new(house_id:).rebuild_house!
    end

    def initialize(visit: nil, previous_changes: {}, house_id: nil)
      @visit = visit
      @previous_changes = previous_changes
      @house_id = house_id
    end

    def call!
      groups = affected_groups
      return visit if groups.empty?

      ApplicationRecord.transaction do
        lock_houses(groups.map(&:house_id))
        delete_candidates_for([visit.id])
        groups.sort_by { |group| [group.house_id, group.date] }.each do |group|
          rebuild_group(group)
        end
      end

      visit
    end

    def rebuild_house!
      raise ArgumentError, 'house_id is required' if house_id.blank?

      ApplicationRecord.transaction do
        lock_houses([house_id])
        all_visit_ids = Visit.with_discarded.where(house_id:).pluck(:id)
        delete_candidates_for(all_visit_ids)

        visits_by_date = Visit.where(house_id:).where.not(visited_at: nil).pluck(:id, :visited_at)
                              .group_by { |_, visited_at| local_date(visited_at) }

        visits_by_date.each_value do |visits|
          insert_pairs(visits.map(&:first).sort)
        end
      end
    end

    private

    attr_reader :house_id, :previous_changes, :visit

    def affected_groups
      current_house_id = visit.house_id
      current_visited_at = visit.visited_at
      groups = [
        group_for(current_house_id, current_visited_at),
        group_for(previous_value(:house_id, current_house_id), previous_value(:visited_at, current_visited_at))
      ]

      groups.compact.uniq { |group| [group.house_id, group.date] }
    end

    def previous_value(attribute, fallback)
      change = previous_changes[attribute.to_s] || previous_changes[attribute.to_sym]
      change ? change.first : fallback
    end

    def group_for(group_house_id, visited_at)
      return if group_house_id.blank? || visited_at.blank?

      Group.new(house_id: group_house_id, date: local_date(visited_at))
    end

    def local_date(visited_at)
      visited_at.in_time_zone(DUPLICATE_TIME_ZONE).to_date
    end

    def date_range(date)
      zone = Time.find_zone!(DUPLICATE_TIME_ZONE)
      beginning = zone.local(date.year, date.month, date.day)
      beginning...(beginning + 1.day)
    end

    def rebuild_group(group)
      conditions = { house_id: group.house_id, visited_at: date_range(group.date) }
      all_visit_ids = Visit.with_discarded.where(conditions).pluck(:id)
      delete_candidates_for(all_visit_ids)

      active_visit_ids = Visit.where(conditions).order(:id).pluck(:id)
      insert_pairs(active_visit_ids)
    end

    def insert_pairs(visit_ids)
      return 0 if visit_ids.length < 2

      timestamp = Time.current
      rows = visit_ids.combination(2).map do |left_id, right_id|
        {
          visit_id: left_id,
          duplicate_visit_id: right_id,
          created_at: timestamp,
          updated_at: timestamp
        }
      end

      # Rows are canonicalized, deduplicated, and constrained at the database level.
      VisitDuplicateCandidate.insert_all( # rubocop:disable Rails/SkipsModelValidations
        rows,
        unique_by: :idx_visit_duplicate_candidates_unique
      ).rows.length
    end

    def delete_candidates_for(visit_ids)
      return 0 if visit_ids.empty?

      VisitDuplicateCandidate.where(visit_id: visit_ids)
                             .or(VisitDuplicateCandidate.where(duplicate_visit_id: visit_ids))
                             .delete_all
    end

    def lock_houses(house_ids)
      House.lock.where(id: house_ids.compact.uniq.sort).order(:id).load
    end
  end
end
