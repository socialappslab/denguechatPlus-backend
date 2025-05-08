# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Serializers
        class Show < ApplicationSerializer
          set_type :HouseBlock

          attributes :id, :name

          attribute :houses do |house_block|
            next unless house_block.houses.any?

            house_block.houses.map do |house|
              {
                id: house.id,
                reference: house.reference_code
              }
            end
          end
        end
      end
    end
  end
end
