class ChangeFieldAdditionalDataToNullableInQuestions < ActiveRecord::Migration[7.1]
  def change
    change_column_null :questions, :additional_data, true
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    question.next = nil
    question.save!

    Question.all.each do |question|
      question.additional_data = nil unless question.additional_data.present?
      question.save!
    end
  end
end
