# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Index < ApplicationSerializer
          set_type :team

          attributes :name
          has_many :team_members, serializer: Member

        end
      end
    end
  end
end
