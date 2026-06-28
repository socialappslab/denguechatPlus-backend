# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Destroy < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :retrieve_visit
          step :authorized_user?
          step :delete_visit
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

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def retrieve_visit
            @ctx[:model] = Visit.find_by(id: @params[:id])
          end

          def authorized_user?
            if @current_user.has_role?(:admin) || @current_user.has_role?(:team_leader)
              return Success({ ctx: @ctx,
                               type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid,
                      errors: ErrorFormater.new_error(field: :base, msg: 'Only an admin/team leader or the owner can update this post', custom_predicate: :without_permissions) })
          end

          def delete_visit
            begin
              @ctx[:model].discard!
              Success({ ctx: @ctx, type: :success })
            rescue StandardError
              Failure({ ctx: @ctx, type: :invalid })
            end
          end

          def update_house_status_table
            HouseStatus.find_by(house_id: @ctx[:model].house_id, last_visit: @ctx[:model].visited_at)&.destroy!
            visit = last_visit
            return unless visit

            house = House.find_by(id: visit.house_id)
            return unless house

            counts = Services::RiskColorCalculator.inspection_counts(visit.inspections.group(:color).count)
            house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: visit.visited_at.to_date)
            house_status.date = visit.visited_at
            house_status.infected_containers = counts[:infected_containers]
            house_status.non_infected_containers = counts[:non_infected_containers]
            house_status.potential_containers = counts[:potential_containers]
            house_status.city_id = house.city_id
            house_status.country_id = house.country_id
            house_status.house_block_id = house.house_blocks.find_by(block_type: 'frente_a_frente')&.id
            house_status.neighborhood_id = house.neighborhood_id
            house_status.team_id = visit.team_id
            house_status.wedge_id = house.wedge_id
            house_status.last_visit = visit.visited_at
            house_status.house_id = house.id
            house_status.status = Services::RiskColorCalculator.visit_status(visit)
            house_status.save
          end

          def update_house_status
            house = House.find_by(id: @ctx[:model].house_id)
            return true unless house

            latest_house_status = HouseStatus.where(house_id: house.id).order(date: :desc, created_at: :desc).first
            return true unless latest_house_status

            house.update(infected_containers: latest_house_status.infected_containers,
                         non_infected_containers: latest_house_status.non_infected_containers,
                         potential_containers: latest_house_status.potential_containers,
                         last_visit: latest_house_status.last_visit,
                         status: latest_house_status.status,
                         tariki_status: house.tariki?(latest_house_status.status))

            true
          end

          private

          def is_team_leader
            return false unless @current_user.has_role?(:team_leader)

            @ctx[:model].team_id.in? @current_user.teams_under_leadership
          end

          def last_visit
            return unless @ctx[:model].visited_at

            Visit.where(
              house_id: @ctx[:model].house_id,
              visited_at: @ctx[:model].visited_at.to_date.all_day
            ).order(visited_at: :desc, created_at: :desc).first
          end
        end
      end
    end
  end
end
