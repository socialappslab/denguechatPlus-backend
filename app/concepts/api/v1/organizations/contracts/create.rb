# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Contracts
        class Create < ApplicationReformContract

          property :name, virtual: true

          validation do
            params do
              required(:name).filled(:string)
            end

          end
        end
      end
    end
  end
end
