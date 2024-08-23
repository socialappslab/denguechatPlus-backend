# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Serializers
        class Show < ApplicationSerializer
          set_type :country

          attributes :name
        end
      end
    end
  end
end
