# frozen_string_literal: true
require 'json'

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
  resources.product(actions).each{| resource, action| Permission.create(name: action, resource: resource) }
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

  SeedTask.create(task_name: 'permissions')

end

#assign roles to users
unless SeedTask.find_by(task_name: 'assign_roles')
  user_account = UserAccount.find_by(username: 'tariki_admin')
  user_account.roles << Role.find_by(name: 'admin')
  user_account.save!
  SeedTask.create(task_name: 'assign_roles') if Permission.count == 63

end
