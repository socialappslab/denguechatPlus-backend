# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class UserProfile < ApplicationSerializer
            set_type :user_profile

            attributes :id, :first_name, :last_name, :gender, :phone_number, :slug,
                       :points, :country, :city, :language, :timezone

            end
          end
        end
      end
    end
  end
