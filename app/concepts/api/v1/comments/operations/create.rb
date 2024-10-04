# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_comment

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Comments::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def create_comment
            begin
              @ctx[:model] = Comment.create(@ctx['contract.default'].values.data)
              @ctx[:model].instance_variable_set(:@current_user_id, @current_user.id)
              return Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :user_account_without_confirmation? )

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end
        end
      end
    end
  end
end
