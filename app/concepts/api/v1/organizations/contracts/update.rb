# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Contracts
        class Update < ApplicationReformContract

          property :id, virtual: true
          property :name, virtual: true

          validation do
            params do
              required(:id).filled(:integer)
              required(:name).filled(:string)
            end

          end
        end
      end
    end
  end
end
