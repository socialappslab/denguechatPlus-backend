# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_inspection
          step :set_language

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def find_inspection
            @ctx[:data] = Api::V1::Inspections::Queries::Show.call(@params)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
            end
          end

          def set_language
            @ctx[:data].define_singleton_method(:language) { @language }
            @ctx[:data].define_singleton_method(:language=) { |value| @language = value }
            @ctx[:data].language = if @params.key?(:language) && @params[:language].in?(%w[en es pt])
                                     @params[:language]
                                   else
                                     'es'
                                   end
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
