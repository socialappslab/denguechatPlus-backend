# AGENTS.md

## Commands
- **Test all:** `bundle exec rspec`
- **Test single file:** `bundle exec rspec spec/path/to/file_spec.rb`
- **Test single example:** `bundle exec rspec spec/path/to/file_spec.rb:line_number`
- **Lint:** `rubocop --fail-level C --display-only-fail-level-offenses -P`
- **Run all linters:** `lefthook run linters`
- **Start server:** `bundle exec rails s`
- **Database setup:** `bundle exec rails db:create db:migrate db:seed`

## Architecture
- **Ruby on Rails 7.1.3** API-only backend with PostgreSQL, Redis, Sidekiq
- **Concept-driven organization:** Each major feature in `app/concepts/` with lib/, operation/, contract/, serializers/
- **Auth:** JWT with action_policy for authorization, rolify for roles
- **Background jobs:** Sidekiq with scheduler, Redis for caching
- **External APIs:** HTTParty for external calls, Twilio for SMS

## Code Style
- **Line length:** 120 chars max
- **Naming:** snake_case variables, prefer 'error' for rescued exceptions
- **Testing:** RSpec with FactoryBot, use `describe`, `context`, `it` structure
- **Frozen strings:** All files start with `# frozen_string_literal: true`
- **Imports:** Group gems logically in Gemfile, require statements at top
- **Error handling:** Use dry-monads for result objects, prefer explicit error handling
