# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Destroy < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)

          end


          rule(:id) do
            visit_exists = ::Visit.find_by(id: value).present?
            unless visit_exists
              key(:id).failure(text: 'The visit not exists',
                                     predicate: :not_exists?)
            end
          end

        end
      end
    end
  end
end
