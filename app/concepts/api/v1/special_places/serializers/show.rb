# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Serializers
        class Show < ApplicationSerializer
          set_type :special_place

          attributes :name, :name_en, :name_pt, :created_at

          attribute :status do |special_place|
            special_place.discarded_at.nil?
          end
        end
      end
    end
  end
end
