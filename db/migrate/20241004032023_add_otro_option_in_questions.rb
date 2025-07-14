class AddOtroOptionInQuestions < ActiveRecord::Migration[7.1]
  def up
    EliminationMethodType.create_or_find_by!(name_es: 'Otro', name_en: 'Other', name_pt: 'Outro')
    question = Question.find_by(question_text_es: '¿Qué acción se realizó con el contenedor?')

    return unless question

    option_params = {
      name_es: 'Otro',
      name_en: 'Other',
      name_pt: 'Outro',
      resource_id: EliminationMethodType.find_by(name_es: 'Otro')&.id,
      type_option: 'textArea',
      next: 20,
      question: question
    }

    Option.find_or_create_by(option_params)

    option_to_change = Option.find_by(name_es: 'El agua del contenedor fue tirado')
    option_to_change.update!(name_es: 'El agua del contenedor fue tirada') if option_to_change
  end
end
