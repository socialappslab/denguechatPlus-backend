# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Serializers
        class Index < ApplicationSerializer
          set_type :country

          attributes :name
        end
      end
    end
  end
end
