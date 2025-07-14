# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Serializers
          class Organization < ApplicationSerializer
            set_type :organization

            attributes :name
          end
        end
      end
    end
  end
end
