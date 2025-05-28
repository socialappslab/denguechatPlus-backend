class ChangeQuestionOrderAboutInformation < ActiveRecord::Migration[7.1]
  def change
    before_question = Question.find_by(question_text_es: '¿Quién te acompaña hoy en esta visita?')
    information_question = Question.find_by(question_text_es: 'Por favor informemos a la familia sobre..')
    before_last_question = Question.find_by(question_text_es: '¿Registrar otro recipiente/envase en el mismo sector del sitio?')
    before_last_option_question = before_last_question.options.where(name_es: 'No, no es necesario')&.first


    ActiveRecord::Base.transaction do
      before_question.next = 5
      before_question.save!

      information_question.next = -1
      information_question.save!

      before_last_option_question.next = information_question.id
      before_last_option_question.save!

    end
  end
end
