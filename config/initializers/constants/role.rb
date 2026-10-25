# frozen_string_literal: true

module Constants
  module Role
    ADMIN = 'admin'
    FACILITATOR = 'facilitador'
    BRIGADIST = 'brigadista'
    BACKOFFICE = 'backoffice'

    ALLOWED_NAMES = [
      ADMIN,
      BRIGADIST,
      BACKOFFICE,
      FACILITATOR
    ].freeze

    # Highest first. Each role holds every permission of the roles below it.
    HIERARCHY = [ADMIN, FACILITATOR, BRIGADIST].freeze

    def self.rank(name)
      HIERARCHY.index(name) || HIERARCHY.size
    end

    def self.at_least(name)
      HIERARCHY.first(rank(name) + 1)
    end
  end
end
