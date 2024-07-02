# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Paginates
        class Contract < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:page).hash do
              required(:number).filled(:integer, gteq?: 1)
              required(:size).filled(:integer, gteq?: 1)
            end
          end
        end
      end
    end
  end
end
