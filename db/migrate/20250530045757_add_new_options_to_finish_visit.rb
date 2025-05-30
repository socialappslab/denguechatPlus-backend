class AddNewOptionsToFinishVisit < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by(question_text_es: '¿Registrar otro recipiente/envase en el mismo sector del sitio?')
    option = question.options.find_by(name_es: 'No, no es necesario') if question

    if question
      option.name_es = 'No, terminar la visita'
      option.name_en = 'No, finish the visit'
      option.show_in_case = 'orchard'
      option.selected_case = 'house'
      option.next = -1
      option_house = option.dup
      option_house.show_in_case = 'house'
      option.selected_case = 'orchard'
      option_house.save!
      option.save!
    end

  end
end
