# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Operations
          class Destroy < ApplicationOperation
            step :flush_session

            def flush_session(_ctx, flush_session:, found_token:, current_user:, **)
              return unless current_user

              flush_session.call(found_token, current_user)
            end
          end
        end
      end
    end
  end
end
