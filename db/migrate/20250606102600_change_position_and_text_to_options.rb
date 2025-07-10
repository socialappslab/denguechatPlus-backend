class ChangePositionAndTextToOptions < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by_question_text_es '¿Qué acción se realizó con el envase?'
    opts = question.options

    opts.each do |opt|
      if opt.name_es.downcase.include? 'contenedor'
        opt.name_es.gsub! 'contenedor', 'envase'
      elsif opt.name_es == 'Otro'
        opt.position = opts.count
      end
      opt.save!
    end
  end
end
