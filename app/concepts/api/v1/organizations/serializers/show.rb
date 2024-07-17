# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Serializers
        class Show < ApplicationSerializer
          set_type :organization

          attributes :name, :created_at

          attribute :status do |organization|
            organization.discarded_at.nil?
          end
        end
      end
    end
  end
end
