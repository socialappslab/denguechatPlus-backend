# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class BrigadistPerformance
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter)
            @model = ::Visit
            @filter = filter || {}
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model
              .yield_self(&method(:get_first_five))
          end

          def get_first_five(relation)
            relation.joins(user_account: :user_profile)
                    .select('user_accounts.id AS user_account_id, COUNT(visits.id) AS quantity, user_profiles.first_name, user_profiles.last_name')
                    .group('user_accounts.id, user_profiles.first_name, user_profiles.last_name')
                    .order('quantity DESC')
                    .limit(5)
          end
        end
      end
    end
  end
end
