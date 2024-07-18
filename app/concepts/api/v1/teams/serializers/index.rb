# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Index < ApplicationSerializer
          set_type :team

          attributes :name
          has_many :user_profiles, serializer: UserProfile
          belongs_to :organization, serializer: Api::V1::Organizations::Serializers::Show

        end
      end
    end
  end
end
