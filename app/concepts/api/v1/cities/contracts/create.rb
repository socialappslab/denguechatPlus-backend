module Api
  module V1
    module Cities
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
            required(:country_id).filled(:string)
            required(:state_id).filled(:string)
            optional(:neighborhoods_attributes).array(:hash) do
              optional(:name).filled(:string)
            end
          end

          rule(:neighborhoods_attributes) do
            if value.is_a?(Array)
              value.each do |city|
                city[:country_id] = values[:country_id].to_s
                city[:state_id] = values[:state_id].to_s

              end
            end
          end
        end
      end
    end
  end
end
