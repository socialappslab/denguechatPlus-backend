# frozen_string_literal: true

module Api
  module V1
    module Permissions
      module Serializers
        class Index < ApplicationSerializer
          set_type :permissions

          attributes :id, :name, :resource
        end
      end
    end
  end
end
