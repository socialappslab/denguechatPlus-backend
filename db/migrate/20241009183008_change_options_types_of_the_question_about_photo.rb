class ChangeOptionsTypesOfTheQuestionAboutPhoto < ActiveRecord::Migration[7.1]
  def up
    questionOtherContainers = Question.find_by(question_text_es: '¿Hay otros contenedores como este?')
    if questionOtherContainers
      options = questionOtherContainers.options
      option = options.find { |option| option.name_es == 'No' }
      if option
        option.type_option = 'boolean'
        option.value = 0
        option.save!
      end
    end
    questionPhotos = Question.find_by(question_text_es: '¿Puedes subir una foto del tipo de contenedor?')
    return unless questionPhotos

    options = questionPhotos.options
    option_yes = options.find { |option| option.name_es == 'Si, si puedo' }
    option_no = options.find { |option| option.name_es == 'No, no no puedo' }
    if option_yes
      option_yes.type_option = 'boolean'
      option_yes.value = 0
      option_yes.save!
    end
    return unless option_no

    option_no.type_option = 'boolean'
    option_no.value = 1
    option_no.save!
  end
end
