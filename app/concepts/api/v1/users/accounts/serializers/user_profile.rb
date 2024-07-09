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
            end
          end
        end
      end
    end
  end
