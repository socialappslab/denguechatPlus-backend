# DenguechatPlus-backend
DengueChatPlus-Backend is a Ruby and Ruby on Rails application responsible for all backend-related matters

## Requirements
- Rbenv with ruby 3.1.2
  - [Tutorial install on mac](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-macos)
  - [Tutorial install linux](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-20-04)
  - [Tutorial install windows](https://github.com/ccmywish/rbenv-for-windows)
- Redis 7.2.4
  - [Tutorial install on mac](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-mac-os/)
  - [Tutorial install linux](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/)
  - [Tutorial install windows](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-windows/)
- Postgresql 15.3
    - [Tutorial install on mac](https://www.devart.com/dbforge/postgresql/how-to-install-postgresql-on-macos/)
    - [Tutorial install linux](https://utho.com/docs/linux/how-to-install-postgresql-15-on-ubuntu-22-04/)
    - [Tutorial install windows](https://www.guru99.com/download-install-postgresql.html)
- Mailcatcher
  - [Tutorial install on mac](https://formulae.brew.sh/formula/mailcatcher)
  - [Tutorial install linux](https://blog.eldernode.com/install-mailcatcher-on-ubuntu-20-04/)
  - [Tutorial install windows](https://ipv6.rs/tutorial/Windows_10/MailCatcher/)

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
 - `rbenv install 3.1.2`
 - `bundle install`
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
