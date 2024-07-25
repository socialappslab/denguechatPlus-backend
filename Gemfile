# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors'

# Password Strength Estimation
gem 'zxcvbn-ruby', require: 'zxcvbn'

# Decorators/View-Models for Rails Applications
gem 'draper', '~> 4.0'

# Pagination
gem 'pagy', '3.10.0'
gem 'pagy_cursor', '0.2.2'

# JSON:API Serializer
gem 'jsonapi-serializer', '~> 2.2'
gem 'alba'
gem 'jwt'
gem 'jwt_sessions'
# Role management
gem 'rolify', '~> 6.0'

# Authorization
gem 'action_policy'

# Transactions
gem 'dry-transaction'

# Soft-delete for models
gem 'discard', '~> 1.2'

gem 'sidekiq', '~> 7.1.3'

# External API's
gem 'httparty'

#Audit tables
gem 'paper_trail'

# Fulltext search
gem 'pg_search', '~> 2.3'

# ActiveRecord Bulk import
gem 'activerecord-import', '~> 1.4'

# Upload files to AWS S3
gem 'aws-sdk-s3', require: false

# dry gems
gem 'dry-monads'
gem 'dry-validation'
gem 'dry-auto_inject'
gem 'reform'
gem 'simple_endpoint', '~> 2.0'
gem 'dry-container'

group :development, :test do
  gem 'annotate'
  gem 'brakeman', '~> 5.3', require: false
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'bundler-leak', '~> 0.3', require: false
  gem 'database_consistency', '~> 1.2', require: false
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'fasterer', '~> 0.10', require: false
  gem 'ffaker'
  gem 'lefthook', '~> 1.1', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails_best_practices', require: false
  gem 'reek', '~> 6.1', require: false
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '~> 1.36.0', require: false
  gem 'rubocop-performance', '~> 1.15', require: false
  gem 'rubocop-rails', '~> 2.17', require: false
  gem 'rubocop-rspec', '~> 2.14', require: false
  gem 'shoulda-matchers', '~> 5.2'
  gem 'simplecov', '~> 0.21'
  gem 'simplecov-lcov', '~> 0.8'
  gem 'undercover', '~> 0.4'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
  gem 'spring', '~> 4.1'
  gem 'spring-watcher-listen', '~> 2.1'
end

group :test do
  gem 'dox', '~> 2.1', require: false
  gem 'email_spec', '~> 2.2'
  gem 'fuubar', '~> 2.5'
  gem 'json_matchers', '~> 0.11'
  gem 'mock_redis', '~> 0.33'
  gem 'rspec_junit_formatter', '~> 0.5'
  gem 'rspec-sidekiq', '~> 3.1'
  gem 'super_diff'
  gem 'test-prof', '~> 1.0'
  gem 'webmock', '~> 3.18'
end
