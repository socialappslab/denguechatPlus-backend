# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :check_if_has_photo
          step :update_inspection
          tee :update_house_and_visit_status
          tee :set_language
          tee :assign_points

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params]).symbolize_keys
            @params.delete(:action)
            @params.delete(:controller)
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Inspections::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?

            if is_valid
              @params = @ctx['contract.default'].values.data
              return Success({ ctx: @ctx, type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid })
          end

          def check_if_has_photo
            @delete_photo = @params[:photo].nil? && @params[:delete_photo]
            @photo = @params[:photo] if @params[:photo].present?
            @params.delete(:delete_photo)
            @params.delete(:photo)
          end

          def update_inspection
            begin
              inspection = Inspection.find_by(id: @params[:id])
              inspection = manage_photo(inspection)
              @params[:color] = ::Services::RiskColorCalculator.inspection_color(
                has_water: @params.fetch(:has_water, inspection.has_water),
                type_content_ids: @params[:type_content_ids] || inspection.type_contents.pluck(:id),
                container_protection_ids: @params[:container_protection_ids] ||
                  inspection.container_protections.pluck(:id)
              )
              inspection.update(@params)
              @ctx[:model] = inspection
              Success({ ctx: @ctx, type: :created })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :unexpected_key)

              Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def update_house_and_visit_status
            @visit = @ctx[:model].visit
            @house = @visit.house

            @tariki_reached = ::Services::VisitHouseStatusUpdater.apply_and_tariki_reached?(visit: @visit)
          end

          def assign_points
            user_account = @visit.user_account
            return unless @tariki_reached

            Api::V1::Points::Services::Transactions.assign_point(earner: user_account, house_id: @house.id,
                                                                 visit_id: @visit.id)
          end

          private

          def set_language
            @ctx[:model].define_singleton_method(:language) { @language }
            @ctx[:model].define_singleton_method(:language=) { |value| @language = value }
            @ctx[:model].language = if @params.key?(:language) && @params[:language].in?(%w[en es pt])
                                      @params[:language]
                                    else
                                      'es'
                                    end
            Success({ ctx: @ctx, type: :success })
          end

          def manage_photo(inspection)
            inspection.photo = @photo if @photo && !@delete_photo
            inspection.photo.purge if @delete_photo && !@has_photo
            inspection
          end
        end
      end
    end
  end
end
