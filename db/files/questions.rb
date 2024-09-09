# db/seeds/questions_data.rb

QUESTIONS_DATA = [
  {
    id: 8,
    question_text_es: 'Por favor informemos a la familia sobre',
    question_text_en: 'Please inform the family about',
    question_text_pt: 'Por favor, informe a família sobre',
    type_field: 'multiple',
    next: 1,
    options: [
      { name_es: 'Explicación de larvas y pupas', name_en: 'Explanation of larvae and pupae', name_pt: 'Explicação de larvas e pupas', required: true },
      { name_es: 'Explicación sobre cómo se reproduce el zancudo', name_en: 'Explanation of how the mosquito reproduces', name_pt: 'Explicação sobre como o mosquito se reproduz', required: true },
      { name_es: 'Otro tópico importante', name_en: 'Another important topic', name_pt: 'Outro tópico importante', text_area: true },
    ]
  },
  {
    id: 1,
    question_text_es: '¿Dónde comienza la visita?',
    question_text_en: 'Where does the visit start?',
    question_text_pt: 'Onde começa a visita?',
    type_field: 'list',
    options: [
      { name_es: 'En la huerta', name_en: 'In the orchard', name_pt: 'Na horta', next: 2 },
      { name_es: 'En la casa', name_en: 'In the house', name_pt: 'Na casa', next: 3 },
    ]
  },
  {
    id: 2,
    question_text_es: 'En la huerta',
    question_text_en: 'In the orchard',
    question_text_pt: 'Na horta',
    description_es: "Vamos a buscar todos los recipientes que contienen agua y potencialmente son criaderos de zancudos.\n\nIniciamos la revisión de la vivienda por la derecha y finalizamos por la izquierda.",
    description_en: "We're going to look for all the containers that contain water and could potentially be mosquito breeding grounds.\n\nWe start the review of the house on the right and finish on the left.",
    description_pt: "Vamos buscar todos os recipientes que contêm água e potencialmente são criadouros de mosquitos.\n\nComeçamos a revisão da casa pela direita e terminamos pela esquerda.",
    type_field: 'splash',
    next: 4
  },
  {
    id: 3,
    question_text_es: 'En la casa',
    question_text_en: 'In the house',
    question_text_pt: 'Na casa',
    description_es: "Lleguemos a la casa con mucho respeto.\n\nEs importante que las personas nos sientan como alguien que les llega a apoyar para prevenir el dengue.\n\nPidamos permiso para pasar.\n\nNo lleguemos como inspectores, o para juzgar al hogar.",
    description_en: "Let's arrive at the house with much respect.\n\nIt is important for people to perceive us as someone who arrives to support dengue prevention.\n\nLet's ask for permission to enter.\n\nWe shouldn't present ourselves as inspectors or to judge the household.",
    description_pt: "Vamos chegar na casa com muito respeito.\n\nÉ importante que as pessoas nos vejam como alguém que chega para apoiar a prevenção da dengue.\n\nVamos pedir permissão para entrar.\n\nNão devemos nos apresentar como inspetores, ou para julgar a casa.",
    type_field: 'splash',
    next: 5
  },
  {
    id: 4,
    question_text_es: '¿Encontraste un contenedor?',
    question_text_en: 'Did you find a container?',
    question_text_pt: 'Você encontrou um recipiente?',
    type_field: 'list',
    options: [
      { name_es: 'Sí, encontré', name_en: 'Yes, I found', name_pt: 'Sim, eu encontrei', next: 'inspection' },
      { name_es: 'No, no encontré', name_en: 'No, I did not find', name_pt: 'Não, eu não encontrei', next: 3 },
    ]
  },
  {
    id: 5,
    question_text_es: '¿Encontraste un contenedor?',
    question_text_en: 'Did you find a container?',
    question_text_pt: 'Você encontrou um recipiente?',
    type_field: 'list',
    options: [
      { name_es: 'Sí, encontré', name_en: 'Yes, I found', name_pt: 'Sim, eu encontrei', next: 6 },
      { name_es: 'No, no encontré', name_en: 'No, I did not find', name_pt: 'Não, eu não encontrei',  next: -1 },
      { name_es: 'Otro', name_en: 'Other', text_area: true, name_pt: 'Outro', next: -1 },
    ]
  },
  {
    id: 6,
    question_text_es: '¿Qué tipo de contenedor encontraste?',
    question_text_en: 'What type of container did you find?',
    question_text_pt: 'Que tipo de contêiner você encontrou?',
    type_field: 'list',
    next: 7,
    options: [
      { name_es: 'Tanques (cemento, polietileno, metal, otro material)', name_en: 'Tanks (cement, polyethylene, metal, other material)', name_pt: 'Tanques (cimento, polietileno, metal, outro material)' },
      { name_es: 'Bidones o cilindros (metal, plástico)', name_en: 'Drums or cylinders (metal, plastic)', name_pt: 'Tambores ou cilindros (metal, plástico)' },
      { name_es: 'Pozos', name_en: 'Wells', name_pt: 'Poços' },
      { name_es: 'Estructura o partes de la casa', name_en: 'Structure or parts of the house', name_pt: 'Estrutura ou partes da casa' },
      { name_es: 'Llanta', name_en: 'Tire', name_pt: 'Pneu' },
      { name_es: 'Elementos naturales', name_en: 'Natural elements', name_pt: 'Elementos naturais' },
      { name_es: 'Otros', name_en: 'Others', name_pt: 'Outros' },

    ]
  },
  {
    id: 7,
    question_text_es: '¿Registrar otro contenedor?',
    question_text_en: 'Register another container?',
    question_text_pt: 'Registrar outro contêiner?',
    type_field: 'list',
    options: [
      { name_es: 'Sí, registrar', name_en: 'Yes, register', name_pt: 'Sim, registrar', next: 5 },
      { name_es: 'No, no es necesario', name_pt: 'Não, não é necessário', name_en: "No, it's not necessary", next: 7 },
    ]
  }
].freeze
