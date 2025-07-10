class AddAQuestionForReturnToOrchardOrTheHouse < ActiveRecord::Migration[7.1]
  def up
    questionnaire = Questionnaire.last
    return unless questionnaire

    question = Question.create!(questionnaire_id: questionnaire.id,
                                question_text_es: '¿Registrar otro contenedor?',
                                question_text_en: 'Register another container?',
                                question_text_pt: 'Registrar outro contêiner?',
                                type_field: 'list')
    question ||= Question.create(questionnaire_id: questionnaire.id,
                                 question_text_es: '¿Registrar otro contenedor?',
                                 question_text_en: 'Register another container?',
                                 question_text_pt: 'Registrar outro contêiner?',
                                 type_field: 'list')

    return unless question

    option_1 = Option.find_or_create_by!(name_es: 'Registrar otro contenedor en la huerta',
                                         name_pt: 'Registrar outro contêiner na horta',
                                         name_en: 'Register another container in the orchard',
                                         show_in_case: 'house',
                                         next: 9,
                                         question_id: question.id,
                                         type_option: 'boolean',
                                         position: 1,
                                         value: '1')

    option_2 = Option.find_or_create_by!(name_es: 'Registrar otro contenedor en la casa',
                                         name_pt: 'Registrar outro contêiner na casa',
                                         name_en: 'Register another container in the house',
                                         show_in_case: 'orchard',
                                         next: 9,
                                         question_id: question.id,
                                         type_option: 'boolean',
                                         position: 2,
                                         value: '1')

    option_3 = Option.find_or_create_by!(name_es: 'No, no es necesario',
                                         name_pt: 'Não, não é necessário',
                                         name_en: 'No, it is not necessary',
                                         next: -1,
                                         question_id: question.id,
                                         type_option: 'boolean',
                                         position: 3,
                                         value: '0')

    question.options << [option_1, option_2, option_3]
    question.save!

    question_update = Question.find_by(question_text_es: '¿Dónde comienza la visita?')
    if question_update
      opts = question_update.options
      opts.each do |option|
        option.selected_case = 'orchard' if option.name_es == 'En la huerta'
        option.selected_case = 'house' if option.name_es == 'En la casa'
        option.save
      end
    end
    questionnaire.final_question = Question.last.id
  end
end
