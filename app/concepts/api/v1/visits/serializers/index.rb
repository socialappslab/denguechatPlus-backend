# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Index < ApplicationSerializer
          set_type :visit

          attributes :id, :visited_at, :city, :sector, :wedge, :house, :visit_status, :brigadist, :team

          attribute :visited_at do |visit|
            visit.visited_at if visit.visited_at.present?
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
            visit.house.id if visit.house
          end

          attribute :visit_status, &:status

          attribute :brigadist do |visit|
            visit.user_account.user_profile.full_name
          end

          attribute :team do |visit|
            visit.team.name if visit.team
          end
        end
      end
    end
  end
end
