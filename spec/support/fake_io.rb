# frozen_string_literal: true

require 'forwardable'
require 'stringio'

class FakeIO
  attr_reader :original_filename, :content_type, :size

  def initialize(content, filename: nil, content_type: nil, size: nil)
    @io = StringIO.new(content)
    @original_filename = filename
    @content_type = content_type
    @size = size
  end

  extend Forwardable
  delegate %i[read rewind eof? close] => :@io
end
