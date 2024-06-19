# frozen_string_literal: true

class ApiController < ApplicationController
  include Endpoint
  include Authentication
  include HttpAuthConcern

  private

  def check_user_activity
    return unless current_user

    # Api::V1::Lib::Services::Users::HandleActivity.call(current_user:)
    true || head(:unauthorized)
  end
end
