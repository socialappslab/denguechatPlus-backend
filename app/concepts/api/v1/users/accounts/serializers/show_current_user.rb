# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class ShowCurrentUser < ApplicationSerializer
            set_type :user

            attributes :id, :username, :status


            has_one :user_profile, record_type: :user_profile, serializer: Api::V1::Users::Accounts::Serializers::UserProfile

            attribute :roles do |user_account|
              user_account.roles.map { |rol| rol.name }.join(' ')
            end

            attribute :permissions do |user_account|
              user_account.permissions.map { |permission| "#{permission.resource}_#{permission.name}" }.join(' ')
            end

          end
        end
      end
    end
  end
end
