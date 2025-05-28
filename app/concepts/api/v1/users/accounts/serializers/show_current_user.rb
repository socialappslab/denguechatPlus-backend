# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class ShowCurrentUser < ApplicationSerializer
            set_type :user

            attributes :id, :username, :phone, :status


            has_one :user_profile, record_type: :user_profile, serializer: Api::V1::Users::Accounts::Serializers::UserProfile

            attribute :roles do |user_account|
              next unless user_account.roles.any?

              user_account.roles.map { |rol| rol.name }
            end

            attribute :permissions do |user_account|
              next unless user_account.permissions.any?

              user_account.permissions.map { |permission| "#{permission.resource}-#{permission.name}" }
            end

          end
        end
      end
    end
  end
end
