# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Serializers
        class Index < ApplicationSerializer
          set_type :wedge

          attributes :name

          attribute :sectors do |wedge|
            next if wedge.neighborhoods.blank?

            wedge.neighborhoods.map do |sector|
              {
                id: sector.id,
                name: sector.name
              }
            end
          end
        end
      end
    end
  end
end
