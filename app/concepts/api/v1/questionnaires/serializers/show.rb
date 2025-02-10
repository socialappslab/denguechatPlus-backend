# frozen_string_literal: true

module Api
  module V1
    module Questionnaires
      module Serializers
        class Show < ApplicationSerializer
          set_type :questionnaire

          attributes :initial_question, :final_question

          get_image_obj = lambda do |record|
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
                  resourceName: question.resource_name.blank? ? nil : question.resource_name,
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
                      required: option.required,
                      optionType: option.type_option,
                      statusColor: option.status_color,
                      image: get_image_obj.call(option),
                      position: option.position,
                      next: option.next
                    }.merge(option.type_option == 'boolean' || option.type_option == 'inputNumber' ? {value: option.value} : {})
                     .merge(question.type_field == 'multiple' ? {disableOtherOptions: option.disable_other_options} : {})
                     .merge(option.show_in_case == 'house' || option.show_in_case == 'orchard' ? {showInCase: option.show_in_case} : {})
                     .merge(option.selected_case == 'house' || option.selected_case == 'orchard' ? {selectedCase: option.selected_case} : {})
                     .merge(question.resource_name == 'breeding_site_type_id' ? {additionalInformation: BreedingSiteType.find_by(id: option.resource_id).serialized_additional_info} : {})
                  end
                }
              rescue => error
                p error
              end
            end


          end
        end
      end
    end
  end
end
