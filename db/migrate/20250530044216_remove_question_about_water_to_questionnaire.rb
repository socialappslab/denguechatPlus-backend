class RemoveQuestionAboutWaterToQuestionnaire < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: '¿El recipiente/envase contiene agua?')
    previous_question = Question.find_by(question_text_es: '¿Qué tipo de recipiente/envase encontraste?')
    if question
      question.visible = false
      question.save!
      question.discard!
      previous_question.next = 12
      previous_question.save!
    end
  end
end
