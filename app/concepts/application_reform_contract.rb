# frozen_string_literal: true

require 'reform/form/dry'
require 'reform/form/coercion'

class ApplicationReformContract < Reform::Form
  include Reform::Form::Dry
  feature Reform::Form::Dry
  feature Reform::Form::Coercion

  def merge!(errors)
    errors.each do |error|
      field = error.first
      messages = error.last
      if messages.size > 1
        messages.each { |message| self.errors.add(field, [message]) }
      else
        self.errors.add(field, messages)
      end
    end
  end
end
