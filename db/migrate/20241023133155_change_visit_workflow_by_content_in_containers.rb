class ChangeVisitWorkflowByContentInContainers < ActiveRecord::Migration[7.1]
  def up
    questionnaire = Questionnaire.last

    return unless questionnaire

    question = questionnaire.questions.where(question_text_es: '¿Hay otros contenedores como este?')&.first
    if question
      question.update_columns(question_text_es: '¿Hay otros contenedores exactamente del mismo tipo con agua que no tienen larvas, pupas o huevos?',
                              question_text_en: 'Are there other containers of exactly the same type with water that have no larvae, pupae or eggs?',
                              question_text_pt: 'Há outros recipientes exatamente do mesmo tipo com água que não têm larvas, pupas ou ovos?',
                              notes_es: 'Nota: Si el mismo tipo de contenedor tiene agua, larvas, pupas o huevos, debe registrarse individualmente.',
                              notes_en: 'Note: If the same type of container has water, larvae, pupae or eggs, they should be recorded individually.',
                              notes_pt: 'Observação: se o mesmo tipo de recipiente tiver água, larvas, pupas ou ovos, eles devem ser registrados individualmente.')

    end

    question_founded = questionnaire.questions.where(question_text_es: 'En este contenedor hay...')&.first
    return unless question_founded

    opts = question_founded.options

    nothing_opts = opts.select { |option| option if option.name_es == 'Nada' }.first
    nothing_opts.update_column(:next, 16)
    other_opts = opts.select { |option| option unless option.name_es == 'Nada' }
    other_opts.each do |option|
      option.update_column(:next, 17)
    end
  end
end
