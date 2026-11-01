# frozen_string_literal: true

REWARD_TYPES_DATA = [
  {
    code: 'skin', metric: 'worked_houses', position: 1,
    name_es: 'Skins', name_en: 'Skins', name_pt: 'Skins',
    levels: [
      { code: 'skin-polo', threshold: 50, position: 1, name_es: 'Polo', name_en: 'Polo shirt', name_pt: 'Camisa polo',
        color_primary: '#8A4B1E', color_secondary: '#A0612F', color_background: '#FBE3CC',
        ring_gradient: '#E8A96B,#9C5A2B', image: 'skin-polo.png' },
      { code: 'skin-lupa', threshold: 100, position: 2, name_es: 'Lupa', name_en: 'Magnifier', name_pt: 'Lupa',
        color_primary: '#5B6570', color_secondary: '#7D8793', color_background: '#F4F6F8',
        ring_gradient: '#F1F3F5,#9AA3AD', image: 'skin-lupa.png' },
      { code: 'skin-capa', threshold: 200, position: 3, name_es: 'Capa', name_en: 'Cape', name_pt: 'Capa',
        color_primary: '#9A6A00', color_secondary: '#C08405', color_background: '#FFF6D1',
        ring_gradient: '#FFE27A,#C98A0B', image: 'skin-capa.png' }
    ]
  },
  {
    code: 'star', metric: 'positive_containers', position: 2,
    name_es: 'Medallas', name_en: 'Medals', name_pt: 'Medalhas',
    levels: [
      { code: 'star-detective', threshold: 1, position: 1, name_es: 'Detective del Zancudo',
        name_en: 'Mosquito Detective', name_pt: 'Detetive do Mosquito',
        color_primary: '#FDEB3D', color_secondary: '#D9B800', color_background: '#FFFBE0',
        ring_gradient: '#FFF59A,#E2C300', image: 'star-1.png' },
      { code: 'star-sargento', threshold: 5, position: 2, name_es: 'Sargento del Zancudo',
        name_en: 'Mosquito Sergeant', name_pt: 'Sargento do Mosquito',
        color_primary: '#FF8133', color_secondary: '#D45A12', color_background: '#FFF0E6',
        ring_gradient: '#FFC199,#E0631A', image: 'star-2.png' },
      { code: 'star-protector', threshold: 15, position: 3, name_es: 'Protector de la Salud',
        name_en: 'Health Protector', name_pt: 'Protetor da Saúde',
        color_primary: '#62A9EA', color_secondary: '#2F7CC4', color_background: '#EAF4FD',
        ring_gradient: '#B5D9F7,#3A86CC', image: 'star-3.png' },
      { code: 'star-paladin', threshold: 30, position: 4, name_es: 'Paladín de la Salud',
        name_en: 'Health Paladin', name_pt: 'Paladino da Saúde',
        color_primary: '#62A9EA', color_secondary: '#2F7CC4', color_background: '#262626',
        ring_gradient: '#5A5A5A,#141414', image: 'star-4.png' },
      { code: 'star-campeon', threshold: 50, position: 5, name_es: 'Campeón de la Comunidad',
        name_en: 'Community Champion', name_pt: 'Campeão da Comunidade',
        color_primary: '#FF8133', color_secondary: '#D45A12', color_background: '#262626',
        ring_gradient: '#5A5A5A,#141414', image: 'star-5.png' }
    ]
  }
].freeze
