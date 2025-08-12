# frozen_string_literal: true

module Api
  module V1
    module Questionnaires
      module Serializers
        class Show < ApplicationSerializer
          set_type :questionnaire

          attributes :initial_question, :final_question

          get_image_obj = ->(record) do
            return nil unless record&.image&.attached?

            {
              id: record.image.id,
              url: Rails.application.routes.url_helpers.url_for(record.image)
            }
          end

          attribute :questions do |questionnaire|
            next if questionnaire.questions.nil? || questionnaire.questions.empty?

            questionnaire.questions.map do |question|
              begin
                {
                  id: question.id,
                  question: question.send("question_text_#{questionnaire.language}"),
                  typeField: question.type_field,
                  description: question.send("description_#{questionnaire.language}"),
                  notes: question.send("notes_#{questionnaire.language}"),
                  next: question.next,
                  resourceName: question.resource_name.presence,
                  resourceType: question.resource_type,
                  image: get_image_obj.call(question),
                  required: question.required,
                  additionalData: question.send("additional_data_#{questionnaire.language}"),
                  options: question.options
                                   .sort_by(&:position)
                                   .map do |option|
                    {
                      id: option.id,
                      name: option.send("name_#{questionnaire.language}"),
                      group: option.send("group_#{questionnaire.language}"),
                      resourceId: option.resource_id,
                      weightedPoints: option&.weighted_points,
                      required: option.required,
                      optionType: option.type_option,
                      statusColor: option.status_color,
                      image: get_image_obj.call(option),
                      position: option.position,
                      next: option.next
                    }.merge(%w[boolean inputNumber].include?(option.type_option) ? { value: option.value } : {})
                      .merge(question.type_field == 'multiple' ? { disableOtherOptions: option.disable_other_options } : {})
                      .merge(%w[house
                                orchard].include?(option.show_in_case) ? { showInCase: option.show_in_case } : {})
                      .merge(%w[house
                                orchard].include?(option.selected_case) ? { selectedCase: option.selected_case } : {})
                  end
                }
              rescue StandardError => error
                p error
              end
            end
          end
        end
      end
    end
  end
end
