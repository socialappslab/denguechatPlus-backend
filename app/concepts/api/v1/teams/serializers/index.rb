# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Index < ApplicationSerializer
          set_type :team

          attributes :name

          attribute :member_count do |brigade|
            brigade.members&.count
          end

          attribute :leader do |brigade|
            next if brigade.nil?

            brigade.members
                   .joins(user_account: :roles)
                   .where(roles: { name: %w[team_leader facilitador] })
                   .map(&:full_name)
                   .join(', ')
          end

          attribute :members do |brigade|
            brigade.members.map { |user| "#{user.first_name}, #{user.last_name}" }
          end

          attribute :members do |brigade|
            brigade.members.map { |user| { id: user.id, fullName: "#{user.first_name} #{user.last_name}" } }
          end

          attribute :organization do |brigade|
            next if brigade.organization.nil?

            brigade.organization.name
          end

          attribute :city do |brigade|
            sector = brigade.sector
            next if sector.nil?

            city = sector.city
            next if city.nil?

            city.name
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
