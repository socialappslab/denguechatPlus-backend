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
                       :phone,
                       :gender,
                       :points,
                       :timezone,
                       :language,
                       :email

            attribute :roles do |user_account|
              user_account.roles.map { |rol| rol.name }&.uniq
            end

            attribute :permissions do |user_account|
              user_account.permissions.map { |permission| "#{permission.resource}-#{permission.name}" }&.uniq
            end

            attribute :country do |user_account|
              city = user_account.user_profile.city
              next unless city
              next unless city&.country

              {
                id: city.country.id,
                name: city.country.name
              }
            end

            attribute :state do |user_account|
              next unless user_account.user_profile.city

              {
                id: user_account.user_profile.city.state.id,
                name: user_account.user_profile.city.state.name
              }
            end

            attribute :city do |user_account|
              next unless user_account.user_profile.city

              {
                id: user_account.user_profile.city.id,
                name: user_account.user_profile.city.name
              }
            end

            attribute :neighborhood do |user_account|
              next unless user_account.user_profile.neighborhood

              {
                id: user_account.user_profile.neighborhood.id,
                name: user_account.user_profile.neighborhood.name
              }
            end

            attribute :organization do |user_account|
              next unless user_account.user_profile.organization

              {
                id: user_account.user_profile.organization.id,
                name: user_account.user_profile.organization.name
              }
            end

            attribute :team do |user_account|
              next if user_account.teams.blank?

              {
                id: user_account.teams.first.id,
                name: user_account.teams.first.name
              }
            end
          end
        end
      end
    end
  end
end
