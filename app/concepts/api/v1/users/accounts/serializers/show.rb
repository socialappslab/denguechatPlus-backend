# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class Show < ApplicationSerializer
            set_type :user

            attributes :id,
                       :username,
                       :phone,
                       :status,
                       :email,
                       :first_name,
                       :last_name

            attribute :created_at do |user_profile|
              user_profile.created_at.strftime('%Y-%m-%d')
            end

            attribute :city do |user_profile|
              next if user_profile.city.nil?

              {
                id: user_profile.city.id,
                name: user_profile.city_name
              }
            end

            attribute :neighborhood do |user_profile|
              next if user_profile.neighborhood.nil?

              {
                id: user_profile.neighborhood.id,
                name: user_profile.neighborhood_name
              }
            end

            attribute :organization do |user_profile|
              next if user_profile.organization.nil?

              {
                id: user_profile.organization.id,
                name: user_profile.organization_name
              }
            end

            attribute :team do |user_profile|
              next if user_profile.team.nil?

              {
                id: user_profile.team.id,
                name: user_profile.team_name
              }
            end

            attribute :house_block do |user_profile|
              next if user_profile.house_blocks.blank?

              {
                id: user_profile.house_blocks.first.id,
                name: user_profile.house_blocks.first.name,
                house_ids: Api::V1::Houses::Queries::ListToVisit.call(user_profile.user_account, nil)&.pluck(:id)
              }
            end

            attribute :roles do |user_profile|
              user_profile.roles&.map do |role|
                {
                  id: role.id,
                  name: role.name,
                  label: role.name == 'team_leader' ? 'facilitador' : role.name
                }
              end
            end
          end
        end
      end
    end
  end
end
