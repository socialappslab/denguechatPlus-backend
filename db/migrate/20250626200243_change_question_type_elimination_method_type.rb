class ChangeQuestionTypeEliminationMethodType < ActiveRecord::Migration[7.1]
  def change
    questions = Question.where(question_text_es: '¿Qué acción se realizó con el envase?')

    questions.each do |question|
      question.type_field = 'multiple'
      question.resource_name = 'elimination_method_type_ids'
      question.save!
    end
  end
end
