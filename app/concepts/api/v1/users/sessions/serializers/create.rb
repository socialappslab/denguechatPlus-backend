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
                       :email,
                       :gender,
                       :phone_number,
                       :points,
                       :country,
                       :city,
                       :timezone,
                       :language
          end
        end
      end
    end
  end
end
