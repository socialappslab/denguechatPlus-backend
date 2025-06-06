class ChangeTextOnQuestionAboutWater < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: '¿Registrar otro envase en el mismo sector del sitio?')
    question.question_text_en = 'Register another container with water in the same sector?'
    question.question_text_es = 'Registrar otro envase con agua en el mismo sector?'
    question.save!
  end
end
