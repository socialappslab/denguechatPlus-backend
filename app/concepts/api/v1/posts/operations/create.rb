# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :transform_params
          step :create_post

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Posts::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def transform_params
            team = @current_user.teams.first
            team_sector = team&.sector&.name || ''
            @data = @ctx['contract.default'].values.data
            @data[:team_id] = team.id
            @data[:city_id] = @current_user.city_id
            @data[:neighborhood_id] = @current_user.neighborhood_id
            @data[:country_id] = Neighborhood.find_by(id: @data[:neighborhood_id]).country.id
            @data[:location] = "#{team_sector}, #{team.city.name}"
          end

          def create_post
            begin
              @ctx[:model] = Post.create(@data)
              @ctx[:model].instance_variable_set(:@current_user_id, @current_user.id)
              Success({ ctx: @ctx, type: :created })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end
        end
      end
    end
  end
end
