# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Show < ApplicationSerializer
          set_type :team

          attributes :name
          attribute :leader do |brigade|
            next if brigade.leader.nil?

            {
              id: brigade.leader.id,
              first_name: brigade.leader.first_name,
              last_name: brigade.leader.last_name
            }
          end

          attribute :user_profiles do |brigade|
            brigade.user_profiles.map { |user| { id: user.id, first_name: user.first_name, last_name: user.last_name } }
          end

          attribute :organizations do |brigade|
            next if brigade.organization.nil?

            {
              id: brigade.organization.id,
              name: brigade.organization.name
            }
          end

          attribute :sector do |brigade|
            next if brigade.sector.nil?

            {
              id: brigade.sector.id,
              name: brigade.sector.name
            }
          end

          attribute :wedge do |brigade|
            next if brigade.wedge.nil?

            {
              id: brigade.wedge.id,
              first_name: brigade.wedge.name
            }
          end

        end
      end
    end
  end
end
