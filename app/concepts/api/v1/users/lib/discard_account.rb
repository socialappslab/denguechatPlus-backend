# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class DiscardAccount
          def self.call(user_account:)
            new(user_account:).call
          end

          def initialize(user_account:)
            @user_account = user_account
          end

          def call
            return if user_account.discarded?

            # rubocop:disable Rails/SkipsModelValidations -- anonymize deleted account without triggering validations
            user_account.update_columns(phone: "deleted_#{user_account.id}",
                                        username: "deleted_#{user_account.id}")
            # rubocop:enable Rails/SkipsModelValidations
            anonymize_profile
            remove_user_content
            user_account.discard!
          end

          private

          attr_reader :user_account

          def anonymize_profile
            user_profile = user_account.user_profile
            return unless user_profile

            # rubocop:disable Rails/SkipsModelValidations -- anonymize deleted profile without triggering validations
            user_profile.update_columns(first_name: "user_deleted_#{user_account.id}",
                                        last_name: "user_deleted_#{user_account.id}",
                                        email: "deleted_#{user_account.id}@denguechatplus.com")
            # rubocop:enable Rails/SkipsModelValidations
            user_profile.update(team_id: nil)
          end

          def remove_user_content
            Comment.where(user_account_id: user_account.id).destroy_all
            Post.where(user_account_id: user_account.id).destroy_all
          end
        end
      end
    end
  end
end
