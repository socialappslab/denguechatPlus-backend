# db/seeds/questions_data.rb

unless SeedTask.find_by(task_name: 'add_container_protections_v1')
  ContainerProtection.create!(name_es: 'Tapa hermética', name_en: 'Hermetic lid', name_pt: 'Tampa hermética',
                              color: 'green')
  ContainerProtection.create!(name_es: 'Tapa no hermética', name_en: 'Non-hermetic lid',
                              name_pt: 'Tampa não hermética', color: 'yellow')
  ContainerProtection.create!(name_es: 'Techo', name_en: 'Roof', name_pt: 'Telhado', color: 'yellow')
  ContainerProtection.create!(name_es: 'Otro', name_en: 'Other', name_pt: 'Outro', color: 'yellow')
  ContainerProtection.create!(name_es: 'No tiene', name_en: 'None', name_pt: 'Sem proteção', color: 'red')
  SeedTask.create!(task_name: 'add_container_protections_v1')
end

# create elimination methods
unless SeedTask.find_by(task_name: 'create_method_elimination')
  EliminationMethodType.destroy_all
  EliminationMethodType.create!(
    [
      { name_es: 'El contenedor fue protegido', name_en: 'The container was protected',
        name_pt: 'O contêiner foi protegido' },
      { name_es: 'El contenedor fue descartado', name_en: 'The container was discarded',
        name_pt: 'O contêiner foi descartado' },
      { name_es: 'El agua del contenedor fue tirado', name_en: 'The container was thrown away',
        name_pt: 'O contêiner foi jogado fora' },
      { name_es: 'El contenedor fue trasladado a un lugar seguro', name_en: 'The container was moved to a safe place',
        name_pt: 'O contêiner foi movido para um lugar seguro' },
      { name_es: 'El contenedor fue limpiado', name_en: 'The container was cleaned', name_pt: 'O contêiner foi limpo' },
      { name_es: 'Ninguna acción', name_en: 'No action', name_pt: 'Nenhuma ação' }
    ]
  )
  SeedTask.create!(task_name: 'create_method_elimination')
end

# create water sources types
unless SeedTask.find_by(task_name: 'create_water_sources_types_v1')
  WaterSourceType.destroy_all
  WaterSourceType.create!(
    [
      { name: 'Agua del grifo o potable' },
      { name: 'Agua activamente recogida. Ejemplo: canaleta, gotera, techo.' },
      { name: 'Agua pasivamente recogida. Ejemplo: la lluvia lo llenó.' },
      { name: 'Otro' }
    ]
  )
  SeedTask.create!(task_name: 'create_water_sources_types_v1')
end

# create container types
unless SeedTask.find_by(task_name: 'create_breeding_site_types_v3')
  BreedingSiteType.destroy_all

  SeedTask.create(task_name: 'add_new_container_types')

  BreedingSiteType.create!(name: 'Tanques', container_type: 'permanent')

  BreedingSiteType.create!(name: 'Bidones o Cilindros', container_type: 'permanent')

  BreedingSiteType.create!(name: 'Pozos', container_type: 'permanent')

  BreedingSiteType.create!(name: 'Estructura de la casa', container_type: 'permanent')

  BreedingSiteType.create!(name: 'Sumidero', container_type: 'permanent')

  BreedingSiteType.create!(name: 'Llantas', container_type: 'non-permanent')

  BreedingSiteType.create!(name: 'Plantas, frutas y verduras', container_type: 'non-permanent')

  BreedingSiteType.create!(name: 'Criaderos, bebederos y acuarios', container_type: 'non-permanent')

  BreedingSiteType.create!(name: 'Maceteros y floreros', container_type: 'non-permanent')

  BreedingSiteType.create!(name: 'Otros', container_type: 'non-permanent')

  SeedTask.create!(task_name: 'create_breeding_site_types_v3')
end

unless SeedTask.find_by(task_name: 'add_type_contents_v1')
  TypeContent.destroy_all
  TypeContent.create!(name_es: 'Larvas', name_en: 'Larvae', name_pt: 'Larvas')
  TypeContent.create!(name_es: 'Pupas', name_en: 'Pupae', name_pt: 'Pupas')
  TypeContent.create!(name_es: 'Huevos', name_en: 'Eggs', name_pt: 'Ovos')
  TypeContent.create!(name_es: 'Nada', name_en: 'None', name_pt: 'Nada')
  SeedTask.create!(task_name: 'add_type_contents_v1')
end

QUESTIONS_DATA = [
  {
    id: 1,
    question_text_es: '¿Me dieron permiso para visitar la casa?',
    question_text_en: 'Did they give me permission to visit the house?',
    question_text_pt: 'Eles me deram permissão para visitar a casa?',
    type_field: 'list',
    resource_name: '',
    resource_type: 'attribute',
    options: [
      { name_es: 'Sí, tengo permiso para esta visita', name_en: 'Yes, I have permission for this visit',
        name_pt: 'Sim, tenho permissão para esta visita', required: false, next: 2, type_option: 'boolean', value: 1 },
      { name_es: 'No, no me dieron permiso para esta visita', name_en: 'No, I was not given permission for this visit',
        name_pt: 'Não, não me deram permissão para esta visita', required: false, next: -1, type_option: 'boolean', value: 0 },
      { name_es: 'La casa está cerrada', name_en: 'The house is closed', name_pt: 'A casa está fechada',
        required: false, next: -1, type_option: 'boolean', value: 0 },
      { name_es: 'La casa está deshabitada', name_en: 'The house is uninhabited', name_pt: 'A casa está desabitada',
        required: false, next: -1, type_option: 'boolean', value: 0 },
      { name_es: 'Me pidieron regresar en otra ocasión', name_en: 'I was asked to return another time',
        name_pt: 'Pediram-me para voltar em outra ocasião', required: false, next: -1, type_option: 'boolean', value: 0 },
      { name_es: 'Otra explicación', name_en: 'Another explanation', name_pt: 'Outra explicação',
        type_option: 'textArea', required: false, next: -1 }
    ]
  },
  {
    id: 2,
    question_text_es: 'Visitemos la casa',
    question_text_en: 'Let’s visit the house',
    question_text_pt: 'Vamos visitar a casa',
    description_es: "Lleguemos a la casa con mucho respeto.\n\n Es importante que las personas nos sientan como alguien que les llega a apoyar para prevenir el dengue\n\nPidamos permiso para pasar.\n\nNo lleguemos como inspectores,o para juzgar al hogar.",
    description_en: "Let’s approach the house with a lot of respect.\n\nIt’s important for people to feel that we are there to support them in preventing dengue.\n\nLet’s ask for permission to enter.\n\nWe should not arrive as inspectors or to judge the home.",
    description_pt: "Vamos nos aproximar à casa com muito respeito.\n\nÉ importante que as pessoas sintam que estamos lá para apoiá-las na prevenção da dengue.\n\nVamos pedir permissão para entrar.\n\nNão devemos chegar como inspetores ou para julgar o lar.",
    type_field: 'splash',
    resource_name: '',
    resource_type: 'attribute',
    next: 3,
    options: []
  },
  {
    id: 3,
    question_text_es: '¿Quién te acompaña hoy en esta visita?',
    question_text_en: 'Who is accompanying you today on this visit?',
    question_text_pt: 'Quem está te acompanhando hoje nesta visita?',
    type_field: 'multiple',
    resource_name: '',
    resource_type: 'attribute',
    next: 4,
    options: [
      { name_es: 'Adulto mayor', name_en: 'Senior adult', name_pt: 'Adulto idoso', required: false },
      { name_es: 'Adulto hombre', name_en: 'Adult man', name_pt: 'Homem adulto', required: false },
      { name_es: 'Adulto mujer', name_en: 'Adult woman', name_pt: 'Mulher adulta', required: false },
      { name_es: 'Joven hombre', name_en: 'Young man', name_pt: 'Homem jovem', required: false },
      { name_es: 'Joven mujer', name_en: 'Young woman', name_pt: 'Mulher jovem', required: false },
      { name_es: 'Niños\as', name_en: 'Children', name_pt: 'Crianças', required: false }
    ]
  },
  {
    id: 4,
    question_text_es: 'Por favor informemos a la familia sobre',
    question_text_en: 'Please inform the family about',
    question_text_pt: 'Por favor, informe a família sobre',
    type_field: 'multiple',
    resource_name: '',
    resource_type: 'attribute',
    next: 5,
    options: [
      { name_es: 'Explicación de larvas y pupas', name_en: 'Explanation of larvae and pupae',
        name_pt: 'Explicação de larvas e pupas', required: true },
      { name_es: 'Explicación sobre cómo se reproduce el zancudo',
        name_en: 'Explanation of how the mosquito reproduces', name_pt: 'Explicação sobre como o mosquito se reproduz', required: true },
      { name_es: 'Otro tópico importante', name_en: 'Another important topic', name_pt: 'Outro tópico importante',
        type_option: 'textArea' }
    ]
  },
  {
    id: 5,
    question_text_es: '¿Dónde comienza la visita?',
    question_text_en: 'Where does the visit start?',
    question_text_pt: 'Onde começa a visita?',
    type_field: 'list',
    resource_name: '',
    resource_type: 'attribute',
    options: [
      { name_es: 'En la huerta', name_en: 'In the orchard', name_pt: 'Na horta', next: 6 },
      { name_es: 'En la casa', name_en: 'In the house', name_pt: 'Na casa', next: 8 }
    ]
  },
  {
    id: 6,
    question_text_es: 'Comencemos en la huerta',
    question_text_en: "Let's start in the orchard",
    question_text_pt: 'Comecemos pelo jardim',
    description_es: "Vamos a buscar todos los recipientes que contienen agua y potencialmente son criaderos de zancudos.\n\nIniciamos la revisión de la vivienda por la derecha y finalizamos por la izquierda.",
    description_en: "We're going to look for all the containers that contain water and could potentially be mosquito breeding grounds.\n\nWe start the review of the house on the right and finish on the left.",
    description_pt: "Vamos buscar todos os recipientes que contêm água e potencialmente são criadouros de mosquitos.\n\nComeçamos a revisão da casa pela direita e terminamos pela esquerda.",
    type_field: 'splash',
    resource_name: '',
    resource_type: 'attribute',
    next: 7,
    options: []
  },
  {
    id: 7,
    question_text_es: '¿Encontraste un contenedor?',
    question_text_en: 'Did you find a container?',
    question_text_pt: 'Você encontrou um recipiente?',
    type_field: 'list',
    resource_name: '',
    resource_type: 'attribute',
    options: [
      { name_es: 'Sí, encontré', name_en: 'Yes, I found', name_pt: 'Sim, eu encontrei', next: 10 },
      { name_es: 'No, no encontré', name_en: 'No, I did not find', name_pt: 'Não, eu não encontrei', next: 8 }
    ]
  },
  {
    id: 8,
    question_text_es: 'Revisemos dentro de la casa',
    question_text_en: "Let's check inside the house",
    question_text_pt: 'Vamos ver o interior da casa',
    description_es: "Vamos a buscar todos los recipientes que contienen agua y potencialmente son criaderos de zancudos.\n\nIniciamos la revisión de la vivienda por la derecha y finalizamos por la izquierda.",
    description_en: "We're going to look for all the containers that contain water and could potentially be mosquito breeding grounds.\n\nWe start the review of the house on the right and finish on the left.",
    description_pt: "Vamos buscar todos os recipientes que contêm água e potencialmente são criadouros de mosquitos.\n\nComeçamos a revisão da casa pela direita e terminamos pela esquerda.",
    type_field: 'splash',
    resource_name: '',
    resource_type: 'attribute',
    next: 9
  },
  {
    id: 9,
    question_text_es: '¿Encontraste un contenedor?',
    question_text_en: 'Did you find a container?',
    question_text_pt: 'Você encontrou um recipiente?',
    type_field: 'list',
    resource_name: '',
    resource_type: 'attribute',
    options: [
      { name_es: 'Sí, encontré', name_en: 'Yes, I found', name_pt: 'Sim, eu encontrei', next: 10 },
      { name_es: 'No, no encontré', name_en: 'No, I did not find', name_pt: 'Não, eu não encontrei', next: -1 }
    ]
  },
  {
    id: 10,
    question_text_es: '¿Qué tipo de contenedor encontraste?',
    question_text_en: 'What type of container did you find?',
    question_text_pt: 'Que tipo de contêiner você encontrou?',
    type_field: 'list',
    resource_name: 'breeding_site_type_id',
    resource_type: 'relation',
    next: 11,
    options: [
      { group_es: 'No permanentes', group_en: 'Non permanent', group_pt: 'Não permanente', name_es: 'Llantas',
        name_en: 'Tire', name_pt: 'Pneu', resource_id: BreedingSiteType.find_by(name: 'Llantas').id },

      { group_es: 'No permanentes', group_en: 'Non permanent', group_pt: 'Não permanente',
        name_es: 'Plantas, frutas y verduras', name_en: 'Plants, fruits and vegetables', name_pt: 'Plantas, frutos e legumes', resource_id: BreedingSiteType.find_by(name: 'Plantas, frutas y verduras').id },

      { group_es: 'No permanentes', group_en: 'Non permanent', group_pt: 'Não permanente', name_es: 'Criaderos, bebederos y acuarios',
        name_en: 'Hatcheries, drinking troughs and aquariums', name_pt: 'Incubadoras, bebedouros e aquários', resource_id: BreedingSiteType.find_by(name: 'Criaderos, bebederos y acuarios').id },

      { group_es: 'No permanentes', group_en: 'Non permanent', group_pt: 'Não permanente', name_es: 'Maceteros y floreros',
        name_en: 'Flower pots and vases', name_pt: 'Vasos de flores e vasos', resource_id: BreedingSiteType.find_by(name: 'Maceteros y floreros').id },

      { group_es: 'No permanentes', group_en: 'Non permanent', group_pt: 'Não permanente', name_es: 'Otros',
        name_en: 'Others', name_pt: 'Outros', resource_id: BreedingSiteType.find_by(name: 'Otros').id },

      { group_es: 'Permanentes', group_en: 'Permanent', group_pt: 'Permanentes', name_es: 'Tanques',
        name_en: 'Tanks', name_pt: 'Tanques', resource_id: BreedingSiteType.find_by(name: 'Tanques').id },

      { group_es: 'Permanentes', group_en: 'Permanent', group_pt: 'Permanentes', name_es: 'Bidones o Cilindros', name_en: 'Drums or cylinders',
        name_pt: 'Tambores ou cilindros', resource_id: BreedingSiteType.find_by(name: 'Bidones o Cilindros').id },

      { group_es: 'Permanentes', group_en: 'Permanent', group_pt: 'Permanentes', name_es: 'Pozos', name_en: 'Wells',
        name_pt: 'Poços', resource_id: BreedingSiteType.find_by(name: 'Pozos').id },

      { group_es: 'Permanentes', group_en: 'Permanent', group_pt: 'Permanentes', name_es: 'Estructura de la casa', name_en: 'Structure of the house',
        name_pt: 'Estrutura da casa', resource_id: BreedingSiteType.find_by(name: 'Estructura de la casa').id },

      { group_es: 'Permanentes', group_en: 'Permanent', group_pt: 'Permanentes', name_es: 'Sumidero', name_en: 'Sump',
        name_pt: 'Drenagem', resource_id: BreedingSiteType.find_by(name: 'Sumidero').id }
    ]
  },
  {
    id: 11,
    question_text_es: '¿El contenedor contiene agua?',
    question_text_en: 'Does the container hold water?',
    question_text_pt: 'O recipiente contém água?',
    type_field: 'list',
    resource_name: 'has_water',
    resource_type: 'attribute',
    options: [
      { name_es: 'Sí, contiene agua', name_en: 'Yes, it holds water', name_pt: 'Sim, contém água', next: 12,
        type_option: 'boolean', value: 1 },
      { name_es: 'No, no contiene agua', name_en: 'No, it does not hold water', name_pt: 'Não, não contém água',
        next: 19, type_option: 'boolean', value: 0 }
    ]
  },
  {
    id: 12,
    question_text_es: '¿De dónde proviene el agua?',
    question_text_en: 'Where does the water come from?',
    question_text_pt: 'De onde vem a água?',
    type_field: 'list',
    resource_name: 'water_source_type_id',
    resource_type: 'relation',
    next: 13,
    options: [
      { name_es: 'Agua del grifo o potable', name_en: 'Tap water or drinkable water',
        name_pt: 'Água de torneira ou potável', next: 13, resource_id: WaterSourceType.find_by(name: 'Agua del grifo o potable').id },
      { name_es: 'Agua activamente recogida. Ejemplo: canaleta, gotera, techo.',
        name_en: 'Actively collected water. Example: gutter, leak, roof.', name_pt: 'Água coletada ativamente. Exemplo: calha, goteira, telhado.', next: 13, resource_id: WaterSourceType.find_by(name: 'Agua activamente recogida. Ejemplo: canaleta, gotera, techo.').id },
      { name_es: 'Agua pasivamente recogida. Ejemplo: la lluvia lo llenó.',
        name_en: 'Passively collected water. Example: rain filled it.', name_pt: 'Água coletada passivamente. Exemplo: a chuva o encheu.', next: 13, resource_id: WaterSourceType.find_by(name: 'Agua pasivamente recogida. Ejemplo: la lluvia lo llenó.').id },
      { name_es: 'Otro', name_en: 'Other', name_pt: 'Outro', next: 13,
        resource_id: WaterSourceType.find_by(name: 'Otro').id, type_option: 'textArea' }
    ]
  },
  {
    id: 13,
    question_text_es: '¿El contenedor está protegido?',
    question_text_en: 'Is the container protected?',
    question_text_pt: 'O recipiente está protegido?',
    type_field: 'list',
    resource_name: 'container_protection_id',
    resource_type: 'relation',
    next: 14,
    options: [
      { name_es: 'Sí, tiene una tapa hermética', name_en: 'Yes, it has a sealed lid',
        name_pt: 'Sim, tem uma tampa hermética', next: 14, group_es: 'Tapa', group_en: 'Lid',
        group_pt: 'Tampa', resource_id: ContainerProtection.find_by(name_es: 'Tapa hermética').id,
        status_color: Constants::ContainerStatus::NOT_INFECTED },
      { name_es: 'Sí, tiene una tapa no hermética', name_en: 'Yes, it has a non-sealed lid',
        name_pt: 'Sim, tem uma tampa não hermética', group_es: 'Tapa', group_en: 'Lid', group_pt: 'Tampa',
        next: 14, resource_id: ContainerProtection.find_by(name_es: 'Tapa no hermética').id,
        status_color: Constants::ContainerStatus::POTENTIALLY_INFECTED },
      { name_es: 'Sí, está bajo techo', name_en: 'Yes, it is under a roof', name_pt: 'Sim, está sob um telhado',
        next: 14, group_es: 'Techo', group_en: 'Roof', group_pt: 'Telhado', resource_id: ContainerProtection.find_by(name_es: 'Techo').id,
        status_color: Constants::ContainerStatus::POTENTIALLY_INFECTED },
      { name_es: 'Otro tipo de protección', name_en: 'Another type of protection', name_pt: 'Outro tipo de proteção',
        next: 14, group_es: 'Otros', group_en: 'Others', group_pt: 'Outros', resource_id: ContainerProtection.find_by(name_es: 'Otro').id,
        status_color: Constants::ContainerStatus::POTENTIALLY_INFECTED },
      { name_es: 'No tiene protección', name_en: 'It has no protection', name_pt: 'Não tem proteção', next: 14,
        group_es: 'Otros', group_en: 'Others', group_pt: 'Outros', resource_id: ContainerProtection.find_by(name_es: 'No tiene').id,
        status_color: Constants::ContainerStatus::POTENTIALLY_INFECTED }
    ]
  },
  {
    id: 14,
    question_text_es: 'Pregunte si en los últimos 30 días: ¿fue el contenedor tratado por el Ministerio de Salud con piriproxifeno o abate?',
    question_text_en: 'Ask if in the last 30 days: was the container treated by the Ministry of Health with pyriproxyfen or abate?',
    question_text_pt: 'Pergunte se nos últimos 30 dias: o recipiente foi tratado pelo Ministério da Saúde com piriproxifeno ou abate?',
    type_field: 'list',
    resource_name: 'was_chemically_treated',
    resource_type: 'attribute',
    next: 15,
    options: [
      { name_es: 'Sí, fue tratado (revise el registro detrás de la puerta)',
        name_en: 'Yes, it was treated (check the record behind the door)', name_pt: 'Sim, foi tratado (verifique o registro atrás da porta)', next: 15 },
      { name_es: 'No, no fue tratado', name_en: 'No, it was not treated', name_pt: 'Não, não foi tratado', next: 15 },
      { name_es: 'No lo sé', name_en: 'I don’t know', name_pt: 'Não sei', next: 15 }
    ]
  },
  {
    id: 15,
    question_text_es: 'En este contenedor hay...',
    question_text_en: 'In this container there are...',
    question_text_pt: 'Neste recipiente há...',
    type_field: 'multiple',
    resource_name: 'type_content_id',
    resource_type: 'relation',
    next: 16,
    options: [
      { name_es: 'Larvas', name_en: 'Larvae', name_pt: 'Larvas', next: 17, group_es: 'Estadios', group_en: 'Stages', group_pt: 'Estágios',
        resource_id: TypeContent.find_by(name_es: 'Larvas').id, status_color: Constants::ContainerStatus::INFECTED },
      { name_es: 'Pupas', name_en: 'Pupae', name_pt: 'Pupas', next: 17, group_es: 'Estadios', group_en: 'Stages', group_pt: 'Estágios',
        resource_id: TypeContent.find_by(name_es: 'Pupas').id, status_color: Constants::ContainerStatus::INFECTED },
      { name_es: 'Huevos', name_en: 'Eggs', name_pt: 'Ovos', next: 17, group_es: 'Estadios', group_en: 'Stages', group_pt: 'Estágios',
        resource_id: TypeContent.find_by(name_es: 'Huevos').id, status_color: Constants::ContainerStatus::INFECTED },
      { name_es: 'Nada', name_en: 'Nothing', name_pt: 'Nada', next: 16, group_es: 'Nada', group_en: 'Nothing', group_pt: 'Nada',
        resource_id: TypeContent.find_by(name_es: 'Nada').id, disable_other_options: true }
    ]
  },
  {
    id: 16,
    question_text_es: '¿Hay otros contenedores exactamente del mismo tipo con agua que no tienen larvas, pupas o huevos?',
    question_text_en: 'Are there other containers of exactly the same type with water that have no larvae, pupae or eggs?',
    question_text_pt: 'Há outros recipientes exatamente do mesmo tipo com água que não têm larvas, pupas ou ovos?',
    type_field: 'list',
    notes: 'Nota: Si el mismo tipo de contenedor tiene agua, larvas, pupas o huevos, debe registrarse individualmente.',
    resource_name: 'quantity_founded',
    resource_type: 'attribute',
    next: 17,
    options: [
      { name_es: 'Si', name_en: 'Yes', name_pt: 'Sim', next: 17, type_option: 'inputNumber', value: 1 },
      { name_es: 'No', name_en: 'No', name_pt: 'No', next: 17, type_option: 'boolean', value: 0 }
    ]
  },
  {
    id: 17,
    question_text_es: '¿Puedes subir una foto del tipo de contenedor?',
    question_text_en: 'Can you upload a photo of the type of container?',
    question_text_pt: 'Você pode enviar uma foto do tipo de recipiente?',
    type_field: 'list',
    resource_name: 'photo_id',
    resource_type: 'attribute',
    next: 18,
    options: [
      { name_es: 'Si, si puedo', name_en: 'Yes, I can', name_pt: 'Sim', next: 18, type_option: 'boolean', value: 1 },
      { name_es: 'No, no no puedo', name_en: 'No, I cant', name_pt: 'No', next: 18, type_option: 'boolean', value: 0 }
    ]
  },
  {
    id: 18,
    question_text_es: 'Registremos acciones tomadas sobre el contenedor',
    question_text_en: 'Let’s record actions taken on the container',
    question_text_pt: 'Vamos registrar as ações tomadas sobre o recipiente',
    type_field: 'splash',
    resource_name: '',
    resource_type: 'attribute',
    next: 19,
    options: []
  },
  {
    id: 19,
    question_text_es: '¿Qué acción se realizó con el contenedor?',
    question_text_en: 'What action was taken with the container?',
    question_text_pt: 'Que ação foi realizada com o recipiente?',
    type_field: 'list',
    resource_name: 'elimination_method_type_id',
    resource_type: 'relation',
    next: -1,
    options: [
      { name_es: 'El contenedor fue protegido', name_en: 'The container was protected',
        name_pt: 'O recipiente foi protegido', resource_id: EliminationMethodType.find_by(name_es: 'El contenedor fue protegido').id },

      { name_es: 'El contenedor fue descartado', name_en: 'The container was discarded',
        name_pt: 'O recipiente foi descartado', resource_id: EliminationMethodType.find_by(name_es: 'El contenedor fue descartado').id },

      { name_es: 'El agua del contenedor fue tirada', name_en: 'The water from the container was discarded',
        name_pt: 'A água do recipiente foi descartada', resource_id: EliminationMethodType.find_by(name_es: 'El agua del contenedor fue tirado').id },

      { name_es: 'El contenedor fue trasladado a un lugar seguro',
        name_en: 'The container was moved to a safe location', name_pt: 'O recipiente foi transferido para um local seguro', resource_id: EliminationMethodType.find_by(name_es: 'El contenedor fue trasladado a un lugar seguro').id },

      { name_es: 'El contenedor fue limpiado', name_en: 'The container was cleaned', name_pt: 'O recipiente foi limpo',
        resource_id: EliminationMethodType.find_by(name_es: 'El contenedor fue limpiado') },

      { name_es: 'Ninguna acción', name_en: 'No action', name_pt: 'Nenhuma ação',
        resource_id: EliminationMethodType.find_by(name_es: 'Ninguna acción') },

      { name_es: 'Otro', name_en: 'Other', name_pt: 'Outro',
        resource_id: EliminationMethodType.find_by(name_es: 'Otro'), type_option: 'textArea' }
    ]
  }
].freeze
