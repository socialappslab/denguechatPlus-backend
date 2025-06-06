class ChangePositionAndTextToContainerProtectionOptions < ActiveRecord::Migration[7.1]
  def change
    question = Question.find_by_question_text_es '¿El envase está protegido?'
    opts = question.options

    opts.each do |opt|
      if opt.name_es.downcase.include? 'diario'
        opt.name_es.gsub! 'Diario', 'diario'
      elsif opt.name_es == 'Otro tipo de protección'
        opt.position = opts.count
      end
      opt.save!
    end
  end
end
