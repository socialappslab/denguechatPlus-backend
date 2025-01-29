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
            next unless house_block.wedge

            {
              id: house_block.wedge&.id,
              name: house_block.wedge&.name
            }
          end

          attribute :in_use do |house_block|
            !house_block.brigadist.nil?
          end

          attribute :house_ids do |house_block|
            house_block.houses&.pluck(:id)&.compact
          end

          attribute :brigadist do |house_block|
            "#{house_block.brigadist&.first_name}, #{house_block.brigadist&.last_name}"
          end
        end
      end
    end
  end
end
