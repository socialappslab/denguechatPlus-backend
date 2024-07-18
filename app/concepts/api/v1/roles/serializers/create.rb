# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Serializers
        class Create < ApplicationSerializer
          set_type :roles

          attributes :id, :name

          attribute :permissions do |role|
            Permission.new(role.permissions)
          end
        end
      end
    end
  end
end
