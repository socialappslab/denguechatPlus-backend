# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:role_permissions_attributes).array(:hash) do
              optional(:permission_id).filled(:integer)
              optional(:_destroy).filled(:integer)
            end
          end

          rule(:name) do
            if values[:name] && !values[:name].blank? && Role.exists?(name: values[:name].downcase)
              key(:name).failure(text: 'Role name is used, please choose other name', predicate: :unique?)
              end
          end
          rule(:id) do
            key(:id).failure('Role not exists') if values[:id] && !Role.kept.exists?(id: values[:id])
          end

          rule(:role_permissions_attributes).each do
            key(:permission_id).failure('permission not exists') if value[:id] && !Permission.exists?(id: value[:id])
          end
        end
      end
    end
  end
end
