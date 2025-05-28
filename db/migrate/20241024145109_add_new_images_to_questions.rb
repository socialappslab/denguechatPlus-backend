class AddNewImagesToQuestions < ActiveRecord::Migration[7.1]
  def change
    question1 = Question.find_by(question_text_es: 'Visitemos la casa')
    if question1
      #1
      set_image(question1, "1")
    end

    question2 = Question.find_by(question_text_es: 'Comencemos en la huerta')
    if question2
      #8_1
      set_image(question2, "8_1")
    end

    question3 = Question.find_by(question_text_es: 'Revisemos dentro de la casa')
    if question3
      #9
      set_image(question3, "9")
    end

    question5 = Question.find_by(question_text_es: 'Registremos acciones tomadas sobre el contenedor')
    if question5
      #4
      set_image(question5, "4")
    end


    # question5 = Question.find_by(question_text_es: 'Comencemos la visita_____')
    # if question5
    #   #2
    # end

    # question4 = Question.find_by(question_text_es: 'Foto del contenedor____')
    # if question4
    #   #3
    # end

    # question6 = Question.find_by(question_text_es: 'Resumen de la visita___')
    # if question6
    #   #5
    # end


    # question7 = Question.find_by(question_text_es: 'Visita concretada!')
    # if question7
    #   #7 o 6
    # end

  end

  def set_image(question, image_name)
    image_path = Rails.root.join('db', 'files', 'images', "ilustration_#{image_name}.png")

    if File.exist?(image_path)
      question.image.attach(io: File.open(image_path), filename: "#{image_name}.png")
      question.save!
      puts "Image saved!"
    else
      puts "problems with #{question.question_text_es}"
    end
  end
end
