# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Index < ApplicationSerializer
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
            brigade.members.map { |user| "#{user.first_name}, #{user.last_name}"  }
          end

          attribute :organization do |brigade|
            next if brigade.organization.nil?

            brigade.organization.name
          end

          attribute :sector do |brigade|
            next if brigade.sector.nil?

            brigade.sector.name
          end

          attribute :wedge do |brigade|
            next if brigade.wedge.nil?

            brigade.wedge.name
          end

        end
      end
    end
  end
end
