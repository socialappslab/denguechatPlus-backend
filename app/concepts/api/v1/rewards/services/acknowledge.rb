# frozen_string_literal: true

module Api
  module V1
    module Rewards
      module Services
        class Acknowledge
          def self.call(user_account:, ids:)
            # Explicit IDs plus the earner association preserve concurrent and other accounts' notifications.
            user_account.user_rewards.where(id: ids, seen_at: nil).update_all(seen_at: Time.current)
          end
        end
      end
    end
  end
end
