# frozen_string_literal: true

require 'dry/transaction'

class ApplicationOperation
  include Dry::Transaction

  def self.call(*args)
    new.call(*args)
  end
end
