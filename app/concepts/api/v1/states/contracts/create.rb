module Api
  module V1
    module States
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
            required(:country_id).filled(:string)
            optional(:cities_attributes).array(:hash) do
              optional(:name).filled(:string)
            end
          end

          rule(:cities_attributes) do
            if value.is_a?(Array)
              value.each do |city|
                city[:country_id] = values[:country_id].to_s
              end
            end
          end
        end
      end
    end
  end
end
