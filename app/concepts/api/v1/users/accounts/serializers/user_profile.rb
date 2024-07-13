# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class UserProfile < ApplicationSerializer
            set_type :user_profile

            attributes :id, :first_name, :last_name, :gender,
                       :points, :language, :timezone, :email

            attribute :city do |user_profile|
              user_profile.city.name
            end

            attribute :neighborhood do |user_profile|
              user_profile.neighborhood&.name
            end

            attribute :organization do |user_profile|
              user_profile.organization&.name
            end

            attribute :team do |user_profile|
              user_profile.team&.name
            end

          end
        end
      end
    end
  end
end
