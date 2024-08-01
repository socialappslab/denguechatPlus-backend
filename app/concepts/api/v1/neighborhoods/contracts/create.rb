module Api
  module V1
    module Neighborhoods
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
            required(:country_id).filled(:integer)
            required(:state_id).filled(:integer)
            required(:city_id).filled(:integer)
          end

          rule :country_id do
            unless Country.exists?(id: value)
              key(:country_id).failure(text: 'Country should existx',
                                       predicate: :credentials_wrong?)
            end
          end

          rule :state_id do
            unless State.exists?(id: value)
              key(:state_id).failure(text: 'State should existx',
                                     predicate: :credentials_wrong?)
            end
          end

          rule :city_id do
            unless City.exists?(id: value)
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
            Neighborhood.exists?(name: name, country_id: values[:country_id], state_id: values[:state_id], city_id: values[:city_id])
          end
        end
      end
    end
  end
end
