# frozen_string_literal: true
require 'json'
require 'open-uri'

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
    rescue => error
      p error
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

# default country
unless SeedTask.find_by(task_name: 'country')
  country = Country.create(name: 'Peru')
  SeedTask.create(task_name: 'country') if country.persisted?
end

# default organization
unless SeedTask.find_by(task_name: 'organization')
  organization = Organization.create(name: 'Tariki')
  SeedTask.create(task_name: 'organization') if organization.persisted?
end

# states_and_cities
unless SeedTask.find_by(task_name: 'states_and_cities')
  country = Country.first
  data = JSON.parse(Rails.root.join('db/files/states_cities.json').read)
  data.each do |state|
    state_persisted = State.create(name: state['state_name'], country:)

    #create cities
    state['cities']&.each do |city|
      city_persisted = City.create(name: city['name'], state: state_persisted, country:)


      #create neighboorhoods
      city['neighborhoods']&.each do |neighborhood|
        Neighborhood.create(name: neighborhood['name'], state: state_persisted, country:, city:city_persisted)
      end
    end
  end

  SeedTask.create(task_name: 'states_and_cities') if State.count > 24 && City.count > 482
end

# user account and user_profile
unless SeedTask.find_by(task_name: 'user_account')
  user_profile = UserProfile.create(first_name: 'John',
                                    last_name: 'Doe',
                                    gender: 1,
                                    points: 100,
                                    city_id: City.first.id,
                                    neighborhood_id: Neighborhood.first.id,
                                    organization_id: Organization.first.id,
                                    language: 'es',
                                    timezone: 'America/Asuncion')

  user_profile.create_user_account(username: 'tariki_admin',
                                   status: 'active',
                                   password: ENV.fetch('PASSWORD_USER_DEFAULT', nil),
                                   password_confirmation: ENV.fetch('PASSWORD_USER_DEFAULT', nil))
  SeedTask.create(task_name: 'user_account') if user_profile.persisted? && user_profile.user_account.persisted?

end

# teams
unless SeedTask.find_by(task_name: 'user_account')
  user_profile = UserProfile.create(first_name: 'John',
                                    last_name: 'Doe',
                                    gender: 1,
                                    points: 100,
                                    city_id: City.first.id,
                                    neighborhood_id: Neighborhood.first.id,
                                    organization_id: Organization.first.id,
                                    language: 'es',
                                    timezone: 'America/Asuncion')

  user_profile.create_user_account(username: 'tariki_admin',
                                   password: ENV.fetch('PASSWORD_USER_DEFAULT', nil),
                                   password_confirmation: ENV.fetch('PASSWORD_USER_DEFAULT', nil),
                                   confirmed_at: Time.zone.now)
  SeedTask.create(task_name: 'user_account') if user_profile.persisted? && user_profile.user_account.persisted?

end

#roles
unless SeedTask.find_by(task_name: 'roles')
  admin = Role.create(name: 'admin')
  local_facilitator = Role.create(name: 'local_facilitator')
  brigadist = Role.create(name: 'brigadista')
  if admin.persisted? && brigadist.persisted? && local_facilitator.persisted?
    SeedTask.create(task_name: 'roles')
  end
end

#permissions
unless SeedTask.find_by(task_name: 'permissions')
  actions = %w[index show new create edit update destroy]
  resources = %w[teams organizations users roles permissions countries cities states neighborhoods ]
  resources.product(actions).each { | resource, action| Permission.create(name: action, resource: resource) }
  SeedTask.create(task_name: 'permissions') if Permission.count == 63
end

#assign permissions to roles
unless SeedTask.find_by(task_name: 'assign permissions')
  admin_role = Role.find_by(name: 'admin')
  Permission.all.each do |permission|
    unless admin_role.permissions.include?(permission)
      admin_role.permissions << permission
    end
  end
  admin_role.save!

  SeedTask.create(task_name: 'assign permissions')

end

#assign roles to users
unless SeedTask.find_by(task_name: 'assign_roles')
  user_account = UserAccount.find_by(username: 'tariki_admin')
  user_account.roles << Role.find_by(name: 'admin')
  user_account.save!
  SeedTask.create(task_name: 'assign_roles') if Permission.count == 63
end

#create breeding site types
unless SeedTask.find_by(task_name: 'create_breeding_site_types')
  BreedingSiteType.create([{ name: 'permanente' }, { name: 'no permanente' }])
  SeedTask.create(task_name: 'create_breeding_site_types')
end

#create container types
unless SeedTask.find_by(task_name: 'create_container_types')
  breeding_site_first, breeding_site_second = BreedingSiteType.first, BreedingSiteType.second

  ContainerType.create(name: 'Tanques (cemento, polietileno, metal, otra) ',
                       breeding_site_type: breeding_site_first)

  ContainerType.create(name: 'Bidones/Cilindros (metal, plástico)',
                       breeding_site_type: breeding_site_first)

  ContainerType.create(name: 'Pozos',
                       breeding_site_type: breeding_site_first)

  ContainerType.create(name: 'Estructura o Partes de la Casa',
                       breeding_site_type: breeding_site_first)

  ContainerType.create(name: 'Llanta',
                       breeding_site_type: breeding_site_second)

  ContainerType.create(name: 'Otros',
                       breeding_site_type: breeding_site_second)

  ContainerType.create(name: 'Elementos naturales',
                       breeding_site_type: breeding_site_second)

  SeedTask.create(task_name: 'create_container_types')
end

# assign images to container types
unless SeedTask.find_by(task_name: 'assign_images_to_container_types')
  images = get_all_images_for_containers
  ContainerType.all.zip(images).each do |container, image_hash|
    container.photo.attach(image_hash)
    image_hash[:io].unlink
  end
  SeedTask.create(task_name: 'assign_images_to_container_types')
end

#create elimination methods
unless SeedTask.find_by(task_name: 'create_method_elimination')
  EliminationMethodType.create([{ name: 'Quimico' }, { name: 'Tapa' }])
  SeedTask.create(task_name: 'create_method_elimination')
end

#create water sources types
unless SeedTask.find_by(task_name: 'create_water_sources_types')
  WaterSourceType.create([{ name: 'Naturaleza' }, { name: 'Residente' }])
  SeedTask.create(task_name: 'create_water_sources_types')
end

#create house-places
unless SeedTask.find_by(task_name: 'create_places')
  Place.create([{ name: 'Cementerio' }, { name: 'Plaza' }])
  SeedTask.create(task_name: 'create_places')
end


#create default versions params
unless SeedTask.find_by(task_name: 'create_visit_params')
  data = Constants::VisitParams::RESOURCES
  data.each { |value_params| VisitParamVersion.find_or_create_by(name: value_params) }
  SeedTask.create(task_name: 'create_visit_params')
end
