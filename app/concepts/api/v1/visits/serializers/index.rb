# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Index < ApplicationSerializer
          set_type :visit

          attributes :id, :visited_at, :city, :sector, :wedge, :house, :visit_status, :brigadist, :team,
                     :family_education_topics, :other_family_education_topic

          attribute :visited_at do |visit|
            visit.visited_at.presence
          end

          attribute :city do |visit|
            visit.house.city.name if visit.house&.city
          end

          attribute :sector do |visit|
            visit.house.neighborhood.name if visit.house&.neighborhood
          end

          attribute :wedge do |visit|
            visit.house.wedge.name if visit.house&.wedge
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
            visit.team.name if visit.team
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
        end
      end
    end
  end
end
