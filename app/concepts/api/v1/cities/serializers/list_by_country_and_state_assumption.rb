# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Serializers
        class ListByCountryAndStateAssumption < ApplicationSerializer
          set_type :city

          attributes :name
        end
      end
    end
  end
end
