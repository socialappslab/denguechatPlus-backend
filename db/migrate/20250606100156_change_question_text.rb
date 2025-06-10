class ChangeQuestionText < ActiveRecord::Migration[7.1]
  def change
    information_question = Question.find_by(question_text_es: 'Por favor informemos a la familia sobre..')
    information_question.question_text_es = '¿Qué información compartiste?'
    information_question.question_text_en = 'What information did you provide?'
    information_question.save!
  end
end
