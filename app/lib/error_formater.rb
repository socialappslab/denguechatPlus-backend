# frozen_string_literal: true

class ErrorFormater
  class << self
    def new_error(**errors)
      field = errors[:field] || :base
      msg= errors[:msg] || ''
      meta= errors[:meta] || ''
      path = errors[:path] || []
      custom_predicate = errors[:custom_predicate] || nil
      resource = errors[:resource] || nil
      Api::V1::Lib::Errors::CustomError.new(field, msg, meta, path, custom_predicate, resource).to_array
    end
  end
end
