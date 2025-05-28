# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :retrieve_inspections_ids_to_delete
          step :update_visit
          tee :remove_inspections
          tee :update_house_status
          tee :update_house_status_daily
          tee :set_language
          tee :assign_points

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @params.delete(:action)
            @params.delete(:controller)
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Visits::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?

            if is_valid
              @params = @ctx['contract.default'].values.data
              return Success({ ctx: @ctx, type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid })
          end

          def retrieve_inspections_ids_to_delete
            @inspections_to_delete_ids = if @params[:delete_inspection_ids].blank?
                                           []
                                         else
                                           @params.delete(:delete_inspection_ids)
                                         end
          end

          def update_visit
            hosts = @params.delete(:host)
            @params[:host] = hosts.join(', ') if hosts
            begin
              visit = Visit.find_by(id: @params[:id])
              visit.update!(@params)
              @ctx[:model] = visit.reload
              Success({ ctx: @ctx, type: :created })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def remove_inspections
            Inspection.where(id: @inspections_to_delete_ids).destroy_all
          end

          def update_house_status
            @house = @ctx[:model].house
            colors = {
              'red' => 'Rojo',
              'yellow' => 'Amarillo',
              'green' => 'Verde'
            }
            inspections_ids = @ctx[:model].inspections.pluck(:id)
            if inspections_ids.empty?
              @house.update!(infected_containers: 0, potential_containers: 0,
                             non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                             status: 'green')
              @ctx[:model].update!(status: 'Verde')
            else
              counts = @ctx[:model].inspections.group(:color).count
              result = {
                infected_containers: counts['red'] || 0,
                potential_containers: counts['yellow'] || 0,
                non_infected_containers: counts['green'] || 0,
                last_visit: @params[:visited_at] || Time.now.utc,
                status: if (counts['red'] || 0) > 0
                          'red'
                        elsif (counts['yellow'] || 0) > 0
                          'yellow'
                        elsif (counts['green'] || 0) > 0
                          'green'
                        else
                          'green'
                        end
              }
              result[:tariki_status] = @house.is_tariki?(result[:status])
              @house.update!(result)
              @ctx[:model].update!(status: colors[result[:status]])
            else
              tariki_status = @house.is_tariki?('green')
              @house.update!(infected_containers: 0, potential_containers: 0,
                             non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                             status: 'green', tariki_status:)
              @ctx[:model].update!(status: 'Verde')
            end
          end

          def update_house_status_daily
            house = @house.reload
            house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: @ctx[:model].visited_at)
            house_status.infected_containers = house.infected_containers
            house_status.non_infected_containers = house.non_infected_containers
            house_status.potential_containers = house.potential_containers
            house_status.house_id = house.id
            house_status.status = house.status
            house_status.save
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

          def assign_points
            if @house.tariki_status
              Api::V1::Points::Services::Transactions.assign_point(earner: @ctx[:model].user_account,
                                                                   house_id: @house.id, visit_id: @ctx[:model].id)
            end
            return if @house.tariki_status

            Api::V1::Points::Services::Transactions.remove_point(earner: @ctx[:model].user_account, house_id: @house.id,
                                                                 visit_id: @ctx[:model].id)
          end
        end
      end
    end
  end
end
