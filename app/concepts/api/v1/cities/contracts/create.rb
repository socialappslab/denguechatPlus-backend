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


          rule(:neighborhoods_attributes).each do
            if value[:id] && Neighborhood.exists?(id: values[:id], discarded_at: nil)
              key.failure('Neighborhood already exists in this city')
            end
          end

          rule(:state_id) do
            unless State.exists?(id: value)
              key(:state_id).failure(text: "The state with id: #{value} does not exist",
                                 predicate: :not_exists?)
            end
          end

        end
      end
    end
  end
end
