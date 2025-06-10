class ChangeTypeFieldInQuestion < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    question.type_field = 'splash+list'
    question.save!
  end
end
