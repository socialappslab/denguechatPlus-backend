# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Operations
          class RefreshToken < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_params
            step :create_tokens

            def params(params)
              @ctx ||= {}
              @ctx[:found_token] = params[:found_token] || nil
              @ctx[:payload] = params[:payload] || nil
            end

            def validate_params
              return Success({ ctx: @ctx, type: :success }) if @ctx[:found_token] && @ctx[:payload]

              Failure({ ctx: @ctx, type: :invalid })
            end

            def create_tokens
              result = Api::V1::Users::Lib::RefreshToken.call(payload: @ctx[:payload], found_token: @ctx[:found_token])

              if result
                @ctx[:meta] = { jwt: Api::V1::Lib::Serializers::NamingConvention.new(result, :to_camel_case) }
                Success({ ctx: @ctx, type: :created })
              else
                add_errors(@ctx['contract.default'].errors,nil, I18n.t('errors.session.deactivated'))
                Failure({ ctx: @ctx, type: :unauthenticated })
              end
            end
          end
        end
      end
    end
  end
end
