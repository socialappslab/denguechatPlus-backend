class RemoveQuestionToQuestionnaire < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: 'Registremos acciones tomadas sobre el recipiente/envase')
    previous_question = Question.find_by(question_text_es: '¿Puedes subir una foto del tipo de recipiente/envase?')
    if question
      question.visible = false
      previous_question.next = 19 if previous_question
      question.save!
      previous_question&.save!
    end
  end
end
