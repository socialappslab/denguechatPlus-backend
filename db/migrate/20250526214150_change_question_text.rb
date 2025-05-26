class ChangeQuestionText < ActiveRecord::Migration[7.1]
  def up
    question = Question.find_by(question_text_es: 'Por favor informemos a la familia sobre..')
    question&.update!(question_text_es: '¿Qué información compartiste?',
                      question_text_en: 'What information did you provide?')
  end
end
