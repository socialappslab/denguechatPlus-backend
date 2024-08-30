# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class UserProfile < ApplicationSerializer
            set_type :user_profile

            attributes :id, :first_name, :last_name,
                       :points, :email

            attribute :city do |user_profile|
              next if user_profile.city.nil?

              user_profile.city.name
            end

            attribute :neighborhood do |user_profile|
              next if user_profile.neighborhood.nil?

              user_profile.neighborhood&.name
            end

            attribute :organization do |user_profile|
              next if user_profile.organization.nil?

              user_profile.organization&.name
            end

            attribute :team do |user_profile|
              next if user_profile.team.nil?

              user_profile.team&.name
            end

            attribute :house_block do |user_profile|
              next if user_profile.house_blocks.blank?

              {
                id: user_profile.house_blocks.first.id,
                name: user_profile.house_blocks.first.name,
                house_ids: Api::V1::Houses::Queries::ListToVisit.call(user_profile.user_account, nil)&.pluck(:id)
              }
            end

          end
        end
      end
    end
  end
end
