class ModifyProtectedQuestionOption < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: '¿El recipiente/envase está protegido?')
    return unless question

    changes = [
      {
        original_text_es: '',
        new_text_es: 'Uso Diario del agua',
        new_text_en: 'Daily use of water',
        new_text_pt: 'Uso diário da água',
        type_change: :create,
        position: 5,
        group_es: 'Otros',
        group_en: 'Others',
        group_pt: 'Outros',
        status_color: 'GREEN',
        weighted_points: 9,
        next: 14
      },
      {
        original_text_es: 'Techo',
        new_text_es: 'Está bajo techo',
        new_text_en: 'It is under a roof',
        new_text_pt: 'Está embaixo de um telhado',
        type_change: :modify,
        position: 3,
        group_es: 'Techo',
        group_en: 'Roof',
        group_pt: 'Telhado',
        status_color: 'YELLOW',
        weighted_points: 2,
        next: 14
      },
      {
        original_text_es: 'No tiene',
        new_text_es: 'No tiene tapa',
        new_text_en: 'It has no lid',
        new_text_pt: 'Não tem tampa',
        type_change: :modify,
        position: 4,
        group_es: 'Tapa',
        group_en: 'Lid',
        group_pt: 'Tampa',
        status_color: 'YELLOW',
        weighted_points: 2,
        next: 14
      }
    ]
    changes.each do |item|
      handle_change(item)
    end
  end

  private

  def handle_change(item)
    original_text = item[:original_text_es]

    option = if original_text == 'Techo'
               Option.find_by(name_es: 'Sí, está bajo techo')
             elsif original_text == 'No tiene'
               Option.find_by(name_es: 'No tiene protección')
             else
               Option.find_by(name_es: item[:original_text_es])
             end

    container_protection = ContainerProtection.find_by(name_es: original_text.presence || item[:new_text_es])

    case item[:type_change]
    when :modify
      update_records(container_protection, option, item)
    when :create
      create_records(item)
    when :disable
      disable_records(container_protection, option)
    end
  end

  def update_records(container_protection, option, item)
    return unless container_protection && option

    container_protection.update!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt]
    )

    option.update!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt],
      position: item[:position],
      group_es: item[:group_es],
      group_en: item[:group_en],
      group_pt: item[:group_pt],
      status_color: item[:status_color],
      weighted_points: item[:weighted_points],
      next: item[:next]
    )
  end

  def create_records(item)
    container_protection = ContainerProtection.create!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt]
    )
    question = Question.find_by(question_text_es: '¿El recipiente/envase está protegido?')

    Option.create!(
      name_es: item[:new_text_es],
      name_en: item[:new_text_en],
      name_pt: item[:new_text_pt],
      required: false,
      resource_id: container_protection.id,
      position: item[:position],
      question_id: question.id,
      group_es: item[:group_es],
      group_en: item[:group_en],
      group_pt: item[:group_pt],
      status_color: item[:status_color],
      weighted_points: item[:weighted_points],
      next: item[:next]
    )
  end

  def disable_records(container_protection, option)
    container_protection&.discard!
    return unless option

    option.update!(visible: false)
    option.discard!
  end
end
