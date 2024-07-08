# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Operations
          class Destroy < ApplicationOperation
            include Dry::Transaction
            include Inject[
                      flush_session_by_token: 'sessions.flush_session_by_token'
                    ]
            tee :params
            step :flush_session

            def params(input)
              @ctx = {}
              @current_user = input[:current_user]
              @found_token = input[:found_token]
            end

            def flush_session
              return Failure({ ctx: @ctx, type: :gone }) unless @current_user && @found_token

              result = flush_session_by_token.call(@found_token, @current_user)
              if result&.positive?
                Success({ ctx: @ctx, type: :destroyed })
              else
                Failure({ ctx: @ctx, type: :gone })
              end
            end
          end
        end
      end
    end
  end
end
