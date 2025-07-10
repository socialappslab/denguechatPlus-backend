class ChangeQuestionQuantityFoundedOption < ActiveRecord::Migration[7.1]
  def up
    question_1 = Question.find_by(question_text_es: '¿Hay otros contenedores como este?')
    return unless question_1

    option = question_1.options.find_by(name_es: 'Si')
    option&.update!(value: 1)
  end
end
