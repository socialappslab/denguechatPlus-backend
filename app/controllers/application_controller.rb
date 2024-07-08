# frozen_string_literal: true

class ApplicationController < ActionController::API

  rescue_from ActionDispatch::Http::Parameters::ParseError do |e|
    render json: { error: 'Invalid request', code: 1000 }, status: :bad_request
  end
end
