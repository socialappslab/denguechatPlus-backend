# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:organization_id).filled(:integer)
            optional(:leader_id).maybe(:integer)
            optional(:member_ids).maybe(:array).each(:integer)
            optional(:sector_id).filled(:integer)
            optional(:wedge_id).filled(:integer)
          end

          rule(:member_ids).each do
            if values[:member_ids] && !UserProfile.exists?(id: values[:member_ids])
              key(:member_ids).failure(text: 'user_profile does not exist', predicate: :not_found?)
            end

            if values[:member_ids] &&
              UserProfile.where(id: values[:member_ids], team_id: nil).count != values[:member_ids].count
              key(:member_ids).failure(text: "user_profile with id: '#{value}' is already assigned to a brigade", predicate: :unique?)
            end

          end

          rule(:leader_id) do
            if values[:leader_id] && !UserProfile.exists?(id: values[:leader_id])
              key(:leader_id).failure(text: 'leader does not exist', predicate: :not_found?)
            end

            if values[:leader_id] && Team.exists?(leader_id: values[:leader_id])
              key(:leader_id).failure(text: 'leader profile is already assigned to a brigade', predicate: :unique?)
            end

          end

          rule(:organization_id) do
            if values[:organization_id] && !Organization.exists?(id: values[:organization_id])
              key(:organization_id).failure(text: 'organization not exist', predicate: :not_found?)
            end
          end

          rule(:sector_id) do
            if values[:sector_id] && !Neighborhood.exists?(id: values[:sector_id])
              key(:sector_id).failure(text: 'sector not exist', predicate: :not_found?)
            end
          end

          rule(:wedge_id) do
            if values[:wedge_id] && !Wedge.exists?(id: values[:wedge_id])
              key(:wedge_id).failure(text: 'wedge not exist', predicate: :not_found?)
            end
          end

          rule(:name) do
            if values[:name] && Team.exists?(name: values[:name].downcase)
              key(:name).failure(text: 'the team name is already in use', predicate: :unique?)
            end
          end

        end
      end
    end
  end
end
