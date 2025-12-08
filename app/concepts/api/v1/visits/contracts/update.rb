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
          VISIT_PERMISSION_QUESTION_TEXT = '¿Me dieron permiso para visitar la casa?'

          params do
            required(:id).filled(:integer)
            optional(:house_id).filled(:integer)
            optional(:visited_at).filled(:string)
            optional(:user_account_id).filled(:integer)
            optional(:host)
            optional(:notes).maybe(:string)
            optional(:family_education_topics)
            optional(:other_family_education_topic).maybe(:string)
            optional(:visit_permission_option_id).filled(:integer)
            optional(:visit_permission_other).maybe(:string)

            optional(:answers).array(:hash)

            optional(:delete_inspection_ids).array(:integer)
            optional(:was_offline).filled(:bool)
          end

          rule(:visit_permission_option_id) do
            next unless value

            question = Question.find_by(question_text_es: VISIT_PERMISSION_QUESTION_TEXT)
            option = Option.find_by(id: value, question_id: question&.id)
            key.failure(text: 'The visit permission option does not exist', predicate: :not_exists?) unless option
          end

          rule(:visit_permission_other) do
            next unless values[:visit_permission_option_id]

            option = Option.find_by(id: values[:visit_permission_option_id])
            if option&.type_option == 'textArea' && value.blank?
              key.failure(text: 'Other explanation is required when "Otra explicación" is selected',
                          predicate: :filled?)
            end
          end

          rule(:user_account_id) do
            unless UserAccount.kept.exists?(id: value)
              key.failure(text: "The UserAccount with id: #{value} does not exist",
                          predicate: :not_exists?)
            end
          end

          rule(:answers) do
            if value.is_a?(Array)
              value.each_with_index do |answer_hash, index|
                answer_hash.each_key do |key|
                  unless key.to_s.match?(QUESTION_KEY_FORMAT)
                    key([:answers, index]).failure(
                      text: "Invalid question key format for '#{key}'. Expected format: question_NUMBER_NUMBER",
                      predicate: :invalid_format?
                    )
                    next
                  end

                  question_number = key.to_s.match(QUESTION_KEY_FORMAT)[1].to_i

                  next unless values[:id].present? && (visit = Visit.find_by(id: values[:id]))

                  questionnaire = visit.questionnaire
                  question = Question.find_by(id: question_number, questionnaire_id: questionnaire.id)
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
            else
              key.failure(text: 'Answers is null or is blank',
                          predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end
