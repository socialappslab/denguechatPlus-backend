# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:country_id).filled(:integer)
            optional(:state_id).filled(:integer)
            optional(:city_id).filled(:integer)

          end

          rule :country_id do
            if value && Country.exists?(id: value)
              key(:country_id).failure(text: 'Country should existx',
                                       predicate: :credentials_wrong?)
            end
          end

          rule :state_id do
            if value && State.exists?(id: value)
              key(:state_id).failure(text: 'State should existx',
                                     predicate: :credentials_wrong?)
            end
          end

          rule :city_id do
            if value && City.exists?(id: value)
              key(:city_id).failure(text: 'City should existx',
                                    predicate: :credentials_wrong?)
            end
          end

          rule(:name) do
            if !values[:name].nil? && values[:name].blank?
              key(:name).failure(text: "Name can't be null", predicate: :credentials_wrong?)
            elsif values[:name] && repeated_name?(value, values)
              key(:username).failure(text: 'The neighboorhood name already used', predicate: :user_username_unique?)
            end
          end

          private

          def repeated_name?(name, values)
            Neighborhood.where.not(id: values[:id]).exists?(name: name, country_id: values[:country_id], state_id: values[:state_id], city_id: values[:city_id])
          end

        end
      end
    end
  end
end
