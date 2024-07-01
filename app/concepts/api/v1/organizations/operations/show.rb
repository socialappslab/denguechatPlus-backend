# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_organization

          def params(input)
            @ctx = {}
            @params = input.fetch(:params)
          end

          def find_organization
            @ctx[:data] = Organization.find_by(id: @params[:id])
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
