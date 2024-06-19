# frozen_string_literal: true

module Constants
  module BasicAuth
    ENVS_TO_SKIP_AUTH = %w[
      test
      development
    ].freeze
  end
end
