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

          attribute :members do |brigade|
            brigade.members.map { |user| { id: user.id, fullName: "#{user.first_name} #{user.last_name}" } }
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

          attribute :visits do |brigade|
            Visit.where(team_id: brigade.id).count
          end

          attribute :visits do |brigade|
            Visit.where(team_id: brigade.id).count
          end

          attribute :sites_statuses do |brigade|
            House.where(team_id: brigade.id)
                 .group(:status)
                 .count
          end
        end
      end
    end
  end
end
