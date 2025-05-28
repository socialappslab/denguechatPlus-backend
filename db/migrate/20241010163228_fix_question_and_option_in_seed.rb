class FixQuestionAndOptionInSeed < ActiveRecord::Migration[7.1]
  def up

    # question 1
    # add text area to last question
    question_1 =  Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    if question_1
      option = question_1.options.find_by(name_es: 'Otra explicación')
      option&.update!(type_option: 'textArea')
    end

    # add type_boolean and value from first question until fifth question
    if question_1
      option_1 = question_1.options.find_by(name_es: 'Sí, tengo permiso para esta visita')
      other_questions = question_1.options.where(name_es: ['No, no me dieron permiso para esta visita',
                                                           'La casa está cerrada',
                                                           'La casa está deshabitada',
                                                           'Me pidieron regresar en otra ocasión'])

      option_1&.update!(type_option: 'boolean', value: 1)
      other_questions.each{|opt| opt&.update!(type_option: 'boolean', value: 0)}



    end


    #question 13
    # add text area to other options
    question_13 = Question.find_by(question_text_es: '¿El contenedor está protegido?')

    if question_13
      option_q_13 = question_13.options.find_by(name_es: 'Otro tipo de protección')
      option_q_13&.update!(type_option: 'textArea')
    end

    #update all question and options with next 20.
    Option.where(next: 20).update_all(next: 19)
    Question.where(next: 20).update_all(next: 19)


    #fix resource_id elimination_method_type_options
    option_1_q19 = Option.find_by(name_es: 'El contenedor fue limpiado')
    option_1_q19&.update!(resource_id: EliminationMethodType.find_by(name_es: 'El contenedor fue limpiado').id)

    option_2_q19 = Option.find_by(name_es: 'Ninguna acción')
    option_2_q19&.update!(resource_id: EliminationMethodType.find_by(name_es: 'Ninguna acción').id)
  end
end
