# frozen_string_literal: true

require 'dry/transaction'

class ApplicationOperation
  include Dry::Transaction

  def self.call(*)
    new.call(*)
  end

  def to_snake_case(params_to_convert = params)
    Api::V1::Lib::Serializers::NamingConvention.new(params_to_convert, :to_snake_case).res
  end
end
