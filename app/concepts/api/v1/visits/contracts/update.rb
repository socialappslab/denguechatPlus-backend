# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          QUESTION_KEY_FORMAT = /\Aquestion_(\d+)_\d+\z/

          params do
            required(:id).filled(:integer)
            optional(:house_id).filled(:integer)
            optional(:visited_at).filled(:string)
            optional(:user_account_id).filled(:integer)
            optional(:host)
            optional(:notes).maybe(:string)
            optional(:family_education_topics)
            optional(:visit_permission).filled(:bool)

            optional(:answers).array(:hash)

            optional(:delete_inspection_ids).array(:integer)
          end

          #TODO: review with Gonza.
          # rule(:house_id) do
          #   house_exists = ::House.find_by(id: value).present?
          #   if !house_exists && !values[:house]
          #     key.failure(text: 'The house not exists, you need to send a house obj with the new house data',
          #                 predicate: :not_exists?)
          #   end
          # end

          rule(:user_account_id) do
            unless UserAccount.kept.exists?(id: value)
              key.failure(text: "The UserAccount with id: #{value} does not exist",
                          predicate: :not_exists?)
            end
          end

          rule(:answers) do
            if value.present?
              value.each_with_index do |answer_hash, index|
                answer_hash.keys.each do |key|
                  unless key.to_s.match?(QUESTION_KEY_FORMAT)
                    key([:answers, index]).failure(
                      text: "Invalid question key format for '#{key}'. Expected format: question_NUMBER_NUMBER",
                      predicate: :invalid_format?
                    )
                    next
                  end

                  question_number = key.to_s.match(QUESTION_KEY_FORMAT)[1].to_i

                  if values[:id].present? && (visit = Visit.find_by(id: values[:id]))
                    questionnaire = visit.questionnaire
                    question =  Question.find_by(id: question_number, questionnaire_id: questionnaire.id)
                    if question
                      answer_id = answer_hash[key]
                      unless question.options.where(id: answer_id).any?
                        key([:answers, index]).failure(
                          text: "The answer with id #{answer_id} does not exist by the question number #{question.id}",
                          predicate: :not_exists?
                        )
                      end
                    else
                      key([:answers, index]).failure(
                        text: "Question with id #{question_number} does not exist for the questionnaire",
                        predicate: :not_exists?
                      )
                    end
                  end
                end
              end
            else
              key.failure(text: "Answers is null or is blank",
                          predicate: :not_found?)
            end
          end


        end
      end
    end
  end
end
