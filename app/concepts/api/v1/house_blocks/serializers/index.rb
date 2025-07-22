# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Serializers
        class Index < ApplicationSerializer
          set_type :HouseBlock

          attributes :id, :name

          attribute :team do |house_block|
            next unless house_block.team

            house_block.team&.name
          end

          attribute :neighborhood do |house_block|
            next unless house_block.neighborhood

            {
              id: house_block.neighborhood&.id,
              name: house_block.neighborhood&.name
            }
          end

          attribute :wedge do |house_block|
            next if house_block.wedges.blank?

            wedges = house_block.wedges.sort_by(&:external_id)
            {
              id: wedges&.first&.id,
              name: wedges&.pluck(:name)&.join(', ')
            }
          end

          attribute :in_use do |house_block|
            !house_block.brigadist.nil?
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

          attribute :brigadist do |house_block|
            "#{house_block.brigadist&.first_name}, #{house_block.brigadist&.last_name}"
          end

          attribute :type, &:block_type
        end
      end
    end
  end
end
