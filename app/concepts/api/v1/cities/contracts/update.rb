# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            required(:state_id).filled(:integer)
            required(:country_id).filled(:integer)
            optional(:name).filled(:string)
            optional(:neighborhoods_attributes).filled(:array)
          end

          rule(:country_id) do
            next if Country.kept.exists?(id: values[:country_id])

            key(:name).failure(text: 'Country not exists', predicate: :not_found?)
          end

          rule(:state_id) do
            next if State.kept.exists?(id: values[:state_id], country_id: values[:country_id])

            key(:name).failure(text: 'State not exists', predicate: :not_found?)
          end

          rule(:id) do
            next if City.kept.exists?(country_id: values[:country_id], state_id: values[:state_id],
                                      id: values[:id])

            key(:name).failure(text: 'City not exists', predicate: :not_found?)
          end

          rule(:name) do
            next unless values[:name] && City.exists?(name: values[:name].downcase, state_id: values[:state_id],
                                                      discarded_at: nil)

            key(:name).failure(text: 'City already exists in this state',
                               predicate: :unique?)
          end

          rule(:neighborhoods_attributes).each do
            next unless values[:neighborhoods_attributes] && Neighborhood.exists?(name: values[:name].downcase,
                                                                                  city_id: values[:city_id],
                                                                                  discarded_at: nil)

            key(:name).failure(text: 'Neighborhood already exists in this city',
                               predicate: :unique?)
          end
        end
      end
    end
  end
end
