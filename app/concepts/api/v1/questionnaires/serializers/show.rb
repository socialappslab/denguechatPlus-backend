# frozen_string_literal: true

module Api
  module V1
    module Questionnaires
      module Serializers
        class Show < ApplicationSerializer
          set_type :questionnaire

          attributes :initial_question, :final_question

          attribute :questions do |questionnaire|
            get_image_obj = ->(record) do
              return nil unless record&.image&.attached?

              {
                id: record.image.id,
                url: Rails.application.routes.url_helpers.url_for(record.image)
              }
            end

            serialize_question = ->(question) do
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
                  }.tap do |hash|
                    hash[:value] = option.value if %w[boolean inputNumber].include?(option.type_option)
                    hash[:disableOtherOptions] = option.disable_other_options if question.type_field == 'multiple'
                    hash[:showInCase] = option.show_in_case if %w[house orchard].include?(option.show_in_case)
                    hash[:selectedCase] = option.selected_case if %w[house orchard].include?(option.selected_case)

                    if question.resource_name == 'breeding_site_type_id'
                      hash[:additionalInformation] =
                        BreedingSiteType.find_by(id: option.resource_id)&.serialized_additional_info
                    end
                  end
                end,
                children: question.children.map { |child| serialize_question.call(child) }
              }
            end

            questionnaire.questions
                         .where(parent_id: nil)
                         .map { |question| serialize_question.call(question) }
          end
        end
      end
    end
  end
end
