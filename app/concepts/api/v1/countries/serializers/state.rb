# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Serializers
        class State < ApplicationSerializer
          set_type :state

          attributes :name
        end
      end
    end
  end
end
