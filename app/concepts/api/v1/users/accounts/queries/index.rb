# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Queries
          class Index
            include Api::V1::Lib::Queries::QueryHelper

            def initialize(filter, sort)
              @model = UserProfile.includes(:city, :neighborhood, :organization, :team, :house_blocks,
                                            user_account: { roles: [:permissions] })
              @filter = filter
              @sort = sort_to_snake_case(sort)
            end

            def self.call(...)
              new(...).call
            end

            def call
              @model.then { |relation| active_records(relation) }
                    .then { |relation| full_name_clause(relation) }
                    .then { |relation| first_name_clause(relation) }
                    .then { |relation| last_name_clause(relation) }
                    .then { |relation| phone_clause(relation) }
                    .then { |relation| email_clause(relation) }
                    .then { |relation| username_clause(relation) }
                    .then { |relation| team_id(relation) }
                    .then { |relation| status_clause(relation) }
                    .then { |relation| role_name_clause(relation) }
                    .then { |relation| without_team(relation) }
                    .then { |relation| sort_clause(relation) }
            end

            private

            attr_reader :user_accounts, :filter, :sort

            def active_records(relation)
              relation.where(user_account: UserAccount.where(discarded_at: nil))
            end

            def full_name_clause(relation)
              return relation if @filter.nil? || @filter[:full_name].blank?

              text_searched = @filter[:full_name].downcase
              transformed_text = text_searched.split.join('%%')
              transformed_text = "%#{transformed_text}%"

              relation.where(
                "unaccent(LOWER(user_profiles.first_name || ' ' || user_profiles.last_name)) ILIKE unaccent(:query)", query: "%#{transformed_text}%"
              )
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
              relation.joins(user_account: :roles).where(
                'LOWER(roles.name) ILIKE unaccent(?) OR LOWER(roles.name) ILIKE unaccent(?)', "%#{text_searched}%", '%team_leader%'
              )
            end

            def without_team(relation)
              return relation if @filter.nil? || !@filter[:without_team]

              relation
                .where.missing(:team)
            end

            def sort_clause(relation)
              return relation if @sort.nil? || @sort.blank?

              search_array = @sort[:field].split('.')
              table = search_array.first.pluralize.downcase
              attribute = search_array.last
              @sort[:field] = "#{table}.#{attribute}"

              sort_by_table_columns(relation)
            end
          end
        end
      end
    end
  end
end
