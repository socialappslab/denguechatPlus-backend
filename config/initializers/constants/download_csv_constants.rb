# frozen_string_literal: true

module Constants
  module DownloadCsvConstants
    VISIT_HEADERS_ES = [
        "codigo de referencia",
        "fecha_visita",
        "brigadista",
        "brigada",
        "permiso para visitar la casa",
        "notas",
        "se informó a la familia sobre"
      ].freeze

    VISIT_HEADERS_PT = [
      "código de referência",
      "data_visita",
      "brigadista",
      "brigada",
      "permissão para visitar a casa",
      "notas",
      "a família foi informada sobre"
    ].freeze

    VISIT_HEADERS_EN = [
      "reference code",
      "visit_date",
      "brigadist",
      "brigade",
      "permission to visit the house",
      "notes",
      "the family was informed about"
    ].freeze

    INSPECTION_HEADERS_ES = [
      "id",
      "tipo de recipiente",
      "hay agua en el recipiente",
      "origen del agua",
      "otro origen del agua",
      "tipo de protección",
      "otro tipo de protección",
      "fue tratado por el ministerio de salud",
      "en este envase hay",
      "acción realizada sobre el recipiente",
      "otra acción",
      "foto del envase"
    ].freeze

    INSPECTION_HEADERS_PT = [
      "id",
      "tipo de recipiente",
      "há água no recipiente",
      "origem da água",
      "outra origem da água",
      "tipo de proteção",
      "outro tipo de proteção",
      "foi tratado pelo ministério da saúde",
      "neste recipiente há",
      "ação realizada no recipiente",
      "outra ação",
      "foto do recipiente"
    ].freeze

    INSPECTION_HEADERS_EN = [
      "id",
      "container type",
      "is there water in the container",
      "water source",
      "other water source",
      "protection type",
      "other protection type",
      "treated by the ministry of health",
      "in this container there is",
      "action performed on the container",
      "other action",
      "container photo"
    ].freeze

    QUESTION_TALK_ABOUT_TOPICS= [
      { name_es: 'Explicación de larvas y pupas', name_en: 'Explanation of larvae and pupae',
        name_pt: 'Explicação de larvas e pupas' },
      { name_es: 'Explicación sobre cómo se reproduce el zancudo',
        name_en: 'Explanation of how the mosquito reproduces', name_pt: 'Explicação sobre como o mosquito se reproduz' },
      { name_es: 'Otro tema importante', name_en: 'Another important topic', name_pt: 'Outro tópico importante' }
    ].freeze

    BOOLEAN_TRANSLATIONS = {
      'es' => { true => 'Sí', false => 'No' },
      'en' => { true => 'Yes', false => 'No' },
      'pt' => { true => 'Sim', false => 'Não' }
    }.freeze

    WAS_CHEMICALLY_TRANSLATIONS =
      [
        {
          name_es: 'Sí, fue tratado (revise el registro detrás de la puerta)',
          name_en: 'Yes, it was treated (check the record behind the door)',
          name_pt: 'Sim, foi tratado (verifique o registro atrás da porta)'
        },
        {
          name_es: 'No, no fue tratado',
          name_en: 'No, it was not treated',
          name_pt: 'Não, não foi tratado'
        },
        {
          name_es: 'No lo sé',
          name_en: "I don't know",
          name_pt: 'Eu não sei'
        }
      ].freeze
  end
end
