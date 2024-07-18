# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :create_rol

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Roles::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def add_permissions
            return nil unless @params.key? 'role_permissions_attributes'

            data = @ctx['contract.default'].values.data[:role_permissions_attributes].pluck(:permission_id)
            permission_ids = data - @ctx[:model].permissions.pluck(:id)
            @ctx[:model].permissions << Permission.where(id: permission_ids) if permission_ids&.any?
          end

          def create_rol
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model] = Role.create(@ctx['contract.default'].values.data)
                raise ActiveRecord::RecordInvalid, @ctx[:model] unless @ctx[:model].persisted?

                Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => invalid
                errors = ErrorFormater.new_error(field: :base, msg: @ctx[:model].errors.full_messages.join(' '), custom_predicate: :credentials_wrong?)
                Failure({ ctx: @ctx, type: :invalid, errors: errors })
              end
            end
          end


        end
      end
    end
  end
end
