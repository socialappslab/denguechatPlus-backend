# frozen_string_literal: true

require 'dry/transaction'

class AuthorizedApiController < ApiController
  include Dry::Transaction

  before_action :authorize_access_request!
  before_action :check_permissions!

  def self.call(*args)
    new.call(*args)
  end
end
