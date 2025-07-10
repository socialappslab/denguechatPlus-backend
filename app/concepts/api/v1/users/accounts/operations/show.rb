# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Show < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :find_user

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end

            def find_user
              @ctx[:data] = UserProfile.find_by(id: @params[:id])
              if @ctx[:data].nil?
                Failure({ ctx: @ctx, type: :not_found,
                          errors: ErrorFormater.new_error(field: :base, msg: 'not found', custom_predicate: :not_found?) })

              else
                Success({ ctx: @ctx, type: :success })
              end
            end
          end
        end
      end
    end
  end
end
