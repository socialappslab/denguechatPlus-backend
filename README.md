# DenguechatPlus-backend
DengueChatPlus-Backend is a Ruby and Ruby on Rails application responsible for all backend-related matters

## Requirements
- Rbenv with ruby 3.1.2
- Redis 7.2.4
- Postgresql 15.3
- Mailcatcher

## Using this project
Create a file called 'local_env.yml' in config/ folder. This file should contain the following data:
- **DATABASE_HOST:** your_database_host
- **DATABASE_USERNAME:** your_database_user
- **DATABASE_PASSWORD:** your database_password
- **DATABASE_NAME:** your database_name
- **JWT_SECRET_KEY:** your jwt_secret_key
- **REDIS_URL:** your redis_url
- **CLIENT_URL:** your client_url
- **PASSWORD_USER_DEFAULT:** your default_user_password

After that, run these commands in the terminal:
 - `bundle exec rails db:create`
 - `bundle exec rails db:migrate`
 - `bundle exec rails db:seed`

To run this project execute this in the terminal
- `bundle exec rails s`
 if you need test the mailer feature use mailcatcher writing this in the terminal
- `mailcatcher`

## Testing

If you need to check the project's health, run this in the terminal
- `rubocop --fail-level C --display-only-fail-level-offenses -P`
- `reek`
- `bundle-audit check --update`
- `bundle leak update && bundle leak`
- `fasterer`
- `rails_best_practices -e "app/views,app/mailers,app/controllers/concerns/endpoint.rb,app/models/" -c rails_best_practices.yml`
- `database_consistency`
