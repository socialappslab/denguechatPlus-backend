# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class ReportFailuresOnLogin
          def self.call(params:, error_phase:)
            Sentry.with_scope do |scope|
              scope.set_tag(:env, 'login_issue')
              scope.set_tag(:error_phase, error_phase)
              scope.set_tag(:user_name, params['username'])
              scope.set_tag(:phone, params['phone'])
              scope.set_tag(:login_type, params['type'])
              scope.set_context(
                'login_issue_data',
                {
                  user_name: params['username'],
                  phone: params['phone'],
                  login_type: params['type'],
                  error_phase: params['error_phase']
                }
              )

              Sentry.capture_message('login_issue')
            end
          end
        end
      end
    end
  end
end
