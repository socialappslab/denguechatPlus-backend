# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class UserAccount < ApplicationSerializer
            set_type :user_account

            attributes :id, :email, :username, :phone, :confirmed_at
            belongs_to :user_profile, serializer: Api::V1::Users::Accounts::Serializers::UserProfile, include: true

          end
        end
      end
    end
  end
end
