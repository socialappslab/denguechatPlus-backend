class FillAdditionalDataPtEnToQuestion < ActiveRecord::Migration[7.1]
  def up
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    question.additional_data_en = question.additional_data_es
    question.additional_data_pt = question.additional_data_es
    url = "https://apisandbox.denguechatplus.org//rails/active_storage/disk/eyJfcmFpbHMiOnsiZGF0YSI6eyJrZXkiOiJxd20zYjJxYXNyNnBiczR2a2hsYmkydGs2M2tnIiwiZGlzcG9zaXRpb24iOiJpbmxpbmU7IGZpbGVuYW1lPVwiaWx1c3RyYWNpb25lcyBHYWJyaWVsYSAyICUyODElMjlfcGFnZS0wMDA2LmpwZ1wiOyBmaWxlbmFtZSo9VVRGLTgnJ2lsdXN0cmFjaW9uZXMlMjBHYWJyaWVsYSUyMDIlMjAlMjgxJTI5X3BhZ2UtMDAwNi5qcGciLCJjb250ZW50X3R5cGUiOiJpbWFnZS9qcGVnIiwic2VydmljZV9uYW1lIjoibG9jYWwifSwiZXhwIjoiMjAyNy0wNi0wNlQxMDoyMDowMi42MjdaIiwicHVyIjoiYmxvYl9rZXkifX0=--f1b27c19e5bcf47b6a8677d342b3a5a476e3aa38/ilustraciones%20Gabriela%202%20(1)_page-0006.jpg"
    question.additional_data_es = {"image":url,"title":"Visitemos la casa","description":"Lleguemos a la casa con mucho respeto."}
    question.additional_data_en = {"image": url, "title": "Let's visit the house", "description": "Let's arrive at the house with great respect."}
    question.additional_data_pt = {"image": url, "title": "Vamos visitar a casa", "description": "Vamos chegar à casa com muito respeito."}
    question.save!

    Question.where(additional_data_es: [{}], additional_data_en: [{}], additional_data_pt: [{}])
            .update_all(additional_data_es: nil,
                        additional_data_en: nil,
                        additional_data_pt: nil)
  end
end
