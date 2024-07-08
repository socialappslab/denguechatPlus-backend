# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Serializers
        class Index < ApplicationSerializer
          set_type :organization

          attributes :name
        end
      end
    end
  end
end
