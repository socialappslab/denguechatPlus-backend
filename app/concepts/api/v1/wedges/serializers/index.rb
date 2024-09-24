# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Serializers
        class Index < ApplicationSerializer
          set_type :wedge

          attributes :name

          attribute :sector do |wedge|
            next if wedge.sector.nil?

            {
              id: wedge.sector.id,
              name: wedge.sector.name
            }
          end
        end
      end
    end
  end
end
