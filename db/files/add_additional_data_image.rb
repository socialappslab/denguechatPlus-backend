splash_question = Question.find_by(question_text_es: 'Visitemos la casa')
target_question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')

if splash_question&.image&.attached?
  ActiveStorage::Current.url_options = {
    host: ENV["HOST_URL"]
  }
  url = splash_question.image.url(expires_in: 2.years)

  target_question.additional_data["image"] = url
  target_question.save!
end
