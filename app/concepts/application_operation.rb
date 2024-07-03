# frozen_string_literal: true

require 'dry/transaction'

class ApplicationOperation
  include Dry::Transaction

  def self.call(*args)
    new.call(*args)
  end

  def add_errors(errors, field, msg, meta, path)
    errors.add( Api::V1::Lib::Errors::CustomError.new(field, msg, meta, path))
  end
end
