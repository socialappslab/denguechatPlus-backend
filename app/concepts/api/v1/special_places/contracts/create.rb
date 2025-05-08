# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            optional(:name).filled(:string)
            optional(:name_es).filled(:string)
            optional(:name_en).filled(:string)
            optional(:name_pt).filled(:string)
          end

          rule(:name) do
            if SpecialPlace.exists?(name: values['name'].downcase)
              key(:name).failure(text: 'The special place name is used, please choose another name',
                                 predicate: :unique?)
            end
          end
        end
      end
    end
  end
end
