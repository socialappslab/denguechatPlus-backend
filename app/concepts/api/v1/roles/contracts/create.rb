# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:name).filled(:string)
            optional(:permission_ids).filled(:array).each(:integer)
          end

          rule(:name) do
            if values[:name] && !values[:name].blank? && Role.exists?(name: values[:name].downcase)
              key(:name).failure(text: 'Role name is used, please choose other name', predicate: :unique?)
              end
          end

          rule(:permission_ids).each do
            if values[:permission_ids] && !Permission.exists?(id: values[:permission_ids])
              key(:permission_ids).failure(text: 'Permission not found', predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end