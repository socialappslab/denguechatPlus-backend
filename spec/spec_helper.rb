# frozen_string_literal: true

require_relative 'support/config/simplecov'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'dry/container/stub'
require 'rspec/rails'
require 'super_diff/rspec-rails'
require 'test_prof/recipes/rspec/let_it_be'
require 'test_prof/recipes/rspec/factory_default'
require 'webmock/rspec'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

support_dir = File.join(File.dirname(__FILE__), 'support/**/*.rb')
Dir[File.expand_path(support_dir)].each do |file|
  require file unless file[/\A.+_spec\.rb\z/]
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  abort error.to_s.strip
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec_stats.txt'
  config.expect_with(:rspec) { |expectations| expectations.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.fixture_path = Rails.root.join('spec/fixtures').to_s
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Helpers
  config.include ActionDispatch::TestProcess::FixtureFile

  config.before(:each, :redis) do
    mock_redis.flushall
  end

  config.before do
    allow(Redis).to receive(:new).and_return(MockRedis.new)
  end
end
