# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Serializers
        class Index < ApplicationSerializer
          set_type :special_place

          attributes :name, :created_at

          attribute :status do |special_place|
            special_place.discarded_at.nil?
          end
        end
      end
    end
  end
end
