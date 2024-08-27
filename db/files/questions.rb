# db/seeds/questions_data.rb

QUESTIONS_DATA = [
  {
    id: 8,
    question: "Por favor informemos a la familia sobre",
    type_field: "multiple",
    next: 1,
    options: [
      { name: "Explicación de larvas y pupas", required: true },
      { name: "Explicación sobre cómo se reproduce el zancudo", required: true },
      { name: "Otro tópico importante", text_area: true }
    ]
  },
  {
    id: 1,
    question: "¿Dónde comienza la visita?",
    type_field: "list",
    options: [
      { name: "En la huerta", next: 2 },
      { name: "En la casa", next: 3 }
    ]
  },
  {
    id: 2,
    question: "En la huerta",
    description: "Vamos a buscar todos los recipientes que contienen agua y potencialmente son criaderos de zancudos.",
    type_field: "splash",
    next: 4
  },
  {
    id: 3,
    question: "En la casa",
    description: "Vamos a buscar todos los recipientes que contienen agua y potencialmente son criaderos de zancudos.",
    type_field: "splash",
    next: 5
  },
  {
    id: 4,
    question: "¿Encontraste un contenedor?",
    type_field: "list",
    options: [
      { name: "Sí, encontré", next: "inspection" },
      { name: "No, no encontré", next: 3 }
    ]
  },
  {
    id: 5,
    question: "¿Encontraste un contenedor?",
    type_field: "list",
    options: [
      { name: "Sí, encontré", next: 6 },
      { name: "No, no encontré", next: -1 },
      { name: "Otro", text_area: true, next: -1 }
    ]
  },
  {
    id: 6,
    question: "¿Qué tipo de contenedor encontraste?",
    type_field: "list",
    next: 7,
    options: [
      { name: "Tanques (cemento, polietileno, metal, otro material)" },
      { name: "Bidones o cilindros (metal, plástico)" },
      { name: "Pozos" },
      { name: "Estructura o partes de la casa" },
      { name: "Llanta" },
      { name: "Elementos naturales" },
      { name: "Otros" }
    ]
  },
  {
    id: 7,
    question: "¿Registrar otro contenedor?",
    type_field: "list",
    options: [
      { name: "Sí, registrar", next: 5 },
      { name: "No, no es necesario", next: 7 }
    ]
  }
].freeze
