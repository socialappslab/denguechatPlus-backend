# frozen_string_literal: true
require 'json'
require 'open-uri'
require_relative '../db/files/questions'
require_relative '../db/files/permissions'
require_relative '../db/files/users'

###################################
###################################
# Auxiliary methods
###################################
###################################

# get images from internet for container type
def get_all_images_for_containers
  results = []
  types = {
    tanque: 'https://thumbs.dreamstime.com/z/tanque-de-agua-cemento-227472829.jpg?ct=jpeg',
    bidon: 'https://www.um.es/grzba/Vigilancia_Mosquito_Tigre/Imagenes/cria/Bidones.jpg',
    pozo: 'https://www.iagua.es/sites/default/files/styles/thumbnail-830x455/public/pozo_agua_portada.jpg?itok=yAUNA4_N',
    house_parts: 'https://www.um.es/grzba/Vigilancia_Mosquito_Tigre/Imagenes/cria/fuente.jpg',
    tires: 'https://www.um.es/grzba/Vigilancia_Mosquito_Tigre/Imagenes/cria/neumaticos.jpg',
    others: 'https://www.um.es/grzba/Vigilancia_Mosquito_Tigre/Imagenes/cria/Cubo.jpg',
    natural_elements: 'https://pacificsprings.com.au/wp-content/uploads/2023/08/natural-spring-water.jpg'
  }.freeze

  types.each do |key, url|
    begin
      res = URI.open(url)
    rescue StandardError => error
      Rails.logger.debug error
      res = nil
    end
    results << { io: res, filename: key.to_s, content_type: 'image/jpg' }
  end
  results
end

def get_images_for_questionnaire
  results = []
  types = {
    'En la huerta': 'https://i.imghippo.com/files/lBlRv1724220223.png',
    'En la casa': 'https://i.imghippo.com/files/hfv801724220367.png',
    'Tanques (cemento, polietileno, metal, otro material)': 'https://i.imghippo.com/files/owjeu1724220878.png',
    'Bidones o cilindros (metal, plástico)': 'https://i.imghippo.com/files/ta0H31724220912.png',
    'Pozos': 'https://i.imghippo.com/files/PXsOQ1724220823.png',
    'Estructura o partes de la casa': 'https://i.imghippo.com/files/z8Yex1724220962.png',
    'Llanta': 'https://i.imghippo.com/files/hYKbi1724220688.png',
    'Elementos naturales': 'https://i.imghippo.com/files/JjdHE1724220604.png',
    'Otros': 'https://i.imghippo.com/files/hxNCm1724220325.png',
  }.freeze

  types.each do |key, url|
    begin
      res = URI.open(url)
    rescue StandardError => error
      Rails.logger.debug error
      res = nil
    end
    results << { io: res, filename: key.to_s, content_type: 'image/jpg' }
  end
  results
end

###################################
###################################
# Create initial data
###################################
###################################

unless SeedTask.find_by(task_name: 'clean_db_v4')
  task_to_re_run = %i[create_wedges create_roles_v2 create_permissions_v2
                      assign_permissions_to_roles_v2 create_teams_v2 user_account_v2
                      create_house_blocks_v2 create_houses_v2 states_and_cities_v2]
  HouseBlock.destroy_all
  House.destroy_all
  UserAccount.destroy_all
  UserProfile.destroy_all
  Role.destroy_all
  Permission.destroy_all
  Inspection.destroy_all
  Visit.destroy_all
  Team.destroy_all
  Wedge.destroy_all
  Neighborhood.destroy_all
  State.destroy_all
  SeedTask.where(task_name: task_to_re_run).destroy_all
  SeedTask.create!(task_name: 'clean_db_v4') if State.count > 0 && City.count > 0

end

# default country
unless SeedTask.find_by(task_name: 'country')
  country = Country.create!(name: 'Peru')
  SeedTask.create!(task_name: 'country') if country.persisted?
end

# states_and_cities
unless SeedTask.find_by(task_name: 'states_and_cities_v2')
  country = Country.first
  data = JSON.parse(Rails.root.join('db/files/states_cities.json').read)
  data.each do |state|
    state_persisted = State.create!(name: state['state_name'], country:)

    #create cities
    state['cities']&.each do |city|
      city_persisted = City.create!(name: city['name'], state: state_persisted, country:)


      #create neighboorhoods
      city['neighborhoods']&.each do |neighborhood|
        Neighborhood.create!(name: neighborhood['name'], state: state_persisted, country:, city:city_persisted)
      end
    end
  end

  SeedTask.create!(task_name: 'states_and_cities_v2') if State.count > 0 && City.count > 0
end

#create default wedges
unless SeedTask.find_by(task_name: 'create_wedges')
  Wedge.create!(name: 'Cuña 1', sector: Neighborhood.last)
  Wedge.create!(name: 'Cuña 2', sector: Neighborhood.last)
  Wedge.create!(name: 'Cuña 3', sector: Neighborhood.last)
  Wedge.create!(name: 'Cuña 4', sector: Neighborhood.last)
  SeedTask.create!(task_name: 'create_wedges')
end

#create default special_places
unless SeedTask.find_by(task_name: 'create_special_places')
  SpecialPlace.create!(name: 'Cementerio')
  SpecialPlace.create!(name: 'Colegio')
  SeedTask.create!(task_name: 'create_special_places')
end

# default organization
unless SeedTask.find_by(task_name: 'organization')
  organization = Organization.create!(name: 'Tariki')
  SeedTask.create!(task_name: 'organization') if organization.persisted?
end

# roles
unless SeedTask.find_by(task_name: 'create_roles_v2')
  Constants::Role::ALLOWED_NAMES.each { |rol| Role.create!(name: rol) }
  SeedTask.create!(task_name: 'create_roles_v2') if Role.count == 4
end

# permissions
unless SeedTask.find_by(task_name: 'create_permissions_v2')
  Permission.insert_all(ACTION_AND_RESOURCES) # rubocop:disable Rails/SkipsModelValidations
  SeedTask.create!(task_name: 'create_permissions_v2') if Permission.count == 79
end

# assign permissions to roles
unless SeedTask.find_by(task_name: 'assign_permissions_to_roles_v2')
  ROLES_PERMISSIONS[:roles].each do |item|
    begin
      rol = Role.find_by(name: item[:name])
      permissions = []
      not_found = []
      item[:permissions].each do |permission|
        permission_found = Permission.find_by(name: permission[:name], resource: permission[:resource])
        if permission_found
          permissions << permission_found
        else
          not_found << "name: #{permission[:name]} - resource: #{permission[:resource]}"
          Rails.logger.debug not_found
        end
      end
    rescue StandardError => error
      Rails.logger.debug error
      Rails.logger.debug not_found
    end
    rol.permissions = permissions if permissions.any?
  end

  SeedTask.create!(task_name: 'assign_permissions_to_roles_v2')
end

#teams
unless SeedTask.find_by(task_name: 'create_teams_v2')
  Team.create!(name: 'Dengue killers', organization: Organization.first, sector: Neighborhood.last, wedge: Wedge.last)
  Team.create!(name: 'Anti Aedes', organization: Organization.first, sector: Neighborhood.last, wedge: Wedge.last)
  SeedTask.create!(task_name: 'create_teams_v2')

end

# user account and user_profile
unless SeedTask.find_by(task_name: 'user_account_v2')
  create_default_users
  SeedTask.create!(task_name: 'user_account_v2')
end

#create default_house_blocks
unless SeedTask.find_by(task_name: 'create_house_blocks_v2')

  team = Team.first
  team.members << UserAccount.find_by(username: 'brigadista').user_profile
  team.members.each_with_index { |brigadist, index|
 HouseBlock.create!(name: "Bloque #{index}", team_id: team.id, wedge: Wedge.last, brigadist:) }

  SeedTask.create!(task_name: 'create_house_blocks_v2')
end

#create houses
unless SeedTask.find_by(task_name: 'create_houses_v2')

  house_blocks = HouseBlock.all
  (1..10).each_with_index do |obj, index|
    house_block = house_blocks.sample
    house = House.new
    house.country = Country.first
    house.state = State.first
    house.city = City.first
    house.neighborhood = Neighborhood.first
    house.wedge = Wedge.first
    house.house_block = house_block
    house.created_by = UserProfile.first
    house.reference_code = index
    house.status = 'green'
    house.team = Team.first
    house.longitude = rand(680000.0..681000.0).round(10)
    house.latitude = rand(7471000.0..7472000.0).round(10)
    house.save!
  end

  SeedTask.create!(task_name: 'create_houses_v2')
end

#create breeding site types
unless SeedTask.find_by(task_name: 'create_breeding_site_types')
  BreedingSiteType.create!([{ name: 'permanente' }, { name: 'no permanente' }])
  SeedTask.create!(task_name: 'create_breeding_site_types')
end

#create container types
unless SeedTask.find_by(task_name: 'create_container_types')
  breeding_site_first, breeding_site_second = BreedingSiteType.first, BreedingSiteType.second

  ContainerType.create!(name: 'Tanques (cemento, polietileno, metal, otra) ',
                       breeding_site_type: breeding_site_first)

  ContainerType.create!(name: 'Bidones/Cilindros (metal, plástico)',
                       breeding_site_type: breeding_site_first)

  ContainerType.create!(name: 'Pozos',
                       breeding_site_type: breeding_site_first)

  ContainerType.create!(name: 'Estructura o Partes de la Casa',
                       breeding_site_type: breeding_site_first)

  ContainerType.create!(name: 'Llanta',
                       breeding_site_type: breeding_site_second)

  ContainerType.create!(name: 'Otros',
                       breeding_site_type: breeding_site_second)

  ContainerType.create!(name: 'Elementos naturales',
                       breeding_site_type: breeding_site_second)

  SeedTask.create!(task_name: 'create_container_types')
end

# assign images to container types
unless SeedTask.find_by(task_name: 'assign_images_to_container_types')
  images = get_all_images_for_containers
  ContainerType.all.zip(images).each do |container, image_hash|
    container.photo.attach(image_hash)
    image_hash[:io].unlink
  end
  SeedTask.create!(task_name: 'assign_images_to_container_types')
end

#create elimination methods
unless SeedTask.find_by(task_name: 'create_method_elimination')
  EliminationMethodType.create!([{ name: 'Quimico' }, { name: 'Tapa' }])
  SeedTask.create!(task_name: 'create_method_elimination')
end

#create water sources types
unless SeedTask.find_by(task_name: 'create_water_sources_types')
  WaterSourceType.create!([{ name: 'Naturaleza' }, { name: 'Residente' }])
  SeedTask.create!(task_name: 'create_water_sources_types')
end

#create house-places
unless SeedTask.find_by(task_name: 'create_places')
  Place.create!([{ name: 'Cementerio' }, { name: 'Plaza' }])
  SeedTask.create!(task_name: 'create_places')
end

#create default versions params
unless SeedTask.find_by(task_name: 'create_visit_params')
  data = Constants::VisitParams::RESOURCES
  data.each { |value_params| VisitParamVersion.find_or_create_by(name: value_params) }
  SeedTask.create!(task_name: 'create_visit_params')
end

#create questions
unless SeedTask.find_by(task_name: 'create_questions')

  images = get_images_for_questionnaire

  questionnaire = Questionnaire.create!(
    name: 'Cuestionario de Zancudos',
    current_form: true,
    initial_question: 8,
    final_question: 7
  )

  QUESTIONS_DATA.each do |question_data|
    options_data = question_data.delete(:options)
    question = questionnaire.questions.create!(question_data)

    options_data&.each do |option_data|
      question.options.create!(option_data)
    end
  end

  images.each do |image|
    resource = Question.find_by(question: image[:filename])
    resource ||= Option.find_by(name: image[:filename])
    next unless resource

    resource.image.attach(image)
    image[:io].unlink
  end


  SeedTask.create!(task_name: 'create_questions')

end


unless SeedTask.find_by(task_name: 'permissions_for_change_brigade')
  roles = Role.where(name: %w[admin brigadista])
  permission = Permission.create(name: 'change_team', resource: 'users')
  roles.each{|rol| rol.permissions << permission}
  SeedTask.create(task_name: 'permissions_for_change_brigade')
end

unless SeedTask.find_by(task_name: 'permissions_for_posts_likes_and_comments')
  roles = Role.all
  actions = %i[create index show update destroy like]
  resources = %i[posts comments]
  permissions = []

  resources.product(actions).each do |resource, action|
    permissions << Permission.create(name: action, resource:)
  end

  roles.each{|rol| rol.permissions << permission}
  SeedTask.create(task_name: 'permissions_for_posts_likes_and_comments')
end
