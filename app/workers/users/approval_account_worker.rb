# app/workers/lock_account_worker.rb

module Users
  class ApprovalAccountWorker
    include Sidekiq::Worker

    def perform(user_id)
      user = UserAccount.find_by(id: user_id)
      return unless user.present? && user.active?

      ::Twillio::UserMessage.send_approval_message(user.normalized_phone, user&.username)
    end
  end
end
