# frozen_string_literal: true

class ApiController < ApplicationController
  include Endpoint
  include Authentication
  include HttpAuthConcern
  include Deserializer
end
