# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          Container = Struct.new(:has_water, :visit_id, :was_chemically_treated, :breeding_site_type_id,
                                 :elimination_method_type_id, :water_source_type_id, :lid_type, :code_reference, :container_test_result, :tracking_type_required, :created_by_id, :treated_by_id, :water_source_other, :lid_type_other, keyword_init: true)


          tee :params
          step :validate_schema
          tee :split_data
          step :create_house_if_necessary
          step :add_team
          step :create_visit
          tee :set_extra_info_to_inspections
          step :create_inspections

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
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
            @house_info = @params.delete(:house) unless @params.key?(:house_id)

            @inspections = @params.delete(:inspections) if @params.key?(:inspections)
          end

          def create_house_if_necessary
            return existing_house_result if params_include_house?

            @params[:house_id] = find_similar_or_create_house_id
            Success({ ctx: @ctx, type: :success })
          end

          def add_team
            return  Success({ ctx: @ctx, type: :success }) if @params[:team_id]&.present?
            return nil unless @current_user.teams.any?

            @params[:team_id] = @current_user.teams.first.id
            Success({ ctx: @ctx, type: :success })
          end

          def create_visit
            begin
              @ctx[:model] = Visit.create(@params)
              Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def set_extra_info_to_inspections
            @inspections.map do |inspection|
              inspection[:created_by_id] = @current_user.id
              inspection[:treated_by_id] = @current_user.id
              inspection[:visit_id] = @ctx[:model].id

            end
          end

          def create_inspections
            container_attrs = Container.members
            inspections_clean_format = []
            visit_id = @ctx[:model].id
            @inspections.each do |inspection|
              inspection[:quantity_founded].times do
                inspection[:visit_id] = visit_id
                inspections_clean_format << Container.new(inspection.slice(*container_attrs)).to_h
              end
            end
            Inspection.insert_all(inspections_clean_format) if inspections_clean_format.any?
            Success({ ctx: @ctx, type: :created })
          end


          private

          def generate_code(country, state, city, wedge, block)
            country_name = country.name[0..1]
            state_name = state.name[0..1]
            city_name = city.name[0..1]
            wedge_name = wedge.name.last(4).delete(' ')
            block_name = block.name.last(4).delete(' ')
            rand_number = Time.now.to_i.to_s

            "#{country_name}-#{state_name}-#{city_name}-#{wedge_name}-#{block_name}-#{rand_number}"
          end

          def params_include_house?
            @params[:house_id].present?
          end

          def existing_house_result
            @house = House.find_by(id: @params[:house_id])
            Success({ ctx: @ctx, type: :success })
          end

          def find_similar_or_create_house_id
            similar_house = Api::V1::Visits::Services::HouseFinderByCoordsService.find_similar_house(latitude: @house_info[:latitude],
                                                                                                     longitude: @house_info[:longitude],
                                                                                                     house_block_id: @house_info[:house_block_id])

            similar_house ? similar_house.id : create_and_get_house_id
          end

          def create_and_get_house_id
            house_block = HouseBlock.find_by(id: @house_info[:house_block_id])
            wedge = house_block.wedge
            neighborhood = wedge.sector
            city = neighborhood.city
            state = neighborhood.state
            country = neighborhood.country
            team =  @current_user.teams&.first
            user_profile = @current_user.user_profile
            reference_code = generate_code(country, state, city, wedge, house_block)

            @house_info[:country_id] = country.id
            @house_info[:state_id] = state.id
            @house_info[:city_id] = city.id
            @house_info[:neighborhood_id] = neighborhood.id
            @house_info[:wedge_id] = wedge.id
            @house_info[:house_block_id] = house_block.id
            @house_info[:team_id] = team.id
            @house_info[:user_profile_id] = user_profile.id
            @house_info[:reference_code] = reference_code


            @house = House.create(@house_info).id
          end
        end
      end
    end
  end
end
