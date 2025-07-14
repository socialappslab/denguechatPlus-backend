# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Serializers
        class Permission < ApplicationSerializer
          set_type :permission

          attributes :id, :name, :resource
        end
      end
    end
  end
end
