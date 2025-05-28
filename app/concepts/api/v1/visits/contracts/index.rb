# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Index < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).hash do
              optional(:visited_at)
              optional(:city_id)
              optional(:city)
              optional(:sector_id)
              optional(:sector_name)
              optional(:wedge_id)
              optional(:wedge)
              optional(:brigadist)
              optional(:brigadist_id)
              optional(:team_id)
              optional(:team)
              optional(:house)
              optional(:house_status)
              optional(:visit_status)
            end
          end
        end
      end
    end
  end
end
