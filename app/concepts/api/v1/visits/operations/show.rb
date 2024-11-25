# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_post

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def find_post
            @ctx[:data] = Api::V1::Visits::Queries::Show.call(@params)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              @ctx[:data].define_singleton_method(:language) { @language }
              @ctx[:data].define_singleton_method(:language=) { |value| @language = value }
              @ctx[:data].language = "en"
              Success({ ctx: @ctx, type: :success })
            end
          end
        end
      end
    end
  end
end
