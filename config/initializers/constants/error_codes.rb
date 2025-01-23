# frozen_string_literal: true

module Constants
  module ErrorCodes
    CODE = {
      min_size?: 1,
      filled?: 2,
      bool?: 3,
      date?: 4,
      date_time?: 5,
      time?: 6,
      number?: 7,
      int?: 8,
      float?: 9,
      decimal?: 10,
      str?: 11,
      hash?: 12,
      array?: 13,
      odd?: 14,
      even?: 15,
      lt?: 16,
      gt?: 17,
      lteq?: 18,
      gteq?: 19,
      size?: 20,
      _min_size?: 21,
      max_size?: 22,
      bytesize?: 23,
      min_bytesize?: 24,
      max_bytesize?: 25,
      inclusion?: 26,
      exclusion?: 27,
      included_in?: 28,
      excluded_from?: 29,
      includes?: 30,
      excludes?: 31,
      eql?: 32,
      is?: 33,
      not_eql?: 34,
      true?: 35,
      false?: 36,
      format?: 37,
      case?: 38,
      uuid_v1?: 39,
      uuid_v2?: 40,
      uuid_v3?: 41,
      uuid_v4?: 42,
      uuid_v5?: 43,
      uri?: 44,
      uri_rfc3986?: 45,
      credentials_wrong?: 46,
      key?: 47,
      user_username_unique?: 48,
      user_phone_unique?: 49,
      user_email_unique?: 50,
      user_account_without_confirmation?: 51,
      unique?: 52,
      not_exists?: 53,
      not_found?: 54,
      user_account_locked?: 55,
      unexpected_key: 56,
      without_permissions: 57,
      users_change_team: 58,
      reports_brigadists_performance: 59,
      code_recovery_in_a_short_time: 60,
      houses_orphan_houses: 61,
      house_already_assigned: 62,
      inspections_index: 63

    }.freeze
  end
end
