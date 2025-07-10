class ChangeContainerActionsToOptions < ActiveRecord::Migration[7.1]
  def change
    changes = [
      {
        original_text_es: 'El recipiente/envase fue protegido',
        new_text_es: 'Tapamos el contenedor',
        new_text_en: 'We put a lid on the container',
        new_text_pt: 'Tampamos o recipiente',
        type_change: :modify,
        position: 1
      },
      {
        original_text_es: 'El agua del recipiente/envase fue tirado',
        new_text_es: 'Vaciamos el agua',
        new_text_en: 'We dumped out the water',
        new_text_pt: 'Esvaziamos a água',
        type_change: :modify,
        position: 2
      },
      {
        original_text_es: 'El recipiente/envase fue trasladado a un lugar seguro',
        new_text_es: 'Trasladamos el contenedor a un techo o a un lugar cerrado',
        new_text_en: 'We moved the container under a roof or inside',
        new_text_pt: 'Colocamos o recipiente embaixo de um telhado ou dentro de casa',
        type_change: :modify,
        position: 3
      },
      {
        original_text_es: 'El recipiente/envase fue descartado',
        new_text_es: 'Tiramos el contenedor',
        new_text_en: 'We threw out the container',
        new_text_pt: 'Jogamos fora o recipiente',
        type_change: :modify,
        position: 4
      },
      {
        original_text_es: 'El recipiente/envase fue limpiado',
        new_text_es: 'Limpiamos el contenedor',
        new_text_en: 'We cleaned the container',
        new_text_pt: 'Limpamos o recipiente',
        type_change: :modify,
        position: 5
      },
      {
        original_text_es: 'Otro',
        new_text_es: 'Otro (tratamiento manual)',
        new_text_en: 'Other (manual treatment)',
        new_text_pt: 'Outro (tratamento manual)',
        type_change: :modify,
        position: 8
      },
      {
        original_text_es: '',
        new_text_es: 'No fue necesario tomar ninguna acción',
        new_text_en: 'No action needed',
        new_text_pt: 'Não foi necessário tomar nenhuma ação',
        type_change: :create,
        position: 6
      },
      {
        original_text_es: 'Ninguna acción',
        new_text_es: 'No se tomó ninguna acción',
        new_text_en: 'No action taken',
        new_text_pt: 'Nenhuma ação foi tomada',
        type_change: :modify,
        position: 7
      }
    ]

    changes.each do |item|
      handle_change(item)
    end
  end

  private

  def handle_change(item)
    original_text = item[:original_text_es]

    option = if original_text == 'El agua del recipiente/envase fue tirado'
               Option.find_by(name_es: 'El agua del recipiente/envase fue tirada')
             else
               Option.find_by(name_es: item[:original_text_es])
             end

    elimination_method = EliminationMethodType.find_by(name_es: original_text.presence || item[:new_text_es])

    case item[:type_change]
    when :modify
      update_records(elimination_method, option, item)
    when :create
      create_records(item)
    when :disable
      disable_records(elimination_method, option)
    end
  end

  def update_records(elimination_method, option, item)
    return unless elimination_method && option

    elimination_method.update!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt]
    )

    option.update!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt],
      position: item[:position]
    )
  end

  def create_records(item)
    elimination_method = EliminationMethodType.create!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt]
    )
    question = Question.find_by(question_text_es: '¿Qué acción se realizó con el recipiente/envase?')

    Option.create!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt],
      required: false,
      resource_id: elimination_method.id,
      position: item[:position],
      question_id: question.id
    )
  end

  def disable_records(elimination_method, option)
    elimination_method&.discard!
    return unless option

    option.update!(visible: false)
    option.discard!
  end
end
