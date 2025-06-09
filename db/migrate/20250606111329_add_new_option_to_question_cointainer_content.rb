class AddNewOptionToQuestionCointainerContent < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by_question_text_es 'En este envase hay..'

    type_content = TypeContent.create!(name_es: 'No pude revisar el envase', name_en: "I couldn't check the container", name_pt: 'Não consegui verificar a embalagem')
    new_opt = Option.new
    new_opt.question = question
    new_opt.name_es = 'No pude revisar el envase'
    new_opt.name_en = "I couldn't check the container."
    new_opt.name_pt = "Não consegui verificar a embalagem."
    new_opt.required = false
    new_opt.next = 16
    new_opt.resource_id = type_content.id
    new_opt.group_es = 'Nada'
    new_opt.group_en = 'Nothing'
    new_opt.group_pt = 'Nada'
    new_opt.status_color = 'YELLOW'
    new_opt.disable_other_options = true
    new_opt.position = question.options.count + 1
    new_opt.weighted_points = 2
    new_opt.save!
  end
end
