# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
          end

          rule(:name) do
            if Organization.exists?(name: values['name'].downcase)
              key(:name).failure(text: 'The organization name is used, please choose another name',
                                 predicate: :unique?)
            end
          end
        end
      end
    end
  end
end
