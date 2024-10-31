# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Queries
          class Index
            include Api::V1::Lib::Queries::QueryHelper

            def initialize(filter, sort)
              @model = UserProfile.includes(:city, :neighborhood, :organization, :team,
                                            user_account: { roles: [:permissions] })
              @filter = filter
              @sort = sort
            end

            def self.call(...)
              new(...).call
            end

            def call
              @model.yield_self(&method(:active_records))
                    .yield_self(&method(:full_name_clause))
                    .yield_self(&method(:first_name_clause))
                    .yield_self(&method(:last_name_clause))
                    .yield_self(&method(:phone_clause))
                    .yield_self(&method(:email_clause))
                    .yield_self(&method(:username_clause))
                    .yield_self(&method(:team_id))
                    .yield_self(&method(:status_clause))
                    .yield_self(&method(:role_name_clause))
                    .yield_self(&method(:without_team))
                    .yield_self(&method(:sort_clause))
            end

            private

            attr_reader :user_accounts, :filter, :sort

            def active_records(relation)
              relation.where(user_account: UserAccount.where(discarded_at: nil))
            end

            def full_name_clause(relation)
              return relation if @filter.nil? || @filter[:full_name].blank?

              text_searched = @filter[:full_name].downcase
              relation.where(
                'unaccent(LOWER(user_profiles.first_name)) ilike unaccent(:query) OR unaccent(LOWER(user_profiles.last_name)) ilike unaccent(:query)', query: "%#{text_searched}%")
            end

            def first_name_clause(relation)
              return relation if @filter.nil? || @filter[:first_name].blank?

              text_searched = @filter[:first_name].downcase
              relation.where('LOWER(user_profiles.first_name) ilike unaccent(:query)', query: "%#{text_searched}%")
            end

            def last_name_clause(relation)
              return relation if @filter.nil? || @filter[:last_name].blank?

              text_searched = @filter[:last_name].downcase
              relation.where('LOWER(user_profiles.last_name) ilike unaccent(:query)', query: "%#{text_searched}%")
            end

            def phone_clause(relation)
              return relation if @filter.nil? || @filter[:phone].blank?

              relation.where('user_accounts.phone ilike :query', query: "%#{@filter[:phone]}%")
            end

            def email_clause(relation)
              return relation if @filter.nil? || @filter[:email].blank?

              text_searched = @filter[:email].downcase
              relation.where('LOWER(user_profiles.email) ilike unaccent(:query)', query: "%#{text_searched}%")
            end

            def username_clause(relation)
              return relation if @filter.nil? || @filter[:username].blank?

              text_searched = @filter[:username].downcase
              relation.where('LOWER(user_accounts.username) ilike unaccent(:query)', query: "%#{text_searched}%")
            end

            def status_clause(relation)
              return relation if @filter.nil? || @filter[:status].blank?

              relation.where(user_accounts: { status: @filter[:status] })
            end

            def team_id(relation)
              return relation if @filter.nil? || @filter[:team_id].blank?

              relation.joins(user_account: :user_profile).where(user_profiles: { team_id: @filter[:team_id] })
            end

            def role_name_clause(relation)
              return relation if @filter.nil? || @filter[:role_name].blank?

              text_searched = @filter[:role_name].downcase
              relation.joins(user_account: :roles).where('LOWER(roles.name) ILIKE unaccent(?)', "%#{text_searched}%")
            end

            def without_team(relation)
              return relation if @filter.nil? || !@filter[:without_team]

              relation
                .left_joins(:team)
                .where(team: { id: nil })
            end

            def sort_clause(relation)
              return relation if @sort.nil? || @sort.blank?

              lower_case = %w[user_profiles.first_name
                    user_profiles.last_name
                    user_profiles.email
                     user_accounts.username].include? @sort[:field]
              sort_by_table_columns(relation, lower_case:)
            end
          end
        end
      end
    end
  end
end
