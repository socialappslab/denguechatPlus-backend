class ChangeQuestionTypeWaterSourceType < ActiveRecord::Migration[7.1]
  def change
    questions = Question.where(question_text_es: '¿De dónde proviene el agua?')

    questions.each do |question|
      question.type_field = 'multiple'
      question.resource_name = 'water_source_type_ids'
      question.save!
    end
  end
end
