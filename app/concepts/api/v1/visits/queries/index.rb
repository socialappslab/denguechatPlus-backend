# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            includes = [
              { house: [:wedge, :neighborhood, :city]},
              :team,
              { user_account: :user_profile }
            ]
            if filter
              includes << { house: :city } if filter[:city] || filter[:city_id]
              includes << { house: :neighborhood } if filter[:sector_name] || filter[:sector_id]
              includes << { house: :wedge } if filter[:wedge] || filter[:wedge_id]
            else
              filter = {}
            end
            @model = Visit.includes(*includes.uniq)
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model
              .yield_self(&method(:visited_at_clause))
              .yield_self(&method(:city_id_clause))
              .yield_self(&method(:city_name_clause))
              .yield_self(&method(:sector_id_clause))
              .yield_self(&method(:sector_name_clause))
              .yield_self(&method(:wedge_id_clause))
              .yield_self(&method(:wedge_name_clause))
              .yield_self(&method(:brigadist_name_clause))
              .yield_self(&method(:brigadist_id_clause))
              .yield_self(&method(:team_id_clause))
              .yield_self(&method(:team_name_clause))
              .yield_self(&method(:house_code_clause))
              .yield_self(&method(:house_status_clause))
              .yield_self(&method(:visit_status_clause))
              .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :filter, :sort

          def visited_at_clause(relation)
            return relation if @filter[:visited_at].blank?

            relation.where('DATE(visited_at) = ?', @filter[:visited_at])
          end

          def city_id_clause(relation)
            return relation if @filter[:city_id].blank?

            relation.joins(house: :city).where(houses: { city_id: @filter[:city_id] })
          end

          def city_name_clause(relation)
            return relation if @filter[:city].blank?

            relation.joins(house: :city).where('LOWER(cities.name) ILIKE ?', "%#{@filter[:city].downcase}%")
          end

          def sector_id_clause(relation)
            return relation if @filter[:sector_id].blank?

            relation.joins(house: :neighborhood).where(houses: { neighborhood_id: @filter[:sector_id] })
          end

          def sector_name_clause(relation)
            return relation if @filter[:sector_name].blank?

            relation.joins(house: :neighborhood).where('LOWER(neighborhoods.name) ILIKE ?',
                                                       "%#{@filter[:sector_name].downcase}%")
          end

          def wedge_id_clause(relation)
            return relation if @filter[:wedge_id].blank?

            relation.joins(house: :wedge).where(houses: { wedge_id: @filter[:wedge_id] })
          end

          def wedge_name_clause(relation)
            return relation if @filter[:wedge].blank?

            relation.joins(house: :wedge).where('LOWER(wedges.name) ILIKE ?', "%#{@filter[:wedge].downcase}%")
          end

          def brigadist_name_clause(relation)
            return relation if @filter[:brigadist].blank?

            relation.joins(user_account: :user_profile)
                    .where('LOWER(user_profiles.first_name) ILIKE ? OR LOWER(user_profiles.last_name) ILIKE ?',
                           "%#{@filter[:brigadist].downcase}%", "%#{@filter[:brigadist].downcase}%")
          end

          def brigadist_id_clause(relation)
            return relation if @filter[:brigadist_id].blank?

            relation.where(user_account_id: @filter[:brigadist_id])
          end

          def team_id_clause(relation)
            return relation if @filter[:team_id].blank?

            relation.where(team_id: @filter[:team_id])
          end

          def team_name_clause(relation)
            return relation if @filter[:team].blank?

            relation.joins(:team).where('LOWER(teams.name) ILIKE ?', "%#{@filter[:team].downcase}%")
          end

          def house_code_clause(relation)
            return relation if @filter[:house].blank?

            relation.joins(:house).where('houses.reference_code ILIKE ?', "%#{@filter[:house]}%")
          end

          def house_status_clause(relation)
            return relation if @filter[:house_status].blank?

            relation.joins(:house).where('houses.status ILIKE ?', "%#{@filter[:house_status]}%")
          end

          def visit_status_clause(relation)
            return relation if @filter[:visit_status].blank?

            relation.where('visits.status ILIKE ?', "%#{@filter[:visit_status]}%")
          end

          def sort_clause(relation)
            return relation if sort.blank? || sort[:field].blank?

            direction = sort[:direction].presence_in(%w[asc desc]) || 'asc'
            sort[:field] = 'teams.name' if sort[:field].include?('team')
            sort[:field] = 'user_profiles.first_name' if sort[:field].include?('brigadist')
            sort[:field] = 'houses.id' if sort[:field].include?('house')
            sort[:field] = 'visits.status' if sort[:field].include?('visit_status')
            sort[:field] = 'houses.wedge_id' if sort[:field].include?('wedge')
            sort[:field] = 'visits.id' if sort[:field] == 'id'

            relation.order("#{sort[:field]} #{direction}")
          end
        end
      end
    end
  end
end
