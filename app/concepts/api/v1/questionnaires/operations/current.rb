# frozen_string_literal: true

module Api
  module V1
    module Questionnaires
      module Operations
        class Current < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_questionnaire

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def find_questionnaire
            @ctx[:data] = Questionnaire.find_by(current_form: true)
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              Success({ ctx: @ctx, type: :success })
            end
          end
        end
      end
    end
  end
end
