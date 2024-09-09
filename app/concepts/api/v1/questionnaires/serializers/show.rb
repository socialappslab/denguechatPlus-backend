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
              {
                id: question.id,
                question: question.send("question_text_#{questionnaire.language}"),
                typeField: question.type_field,
                description: question.send("description_#{questionnaire.language}"),
                next: question.next,
                image: get_image_obj.call(question),
                options: question.options.map do |option|
                  {
                    id: option.id,
                    name: option.send("name_#{questionnaire.language}"),
                    required: option.required,
                    textArea: option.text_area,
                    image: get_image_obj.call(option),
                    next: option.next
                  }
                end
              }
            end
          end
        end
      end
    end
  end
end
