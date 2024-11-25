# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Queries
        class Show
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(params)
            includes = %i[house team user_account]
            @model = Visit.includes(*includes, user_account: :user_profile)
            @visit_id = params[:id]
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.find_by(id: @visit_id)
          end

          private

          attr_reader :visit_id
        end
      end
    end
  end
end
