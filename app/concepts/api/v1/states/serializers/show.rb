# frozen_string_literal: true

module Api
  module V1
    module States
      module Serializers
        class Show < ApplicationSerializer
          set_type :state

          attributes :name

          attributes :cities do |state|
            next unless state.cities.any?

            state.cities.each do |city|
              {
                id: city.id,
                name: city.name
              }
            end
          end
        end
      end
    end
  end
end
