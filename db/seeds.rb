# db/seeds.rb
# This file contains all the record creation needed to seed the database with default values.
# The data can then be loaded with the bin/rails db:seed command or created alongside the database with db:setup.
require_relative '../db/files/permissions'


puts 'Cleaning database...'
RolePermission.destroy_all
Permission.destroy_all
Role.destroy_all
UserAccount.destroy_all
UserProfile.destroy_all
Team.destroy_all
Neighborhood.destroy_all
City.destroy_all
Organization.destroy_all

puts 'Creating organizations...'
Organization.create!(
  id: 1,
  name: 'Tariki'
)

country = Country.create!(name: 'Peru')


state = State.create!(name: 'Loreto', country_id: 1)

city = City.create!(name: 'Iquitos', country_id: 1, state_id: 1)



puts 'Creating neighborhoods...'
neighborhoods = [
  { name: 'Sector 4 (Maynas)', city_id: 1, state_id: state.id, country_id: country.id },
  { name: 'Sector 16 (Tupac Amaru)', city_id: 1, state_id: state.id, country_id: country.id }
]

neighborhoods.each do |neighborhood_data|
  Neighborhood.create!(neighborhood_data)
end

wedges = [
  { name: 'Cuña 1', external_id: 1, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 2', external_id: 2, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 3', external_id: 3, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 11', external_id: 11, source: 'GIS', neighborhood_ids: [2] },
  { name: 'Cuña 12', external_id: 12, source: 'GIS', neighborhood_ids: [2] },
  { name: 'Cuña 13', external_id: 13, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 14', external_id: 14, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 15', external_id: 15, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 16', external_id: 16, source: 'GIS', neighborhood_ids: [2] },
  { name: 'Cuña 4', external_id: 4, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 5', external_id: 5, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 6', external_id: 6, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 7', external_id: 7, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 8', external_id: 8, source: 'GIS', neighborhood_ids: [1] },
  { name: 'Cuña 9', external_id: 9, source: 'GIS', neighborhood_ids: [2] },
  { name: 'Cuña 10', external_id: 10, source: 'GIS', neighborhood_ids: [2] }
]

wedges.each do |wedge_data|
  Wedge.create!(wedge_data)
end

puts 'Creating teams...'
teams = [
  { name: 'Brigadada 1', organization_id: 1, neighborhood_id: 1, wedge_id: 1 },
  { name: 'DengueKillers', organization_id: 1, neighborhood_id:  1, wedge_id: 1 },
  { name: 'Iquitos Team', organization_id: 1, neighborhood_id: 1, wedge_id: 1 },
]

teams.each do |team_data|
  Team.create!(team_data)
end

puts 'Creatings permissions and roles'

ACTION_AND_RESOURCES.each do |permission_attrs|
  permission = Permission.find_or_initialize_by(
    name: permission_attrs[:name],
    resource: permission_attrs[:resource]
  )

  if permission.new_record?
    permission.save!
    puts "Created permission: #{permission_attrs[:name]} - #{permission_attrs[:resource]}"
  end
end

ROLES_PERMISSIONS[:roles].each do |role_data|
  role = Role.find_or_initialize_by(name: role_data[:name])

  if role.new_record?
    role.save!
    puts "Created role: #{role_data[:name]}"
  end

  role_data[:permissions].each do |permission_attrs|
    permission = Permission.find_by(
      name: permission_attrs[:name],
      resource: permission_attrs[:resource]
    )

    if permission
      unless RolePermission.exists?(role: role, permission: permission)
        RolePermission.create!(role: role, permission: permission)
        puts "Assigned permission #{permission_attrs[:name]} - #{permission_attrs[:resource]} to role #{role.name}"
      end
    else
      puts "Warning: Permission #{permission_attrs[:name]} - #{permission_attrs[:resource]} not found"
    end
  end
end

puts 'Permissions and roles update completed!'


puts 'Creating user profiles...'
user_profiles_data = [
  { first_name: 'Tomas', last_name: 'Heredia', email: 'briga@gmail.com', city_id: 1, neighborhood_id: 1,
    organization_id: 1, team_id: 1, gender: nil, language: 'es'},
  { first_name: 'María', last_name: 'Trujillo', email: nil, city_id: 1, neighborhood_id: 1, organization_id: 1,
    team_id: 1, gender: nil, language: 'es' },
  { first_name: 'Francisco', last_name: 'Pardo', email: nil, city_id: 1, neighborhood_id: 1, organization_id: 1,
    team_id: 1, gender: nil, language: 'es' },
]

user_profiles_data.each do |profile_data|
  UserProfile.create!(profile_data)
end

puts 'Creating user accounts...'
user_accounts_data = [
  {  user_profile_id: 1, phone: "'+63138546", username: 'brigadista', status: 1, failed_attempts: 0, role_ids: [1], password: 'test2024#1' },
  {  user_profile_id: 2, phone: "'+51918135", username: 'team_leader', status: 1, failed_attempts: 0, role_ids: [2], password: 'test2024#2' },
  { user_profile_id: 3, phone: "'+88035918", username: 'admin', status: 1, failed_attempts: 0, role_ids: [3], password: 'test2024#3' },

]

user_accounts_data.each do |account_data|
  UserAccount.create!(account_data)
end

puts 'Seeds completed successfully!'


puts "Creating house blocks"
house_blocks_data = [
  { name: "9 de julio", external_id: nil, source: "GIS", wedge_ids: [27] },
  { name: "Psj. Bambamarca", external_id: nil, source: "GIS", wedge_ids: [22] },
  { name: "Jose Olaya, Tahuantisuyo", external_id: nil, source: "GIS", wedge_ids: [23] },
  { name: "Cabo Pantoja (Cuna 5)", external_id: nil, source: "GIS", wedge_ids: [18] },
  { name: "Palestina, Tahuantisuyo, Jose Olaya", external_id: nil, source: "GIS", wedge_ids: [25] },
  { name: "Diego de Almagro, Psj. Diego de Almagro (Cuna 8)", external_id: nil, source: "GIS", wedge_ids: [21] },
  { name: "Tupac Amaru (Cuna 2)", external_id: nil, source: "GIS", wedge_ids: [14] },
  { name: "Diego de Almagro", external_id: nil, source: "GIS", wedge_ids: [17] },
  { name: "Diego de Almagro, Piura (Cuna 8)", external_id: nil, source: "GIS", wedge_ids: [21] },
  { name: "Borja, Misti (Cuna 7)", external_id: nil, source: "GIS", wedge_ids: [20] },
  { name: "Trujillo, Piura (Cuna 8)", external_id: nil, source: "GIS", wedge_ids: [21] },
  { name: "Urarinas, Secoya", external_id: nil, source: "GIS", wedge_ids: [26] },
  { name: "Armando Fortes", external_id: nil, source: "GIS", wedge_ids: [26] },
  { name: "Trujillo, Augusto Freyre (Cuna 8)", external_id: nil, source: "GIS", wedge_ids: [21] },
  { name: "Los Proceres, Independencia (Cuna 3)", external_id: nil, source: "GIS", wedge_ids: [15] },
  { name: "Cuzco, 28 de Julio (Cuna 6)", external_id: nil, source: "GIS", wedge_ids: [19] },
  { name: "Cabo Pantoja, 28 de Julio (Cuna 5)", external_id: nil, source: "GIS", wedge_ids: [18] },
  { name: "9 de julio (Cuna 14)", external_id: nil, source: "GIS", wedge_ids: [27] },
  { name: "Urb. Sarita Colonia (sur)", external_id: nil, source: "GIS", wedge_ids: [29] },
  { name: "Independencia, Manco Capac (Cuna 3)", external_id: nil, source: "GIS", wedge_ids: [15] },
  { name: "Bertha Nunes, Santos Atahualpa, Micaela Bastidas", external_id: nil, source: "GIS", wedge_ids: [29] },
  { name: "Los Libertadores", external_id: nil, source: "GIS", wedge_ids: [27] },
  { name: "Benavides, Augusto Freyre (Cuna 6)", external_id: nil, source: "GIS", wedge_ids: [19] },
  { name: nil, external_id: nil, source: "GIS", wedge_ids: [21] },
  { name: "Huanuco, 28 de julio (Cuna 5)", external_id: nil, source: "GIS", wedge_ids: [18] },
  { name: "Panama, Iquitos (Cuna 3)", external_id: nil, source: "GIS", wedge_ids: [15] },
  { name: "Trujillo (Cuna 2)", external_id: nil, source: "GIS", wedge_ids: [14] },
  { name: "Inca Roca (Cuna 11)", external_id: nil, source: "GIS", wedge_ids: [24] },
  { name: "Panama, Huanuco (Cuna 5)", external_id: nil, source: "GIS", wedge_ids: [18] }
]


house_blocks_data.each do |house_block|
  HouseBlock.create!(house_block)
end
