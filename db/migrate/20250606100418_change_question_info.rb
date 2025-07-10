class ChangeQuestionInfo < ActiveRecord::Migration[7.1]
  def change
    question_revisemos_la_casa = Question.find_by_question_text_es 'Revisemos dentro de la casa'
    question_revisemos_la_huerta = Question.find_by_question_text_es 'Revisemos en la huerta'
    question_donde_comienza_la_visita = Question.find_by_question_text_es '¿Dónde comienza la visita?'
    donde_comienza_la_visita_opts = question_donde_comienza_la_visita.options

    question_revisemos_la_casa.visible = false
    question_revisemos_la_huerta.visible = false

    donde_comienza_la_visita_opts.each do |opt|
      if opt.name_es.include? 'casa'
        opt.image.attach(question_revisemos_la_casa.image.blob)
      else
        opt.image.attach(question_revisemos_la_huerta.image.blob)
      end
      opt.save!
      question_revisemos_la_casa.save!
      question_revisemos_la_huerta.save!
    end
  end
end
