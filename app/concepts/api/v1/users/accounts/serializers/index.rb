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

            attribute :created_at do |user|
              user.created_at.strftime('%Y-%m-%d')
            end

            attribute :team do |user|
              next if user.team.nil?

              {
                id: user.team.id,
                name: user.team_name
              }
            end

            attribute :roles do |user|
              next unless user.roles

              user.roles.map do |role|
                {
                  id: role.id,
                  name: role.name
                }
              end
            end
          end
        end
      end
    end
  end
end
