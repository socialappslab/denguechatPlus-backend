class DeleteLastQuestionAndChangeQuestionnaireLastIndexQuestion < ActiveRecord::Migration[7.1]
  def up
    question = Question.find_by(question_text_es: '¿Registrar otro contenedor?')
    question&.destroy!
    questionnaire = Questionnaire.last
    if questionnaire
      questionnaire.final_question = 19
      questionnaire.save!
    end
  end
end
