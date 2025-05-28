# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Destroy < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :retrieve_post
          step :authorized_user?
          step :delete_post
          tee :update_house_status_table
          tee :update_house_status

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Visits::Contracts::Destroy.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            return Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def retrieve_visit
            @ctx[:model] = Visit.find_by(id: @params[:id])
          end

          def authorized_user?
            return Success({ ctx: @ctx, type: :success }) if @current_user.has_role?(:admin) || @current_user.has_role?(:team_leader)

            Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Only an admin/team leader or the owner can update this post', custom_predicate: :without_permissions )})
          end

          def delete_visit
            begin
              @ctx[:model].discard!
              Success({ ctx: @ctx, type: :success })
            rescue => error
              Failure({ ctx: @ctx, type: :invalid })
            end
          end

          def update_house_status_table
            HouseStatus.find_by(last_visit: @ctx[:model].visited_at).destroy!
            visit = last_visit
            if visit
              team_id = visit.team_id
              house = house.find_by(id: visit.house_id)
              house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: visit.visited_at)
              house_status.date = visit.visited_at
              infected_containers = visit.last.inspections
                                         .where(color: ['yellow'])
                                         .count
              non_infected_containers = visit.last.inspections
                                             .where(color: ['green'])
                                             .count
              potential_containers = visit.last.inspections
                                             .where.not(color: ['yellow'])
                                             .count
              house_status.infected_containers = infected_containers
              house_status.non_infected_containers = non_infected_containers
              house_status.potential_containers = potential_containers
              house_status.city_id = house.city_id
              house_status.country_id = house.country_id
              house_status.house_block_id = house.house_block_id
              house_status.neighborhood_id = house.neighborhood_id
              house_status.team_id = team_id
              house_status.wedge_id = house.wedge_id
              house_status.last_visit = house.last_visit
              house_status.house_id = house.id
              house_status.status = house_status(house_status)
              house_status.save
            end
          end

          def update_house_status
            return true unless Visit.where(house_id: @ctx[:model].house_id).order(visited_at: :desc).first == last_visit

            house = House.find_by(id: @ctx[:model].house_id)
            house.status = HouseStatus.find_by(last_visit: house.last_visit).status
            house.save

            return true
          end

          private

          def is_team_leader
            return false unless @current_user.has_role?(:team_leader)

            @ctx[:model].team_id.in? @current_user.teams_under_leadership
          end

          def last_visit
            visit = Visit.find_by(
              house_id: @ctx[:model].house_id,
              visited_at: @ctx[:model].visited_at.to_date.all_day
            )

            return visit if visit
          end

          def house_status(house_status)
            res = "red" if house_status&.infected_containers.to_i >= 0
            res = "yellow" if house_status.potential_containers.to_i >= 0 && house_status.infected_containers.to_i < 0
            res = "green" if house_status.non_infected_containers.to_i >= 0 && house_status.infected_containers.to_i < 0 && house_status.infected_containers.to_i < 0

            res
          end
        end
      end
    end
  end
end
