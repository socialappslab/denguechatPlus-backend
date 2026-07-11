# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Serializers
        class Index < ApplicationSerializer
          set_type :HouseBlock

          attributes :id, :name

          attribute :wedge do |house_block|
            next if house_block.wedges.blank?

            wedges = house_block.wedges.sort_by(&:external_id)
            {
              id: wedges&.first&.id,
              name: wedges&.pluck(:name)&.join(', ')
            }
          end

          attribute :houses do |house_block|
            next if house_block.houses.blank?

            house_block.houses.map do |house|
              {
                id: house.id,
                reference_code: house.reference_code
              }
            end
          end

          attribute :type, &:block_type
        end
      end
    end
  end
end
