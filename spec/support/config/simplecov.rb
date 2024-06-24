# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
)

SimpleCov.minimum_coverage(100)
SimpleCov.start('rails') { add_filter(%r{^/spec/}) } if ARGV.grep(/spec.\w+/).empty?

require 'undercover'
