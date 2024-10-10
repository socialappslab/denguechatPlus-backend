# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Create < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:answers).filled(:array).each(:hash)
            required(:host).filled(:string)
            required(:visit_permission).filled(:bool)
            required(:visited_at).filled(:date_time)
            optional(:house_id).filled(:integer)
            required(:questionnaire_id).filled(:integer)
            optional(:team_id).filled(:integer)
            optional(:user_account_id).filled(:integer)
            optional(:notes)

            optional(:inspections).array(Api::V1::Visits::Contracts::Inspection.schema)

            optional(:house).hash(Api::V1::Visits::Contracts::House.schema)

          end

          rule(:house_id) do
            house_exists = ::House.find_by(id: value).present?
            if !house_exists && !values[:house]
              key(:house_id).failure(text: 'The house not exists, you need to send a house obj with the new house data',
                                     predicate: :not_exists?)
            end
          end

          rule(:questionnaire_id) do
            unless Questionnaire.kept.exists?(id: value)
              key(:team_id).failure(text: "The Questionnaire with id: #{value} does not exist",
                                    predicate: :not_exists?)
            end
          end

          rule(:user_account_id) do
            unless UserAccount.kept.exists?(id: value)
              key(:team_id).failure(text: "The UserAccount with id: #{value} does not exist",
                                    predicate: :not_exists?)
            end
          end
        end
      end
    end
  end
end
