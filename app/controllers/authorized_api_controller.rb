# frozen_string_literal: true

require 'dry/transaction'

class AuthorizedApiController < ApiController
  include Dry::Transaction

  before_action :authorize_access_request!
  before_action :check_permissions!

  def self.call(*)
    new.call(*)
  end

  protected

  def do_full_public_endpoint!
    request.headers['X-Authorization'] = nil
  end
end
