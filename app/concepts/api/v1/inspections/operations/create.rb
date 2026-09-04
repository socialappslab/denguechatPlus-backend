# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :find_visit
          step :create_inspection

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Inspections::Contracts::Create.kall(@params)
            return Success({ ctx: @ctx, type: :success }) if @ctx['contract.default'].success?

            Failure({ ctx: @ctx, type: :invalid })
          end

          def find_visit
            @params = @ctx['contract.default'].values.data
            @visit = Visit.find_by(id: @params.delete(:visit_id))
            return Success({ ctx: @ctx, type: :success }) if @visit

            Failure({ ctx: @ctx, type: :not_found })
          end

          def create_inspection
            ActiveRecord::Base.transaction do
              @ctx[:model] = create_inspection_record
              update_visit_and_house_status
              update_house_status_daily
              assign_points
            end

            Success({ ctx: @ctx, type: :created })
          rescue StandardError => error
            errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :unexpected_key)

            Failure({ ctx: @ctx, type: :invalid, errors: })
          end

          private

          def create_inspection_record
            photo = @params.delete(:photo)
            inspection = @visit.inspections.create!(
              @params.merge(
                color: inspection_color,
                created_by: @current_user,
                has_water: true,
                treated_by: @visit.user_account
              )
            )
            inspection.photo.attach(photo) if photo.present?
            inspection
          end

          def inspection_color
            ::Services::RiskColorCalculator.inspection_color(
              has_water: true,
              type_content_ids: @params[:type_content_ids],
              container_protection_ids: @params[:container_protection_ids]
            )
          end

          def update_visit_and_house_status
            @house = @visit.house
            @tariki_reached = ::Services::VisitHouseStatusUpdater.apply_and_tariki_reached?(visit: @visit)
          end

          def update_house_status_daily
            house = @house.reload
            house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: @visit.visited_at)
            house_status.assign_attributes(
              city_id: house.city_id,
              country_id: house.country_id,
              house_block_id: house.house_blocks.find_by(block_type: 'frente_a_frente')&.id,
              infected_containers: house.infected_containers,
              last_visit: house.last_visit,
              neighborhood_id: house.neighborhood_id,
              non_infected_containers: house.non_infected_containers,
              potential_containers: house.potential_containers,
              status: house.status,
              team_id: @visit.team_id,
              wedge_id: house.wedge_id
            )
            house_status.save!
          end

          def assign_points
            return unless @tariki_reached

            Api::V1::Points::Services::Transactions.assign_point(
              earner: @visit.user_account,
              house_id: @house.id,
              visit_id: @visit.id
            )
          end
        end
      end
    end
  end
end
