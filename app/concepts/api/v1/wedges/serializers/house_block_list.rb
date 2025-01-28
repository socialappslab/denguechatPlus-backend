# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Serializers
        class HouseBlockList < ApplicationSerializer
          set_type :wedge

          attributes :name

          attribute :house_blocks do |wedge|
            next if wedge.house_blocks.blank?

            wedge.house_blocks.map do |house_block|
              sector_name = house_block.neighborhood.name if house_block.neighborhood
              {
                id: house_block.id,
                name: house_block.name,
                sector_name:
              }
            end
          end
        end
      end
    end
  end
end
