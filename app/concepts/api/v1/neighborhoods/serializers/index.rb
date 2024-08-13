# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Serializers
        class Index < ApplicationSerializer
          set_type :neighborhood

          attributes :name

          attribute :wedges do |neigborhood|
            next if neigborhood&.wedges.nil? || neigborhood&.wedges.empty?
            neigborhood.wedges.map do |wedge|
              {
                id: wedge.id,
                name: wedge.name
              }
            end
          end

        end
      end
    end
  end
end
