# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          Container = Struct.new(:has_water, :visit_id, :was_chemically_treated, :breeding_site_type_id,
                                 :elimination_method_type_id, :water_source_type_id, :lid_type, :code_reference, :container_test_result,
                                 :tracking_type_required, :created_by_id, :treated_by_id, :water_source_other, :lid_type_other,
                                 :container_protection_ids, :other_protection, :other_elimination_method, :type_content_id, keyword_init: true)

          step :check_request_attrs
          tee :params
          tee :depurate_inspection_list
          step :validate_schema
          tee :split_data
          step :create_house_if_necessary
          step :add_team
          step :create_visit
          tee :set_extra_info_to_inspections
          step :create_inspections
          tee :add_photos
          tee :update_house_status
          tee :create_house_status_daily
          tee :set_language
          tee :manage_points


          def check_request_attrs(input)
            unless input.dig(:params, :json_params)
              ctx = {}
              ctx['errors'] = ErrorFormater.new_error(field: :base, msg: 'json_params not found', custom_predicate: :not_found? )

              return Failure({ ctx: ctx, type: :invalid })
            end

            Success({ ctx: input, type: :success })
          end

          def params(input)
            @ctx = {}
            input = input[:ctx]
            if input[:params][:photos]
              @photos = input[:params][:photos]
            end
            params = input[:params][:json_params]
            params_json = JSON.parse(params)
            @params = to_snake_case(params_json)
            @params[:questionnaire_id] ||= Questionnaire.last.id || 1
            @current_user = input[:current_user]
          end

          def depurate_inspection_list
            if @params.key?('inspections')
              inspections = @params['inspections']
              inspections.reject! do |inspection|
                (inspection.keys - %w[quantity_founded status_color]).empty?
              end
              @params['inspections'] = inspections
            end
            @params.delete('inspections') if @params.key?('inspections') && @params['inspections']&.empty?
          end



          def validate_schema
            @ctx['contract.default'] = Api::V1::Visits::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?

            if is_valid
              @params = @ctx['contract.default'].values.data
              return Success({ ctx: @ctx, type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid })
          end

          def split_data
            @house_info = @params.delete(:house)&.deep_symbolize_keys unless @params.key?(:house_id)
            @inspections = @params.delete(:inspections)&.map(&:deep_symbolize_keys) if @params.key?(:inspections)
          end
          def create_house_if_necessary
            return existing_house_result if params_include_house?

            @params[:house_id] = find_similar_or_create_house_id
            Success({ ctx: @ctx, type: :success })
          end

          def add_team
            return Success({ ctx: @ctx, type: :success }) if @params[:team_id]&.present?
            return nil unless @current_user.teams.any?

            @params[:team_id] = @current_user.teams.first.id
            Success({ ctx: @ctx, type: :success })
          end

          def create_visit
            hosts = @params.delete(:host)
            if hosts
              @params[:host] = hosts.join(', ')
            end
            begin
              @ctx[:model] = Visit.create!(@params)
              Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def set_extra_info_to_inspections
            @inspections&.map do |inspection|
              inspection[:created_by_id] = @current_user.id
              inspection[:treated_by_id] = @current_user.id
              inspection[:visit_id] = @ctx[:model].id
            end
          end

          def create_inspections
            return Success({ ctx: @ctx, type: :created }) if @inspections.nil? || @inspections&.empty?

            container_attrs = Container.members
            inspections_clean_format = []
            @photo_ids = []
            visit_id = @ctx[:model].id
            @inspections&.each do |inspection|
              @photo_ids << {code_reference: inspection[:code_reference], photo_id: inspection[:photo_id]} if inspection[:photo_id].present?
              if inspection[:quantity_founded]
                inspection[:quantity_founded] = inspection[:quantity_founded].to_i
                inspection[:quantity_founded].times do
                  inspection[:visit_id] = visit_id
                  inspections_clean_format_object = Container.new(inspection.slice(*container_attrs)).to_h
                  inspections_clean_format_object.delete(:container_protection_ids) if inspections_clean_format_object[:container_protection_ids].nil?
                  inspections_clean_format << inspections_clean_format_object
                end
              end
            end
            if inspections_clean_format.any?
              inspections_clean_format.each do |inspection_data|
                type_content_id = inspection_data.delete(:type_content_id) if inspection_data.key?(:type_content_id)
                inspection_data[:color] = analyze_inspection_status(inspection_data, type_content_id)

                inspection = Inspection.create!(inspection_data)

                if type_content_id
                  type_content = TypeContent.find_by(id: type_content_id)
                  inspection.type_contents << type_content
                end
              end

            end
            Success({ ctx: @ctx, type: :created })
          end



          def add_photos
            return true if  @photo_ids.nil? || @photo_ids.blank? || @photos.nil? || @photos.blank?

            @photo_ids.each do |obj|
              inspection = Inspection.find_by(code_reference: obj[:code_reference])
              next unless inspection

              photo = @photos.select { |file| file.original_filename == "#{inspection.code_reference}.#{file.content_type.split('/').last}" }
              next if photo.blank?

              inspection.photo.attach(photo.first)
            end
          end


          private

          def generate_code(country, state, city, wedge, block)
            country_name = country.name[0..1]
            state_name = state.name[0..1]
            city_name = city.name[0..1]
            wedge_name = wedge.name.last(4).delete(' ')
            block_name = block.name.last(4).delete(' ')
            rand_number = Time.now.to_i.to_s
            last_id = House.last&.id || 1
            last_id + 1
          end

          def params_include_house?
            @params[:house_id].present?
          end

          def existing_house_result
            @house = House.find_by(id: @params[:house_id])
            Success({ ctx: @ctx, type: :success })
          end

          def find_similar_or_create_house_id
            @house = House.find_by(reference_code: @house_info[:reference_code])
            return @house&.id if @house

            # similar_house = Api::V1::Visits::Services::HouseFinderByCoordsService.find_similar_house(latitude: @house_info[:latitude],
            #                                                                                          longitude: @house_info[:longitude],
            #                                                                                          house_block_id: @house_info[:house_block_id])

            @house =  create_and_get_house_id

            @house.id
          end

          def create_and_get_house_id
            house_block = HouseBlock.find_by(id: @house_info[:house_block_id])
            team =  @current_user.teams&.first
            wedge = team.wedge
            neighborhood = team.sector
            city = neighborhood.city
            state = neighborhood.state
            country = neighborhood.country
            user_profile = @current_user.user_profile
            reference_code = @house_info[:reference_code] || generate_code(country, state, city, wedge, house_block)
            location_status = @house_info[:latitude] && @house_info[:longitude] ? 'with_coordinates' : 'without_coordinates'
            @house_info[:latitude] = @house_info[:latitude] || -3.775520
            @house_info[:longitude] = @house_info[:longitude] || -73.450878

            @house_info[:country_id] = country.id
            @house_info[:state_id] = state.id
            @house_info[:city_id] = city.id
            @house_info[:neighborhood_id] = neighborhood.id
            @house_info[:wedge_id] = wedge.id
            @house_info[:house_block_id] = house_block.id
            @house_info[:team_id] = team.id
            @house_info[:user_profile_id] = user_profile.id
            @house_info[:reference_code] = reference_code
            @house_info[:location_status] = location_status


            @house = House.create!(@house_info)
          end

          def update_house_status
            colors = {
              'red' => 'Rojo',
              'yellow' => 'Amarillo',
              'green' => 'Verde'
            }
            inspections_ids = @ctx[:model].inspections.pluck(:id)
            if !inspections_ids.empty?
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
              result[:tariki_status] = @house.is_tariki?
              @house.update!(result)
              @ctx[:model].update!(status: colors[result[:status]])
              elsif inspections_ids.empty? && @params[:visit_permission]
                @house.update!(infected_containers: 0, potential_containers: 0,
                               non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                               status: 'green')
                @ctx[:model].update!(status: 'Verde')
            else
              @house.update!(infected_containers: 0, potential_containers: 0,
                             non_infected_containers: 0, last_visit:  @params[:visited_at] || Time.now.utc,
                             status: 'red')
              @ctx[:model].update!(status: 'Rojo')
            end
          end

          def create_house_status_daily
            team_id = @current_user.teams&.first&.id || Team.first.id
            house = @house
            house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: @ctx[:model].visited_at)
            house_status.date = @ctx[:model].visited_at
            house_status.infected_containers = house.infected_containers
            house_status.non_infected_containers = house.non_infected_containers
            house_status.potential_containers = house.potential_containers
            house_status.city_id = house.city_id
            house_status.country_id = house.country_id
            house_status.house_block_id = house.house_block_id
            house_status.neighborhood_id = house.neighborhood_id
            house_status.team_id = team_id
            house_status.wedge_id = house.wedge_id
            house_status.last_visit = house.last_visit
            house_status.house_id = house.id
            house_status.status = house.status
            house_status.save
          end

          def analyze_inspection_status(inspection, type_content_id = [])
            return 'green' unless inspection[:has_water]

            results = Option.joins(:question)
                  .where(
                    "(questions.resource_name = 'type_content_id' AND options.resource_id IN (?))
                     OR (questions.resource_name = 'container_protection_ids' AND options.resource_id IN (?))",
                    type_content_id, inspection[:container_protection_ids]
                  )
                  .group(:status_color)
                  .sum(:weighted_points)

            results.key(results.values.max)&.downcase || 'green'
          end

          def container_status_analyzer(inspection)
            return Constants::ContainerStatus::NOT_INFECTED unless inspection.has_water
            return Constants::ContainerStatus::INFECTED if inspection.infected?

            Constants::ContainerStatus::POTENTIALLY_INFECTED if inspection.potential?
          end

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

          def manage_points
            Api::V1::Points::Services::Transactions.assign_point(earner: @current_user, house_id: @house.id, visit_id: @ctx[:model].id) if @house.is_tariki?
            Api::V1::Points::Services::Transactions.remove_point(earner: @current_user, house_id: @house.id, visit_id: @ctx[:model].id) unless @house.is_tariki?
          end

        end
      end
    end
  end
end
