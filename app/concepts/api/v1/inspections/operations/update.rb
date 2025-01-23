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
          tee :update_house_status_daily
          tee :set_language

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
            @photo = @params[:photo] unless @params[:photo].blank?
            @params.delete(:delete_photo)
            @params.delete(:photo)
          end

          def update_inspection
            begin
              inspection = Inspection.find_by(id: @params[:id])
              inspection = manage_photo(inspection)
              @params[:color] = analyze_inspection_status(inspection, @params[:type_content_ids])
              inspection.update(@params)
              @ctx[:model] = inspection
              Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :unexpected_key )

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def update_house_and_visit_status
            colors = {
              'red' => "Rojo",
              'yellow' => "Amarillo",
              'green' => "Verde"
            }
            @visit = @ctx[:model].visit
            @house = @visit.house
            @inspections = @visit.inspections
            if !@inspections.empty?
              counts = @inspections.group(:color).count
              result = {
                infected_containers: counts["red"] || 0,
                potential_containers: counts["yellow"] || 0,
                non_infected_containers: counts["green"] || 0,
                last_visit: @params[:visited_at] || Time.now.utc,
                status: if (counts["red"] || 0) > 0
                          "red"
                        elsif (counts["yellow"] || 0) > 0
                          "yellow"
                        elsif (counts["green"] || 0) > 0
                          "green"
                        else
                          "green"
                        end
              }
              @house.update!(result)
              @visit.update!(status: colors[result[:status]])
            elsif @inspections.empty? && @visit.visit_permission
              @house.update!(infected_containers: 0, potential_containers: 0,
                             non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                             status: 'green')
              @visit.update!(status: 'Verde')
            else
              @house.update!(infected_containers: 0, potential_containers: 0,
                             non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                             status: 'red')
              @visit.update!(status: 'Rojo')
            end
          end

          def update_house_status_daily
            house = @house
            house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: @visit.visited_at)
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

          def manage_photo(inspection)
            if @photo && !@delete_photo
              inspection.photo = @photo
            end
            if @delete_photo && !@has_photo
              inspection.photo.purge
            end
            inspection
          end

          def analyze_inspection_status(inspection, type_content_id = [])
            type_content_id ||= []
            type_content_id.map!(&:to_i)
            container_protection_ids = ContainerProtection.where(name_es: ['Tapa no hermética', 'Si, tiene tapa pero no está bien cerrado', 'Techo', 'Otro', 'No tiene']).pluck(:id)
            ids_red_cases = TypeContent.where(name_es: %w[Larvas Pupas Huevos]).pluck(:id)

            return 'green' if type_content_id.nil? || type_content_id.blank?
            return 'green' if TypeContent.find_by(id: type_content_id).name_es == 'Nada' && !inspection[:container_protection_id].in?(container_protection_ids)

            return 'red' if (ids_red_cases & type_content_id).any? if type_content_id.any?
            return 'yellow' if (ids_red_cases & type_content_id).none? && inspection[:container_protection_id].in?(container_protection_ids)
            return 'yellow' if  inspection[:has_water] && !inspection[:container_protection_id].in?(container_protection_ids)

            'green'

          end

          def container_status_analyzer(inspection)
            return Constants::ContainerStatus::NOT_INFECTED unless inspection.has_water
            return Constants::ContainerStatus::INFECTED if inspection.infected?

            Constants::ContainerStatus::POTENTIALLY_INFECTED if inspection.potential?
          end
        end
      end
    end
  end
end
