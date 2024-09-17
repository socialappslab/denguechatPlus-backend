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
                    .yield_self(&method(:first_name_clause))
                    .yield_self(&method(:last_name_clause))
                    .yield_self(&method(:phone_clause))
                    .yield_self(&method(:email_clause))
                    .yield_self(&method(:username_clause))
                    .yield_self(&method(:team_id))
                    .yield_self(&method(:status_clause))
                    .yield_self(&method(:role_name_clause))
                    .yield_self(&method(:sort_clause))
            end

            private

            attr_reader :user_accounts, :filter, :sort

            def active_records(relation)
              relation.where(user_account: {discarded_at: nil})
            end

            def first_name_clause(relation)
              return relation if @filter.nil? || @filter[:first_name].blank?

              relation.where('user_profiles.first_name ilike :query', query: "%#{@filter[:first_name]}%")
            end

            def last_name_clause(relation)
              return relation if @filter.nil? || @filter[:last_name].blank?

              relation.where('user_profiles.last_name ilike :query', query: "%#{@filter[:last_name]}%")
            end

            def phone_clause(relation)
              return relation if @filter.nil? || @filter[:phone].blank?

              relation.where('user_account.phone ilike :query', query: "%#{@filter[:phone]}%")
            end

            def email_clause(relation)
              return relation if @filter.nil? || @filter[:email].blank?

              relation.where('user_profiles.email ilike :query', query: "%#{@filter[:email]}%")
            end

            def username_clause(relation)
              return relation if @filter.nil? || @filter[:username].blank?

              relation.where('user_account.username ilike :query', query: "%#{@filter[:username]}%")
            end

            def status_clause(relation)
              return relation if @filter.nil? || @filter[:status].blank?

              relation.where(user_account: { status: @filter[:status] })
            end

            def team_id(relation)
              return relation if @filter.nil? || @filter[:team_id].blank?

              relation.joins(user_account: :user_profile).where(user_profiles: { team_id: @filter[:team_id] })
            end

            def role_name_clause(relation)
              return relation if @filter.nil? || @filter[:role_name].blank?

              relation.joins(user_account: :roles).where('roles.name ILIKE ?', "%#{@filter[:role_name]}%")
            end

            def sort_clause(relation)
              return relation if @sort.nil? || @sort.blank?

              lower_case = %w[user_profiles.first_name
                    user_profiles.last_name
                    user_profiles.email
                     user_account.username].include? @sort[:field]
              sort_by_table_columns(relation, lower_case:)
            end
          end
        end
      end
    end
  end
end
