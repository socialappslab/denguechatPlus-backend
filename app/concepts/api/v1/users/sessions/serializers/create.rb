# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Serializers
          class Create < ApplicationSerializer
            set_type :user_profile

            attributes :first_name,
                       :last_name,
                       :phone,
                       :gender,
                       :points,
                       :timezone,
                       :language,
                       :email
            has_one :city, serializer: City
            has_one :neighborhood, serializer: Neighborhood
            has_one :organization, serializer: Organization

            attribute :roles do |user_account|
              user_account.roles.map { |rol| rol.name }
            end

            attribute :permissions do |user_account|
              user_account.permissions.map { |permission| "#{permission.resource}_#{permission.name}" }
            end
          end
        end
      end
    end
  end
end
