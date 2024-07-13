# frozen_string_literal: true

module Api
  module V1
    module Roles
      module Serializers
        class Index < ApplicationSerializer
          set_type :roles

          attributes :id, :name
          #          has_many :permissions, serializer: Permission

          attribute :permissions do |role|
            Permission.new(role.permissions)
          end
        end
      end
    end
  end
end
