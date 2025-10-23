# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Index < ApplicationSerializer
          set_type :visit

          attributes :id, :visited_at, :city, :sector, :wedge, :house, :visit_status, :brigadist, :team,
                     :family_education_topics, :other_family_education_topic, :was_offline

          attribute :visited_at do |visit|
            visit.visited_at.presence
          end

          attribute :city do |visit|
            visit.house.city&.name
          end

          attribute :sector do |visit|
            visit.house.neighborhood&.name
          end

          attribute :wedge do |visit|
            visit.house.wedge&.name
          end

          attribute :house do |visit|
            next unless visit.house

            {
              id: visit.house.id,
              reference_code: visit.house.reference_code,
              status: visit.house.status
            }
          end

          attribute :visit_status, &:status

          attribute :brigadist do |visit|
            next if visit.user_account.nil?

            visit.user_account.user_profile.full_name
          end

          attribute :team do |visit|
            visit.team&.name
          end

          attribute :modification_history do |visit|
            versions = visit.versions
            next unless versions
            next unless versions.last

            modify_by = JSON.parse(visit.versions.last.whodunnit)['full_name'] if visit.versions&.last&.whodunnit
            {
              lastModified: visit.updated_at,
              modifiedBy: modify_by
            }
          end

          attribute :possible_duplicate_visit_ids do |visit|
            visit.possible_duplicate_visit_ids
          end
        end
      end
    end
  end
end
