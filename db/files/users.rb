# frozen_string_literal: true

USERS = %i[brigadista team_leader admin].freeze

def create_default_users
  USERS.each do |user|
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

      account.roles << Role.where(name: user)
      account.teams << Team.find_by(id: Team.pluck(:id).sample)
    rescue StandardError => error
      Rails.logger.debug { "error: #{error.message}" }
    end
  end
end
