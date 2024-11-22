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
            optional(:visited_at).filled(:date)
            optional(:city_id).filled(:integer)
            optional(:city_name).filled(:string)
            optional(:sector_id).filled(:integer)
            optional(:sector_name).filled(:string)
            optional(:wedge_id).filled(:integer)
            optional(:wedge_name).filled(:string)
            optional(:brigadist_name).filled(:string)
            optional(:brigadist_id).filled(:integer)
            optional(:team_id).filled(:integer)
            optional(:team_name).filled(:string)
            optional(:house_id).filled(:integer)
            optional(:house_status).filled(:string)
            optional(:visit_status).filled(:string)
          end
        end
      end
    end
  end
end
