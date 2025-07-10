module Api
  module V1
    module Visits
      module Serializers
        class ShowAttrsByUpdate < ApplicationSerializer
          set_type :id

          sanitize_answers = ->(answers) {
            return nil if answers.blank?

            result = answers.each_with_object({}) do |obj, merged|
              obj.each do |key, value|
                new_key = key.split('_')[1].to_i
                merged[new_key] = value
              end
            end
            result
          }

          build_options_with_answers = ->(answer_id, question) {
            return [] unless %w[list multiple].include?(question.type_field)

            question.options.map do |option|
              {
                id: option.id,
                description: option.name_es,
                selected: answer_id.nil? ? false : option.id == answer_id
              }
            end
          }

          build_dynamic_fields = proc do |visit|
            questionnaire = visit.questionnaire
            questions = questionnaire.questions
            answers = sanitize_answers.call(visit.answers)

            questions.where(id: answers.keys, resource_type: 'attribute')
                     .where.not(type_field: 'splash')
                     .where.not(question_text_es: '¿Encontraste un recipiente/envase?')
                     .map do |question|
              {
                id: question.id,
                description: question.question_text_es,
                options: build_options_with_answers.call(answers[question.id], question)
              }
            end
          end

          attribute :visit do |visit|
            {
              visitStatus: visit.status,
              hardFields: {
                visitedAt: visit.visited_at,
                brigade: visit.team.name,
                familyEducationTopics: visit.family_education_topics,

                host: visit.host.split(', '),
                brigadist: {
                  id: visit.user_account.id,
                  fullName: visit.user_account.full_name
                },
                house: {
                  id: visit.house_id,
                  referenceCode: visit.house.reference_code
                },
                notes: visit.notes
              },
              dynamicFields: build_dynamic_fields.call(visit)
            }
          end
        end
      end
    end
  end
end
