# frozen_string_literal: true

module Constants
  module Role
    ADMIN = 'admin'
    BRIGADIST = 'brigadista'
    TEAM_LEADER = 'team_leader'
    BACKOFFICE = 'backoffice'

    ALLOWED_NAMES = [
      ADMIN,
      BRIGADIST,
      BACKOFFICE,
      TEAM_LEADER
    ].freeze
  end
end
