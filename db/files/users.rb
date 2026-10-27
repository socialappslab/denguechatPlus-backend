# frozen_string_literal: true

USERS = {
  brigadista: Constants::Role::BRIGADIST,
  team_leader: Constants::Role::FACILITATOR,
  admin: Constants::Role::ADMIN
}.freeze

def create_default_users
  USERS.each do |user, role_name|
    begin
      user_profile = UserProfile.create(first_name: FFaker::NameES.first_name,
                                        last_name: FFaker::NameES.last_name,
                                        city_id: City.last.id,
                                        neighborhood_id: Neighborhood.last.id,
                                        organization_id: Organization.last.id)

      account = user_profile.create_user_account(username: user,
                                                 status: 'active',
                                                 phone: FFaker::Number.number(digits: 8),
                                                 password: ENV.fetch("#{user.upcase}_PASSWORD", nil))

      account.roles << Role.where(name: role_name)
      account.teams << Team.find_by(id: Team.pluck(:id).sample)
    rescue StandardError => error
      Rails.logger.debug { "error: #{error.message}" }
    end
  end
end
