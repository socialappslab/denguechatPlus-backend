class ChangeAndCreateBreedingSiteTypes < ActiveRecord::Migration[7.1]
  def up
    BreedingSiteType.create_or_find_by!(name: 'Sumidero', container_type: 'permanent')
    BreedingSiteType.create_or_find_by!(name: 'Maceteros y floreros', container_type: 'non-permanent')
    BreedingSiteType.create_or_find_by!(name: 'Criaderos, bebederos y acuarios', container_type: 'non-permanent')

    change_1 = BreedingSiteType.find_by(name: 'Elementos naturales')
    change_1&.update!(name: 'Plantas, frutas y verduras')

    change_2 = BreedingSiteType.find_by(name: 'Llanta')
    change_2&.update!(name: 'Llantas')

    change_3 = BreedingSiteType.find_by(name: 'Tanques (cemento, polietileno, metal, otro material)')
    change_3&.update!(name: 'Tanques')

    change_4 = BreedingSiteType.find_by(name: 'Bidones o Cilindros (metal, plástico)')
    change_4&.update!(name: 'Bidones o Cilindros')

    change_5 = BreedingSiteType.find_by(name: 'Estructura o partes de la casa')
    change_5&.update!(name: 'Estructura de la casa')

    Option.find_by(name_es: 'Elementos naturales')&.update!(name_es: 'Plantas, frutas y verduras',
                                                            name_en: 'Plants, fruits and vegetables', name_pt: 'Plantas, frutos e legumes')

    Option.find_by(name_es: 'Llanta')&.update!(name_es: 'Llantas',
                                               name_en: 'Tire', name_pt: 'Pneu')

    Option.find_by(name_es: 'Tanques (cemento, polietileno, metal, otro material)')&.update!(name_es: 'Tanques',
                                                                                             name_en: 'Tanks', name_pt: 'Tanques')

    Option.find_by(name_es: 'Bidones o Cilindros (metal, plástico)')&.update!(name_es: 'Bidones o Cilindros', name_en: 'Drums or cylinders',
                                                                              name_pt: 'Tambores ou cilindros')

    Option.find_by(name_es: 'Estructura o partes de la casa')&.update!(name_es: 'Estructura de la casa', name_en: 'Structure of the house',
                                                                       name_pt: 'Estrutura da casa')

    question = Question.find_by(question_text_es: '¿Qué tipo de contenedor encontraste?')

    return unless question

    option_params = {
      group_es: 'No permanentes',
      group_en: 'Non permanent',
      group_pt: 'Não permanente',
      name_es: 'Maceteros y floreros',
      name_en: 'Flower pots and vases',
      name_pt: 'Vasos de flores e vasos',
      resource_id: BreedingSiteType.find_by(name: 'Maceteros y floreros')&.id,
      question: question
    }

    Option.create!(option_params)

    option_params = {
      group_es: 'Permanentes',
      group_en: 'Permanent',
      group_pt: 'Permanentes',
      name_es: 'Sumidero',
      name_en: 'Sump',
      name_pt: 'Drenagem',
      resource_id: BreedingSiteType.find_by(name: 'Sumidero')&.id,
      question: question
    }
    Option.create!(option_params)

    option_params = {
      group_es: 'No permanentes',
      group_en: 'Non permanent',
      group_pt: 'Não permanente',
      name_es: 'Criaderos, bebederos y acuarios',
      name_en: 'Hatcheries, drinking troughs and aquariums',
      name_pt: 'Incubadoras, bebedouros e aquários',
      resource_id: BreedingSiteType.find_by(name: 'Criaderos, bebederos y acuarios')&.id,
      question: question
    }
    Option.create!(option_params)
  end
end
