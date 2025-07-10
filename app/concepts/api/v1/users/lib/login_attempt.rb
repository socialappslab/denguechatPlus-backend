# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class LoginAttempt
          def initialize(user)
            @user = user
          end

          def self.call(user)
            new(user)
          end

          def increase_attempts_count!
            @user.increment!(:failed_attempts)
            lock_account! if @user.failed_attempts >= Configuration.attempts_number
          end

          def lock_account!
            @user.update(status: 'locked')
            ::Users::UnlockAccountWorker.perform_in(Configuration.time_locked.minutes, @user.id)
          end

          def reset_attempts_count!
            @user.update(failed_attempts: 0, status: 'active')
          end
        end
      end
    end
  end
end
