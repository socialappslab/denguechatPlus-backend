# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Serializers
        class ListByIquitosLocation < ApplicationSerializer
          set_type :city

          attributes :name

        end
      end
    end
  end
end
