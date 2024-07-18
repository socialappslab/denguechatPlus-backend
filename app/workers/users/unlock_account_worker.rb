# app/workers/lock_account_worker.rb

module Users
  class UnlockAccountWorker
    include Sidekiq::Worker

    def perform(user_id)
      user = UserAccount.find_by(id: user_id)
      Api::V1::Users::Lib::LoginAttempt.call(user).reset_attempts_count!
    end
  end

end
