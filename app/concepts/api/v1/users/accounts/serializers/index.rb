# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class Index < ApplicationSerializer
            set_type :user

            attributes :id,
                       :username,
                       :phone,
                       :status,
                       :email,
                       :first_name,
                       :last_name,
                       :organization_name,
                       :city_name,
                       :neighborhood_name,
                       :team_name
          end
        end
      end
    end
  end
end
