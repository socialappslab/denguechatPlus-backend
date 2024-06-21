# DenguechatPlus-backend
DengueChatPlus-Backend is a Ruby and Ruby on Rails application responsible for all backend-related matters

## How this project is organized
- **app/controllers:** This directory contains the application controllers. Controllers are responsible for handling incoming requests to the application and usually interact with models and views to send a response back to the client.  
- **app/views:** This directory contains the application's views, which are responsible for generating the interface displayed to the user. The views are mostly HTML files with some embedded Ruby for data presentation.  
- **app/helpers:** Helpers are modules that contain functions you can use globally in views and sometimes in controllers. They are useful for keeping the code DRY.  
- **app/assets:** This directory contains assets such as CSS stylesheets, JavaScript scripts, and images used in the application.  
- **app/mailers:** Mailers are objects similar to controllers that allow sending emails to users. Each mailer can have multiple actions, each corresponding to a specific email.  
- **app/jobs:** Here you will find tasks and/or processes that run in the background.  
- **app/channels:** Here you will find tasks and/or processes that run in real-time using WebSockets.  
- **app/concepts:** This directory contains a folder for each concept (usually, each main model) of the application. A concept is a functionality of the application.  
  - **lib:** This directory contains shared libraries and modules.  
  - **operation:** Encapsulate the business logic and processes of the application.  
  - **contract:** Define validations and schemas for the data. Contracts ensure the data is correct before proceeding to the business logic. They use Reform to define and validate forms more explicitly and modularly.  
  - **serializers:** Used to define serializers responsible for transforming Ruby objects into specific formats, such as JSON or XML, that can be sent to a client through the API.  
- **config:** This directory contains files for the configuration of the application, routing, databases, among others.  
- **db:** Here we find the current schema and database migrations.  
- **lib:** This directory contains rake tasks and extended libraries.  
- **log:** Contains log files. Rails creates a log file for each environment.  
- **public:** Here static and compiled files are stored that can be served directly by the web server.  
- **spec:** This directory contains automated tests for the application.  
- **tmp:** This directory contains temporary files for the application's runtime environment, such as sessions, file cache, server PID, etc.  
- **vendor:** This is a place for third-party code. In Rails, this includes gems installed with => vendor/gem_name specified in the Gemfile.  

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
- Cmake
  - MacOs: Run in your terminal `brew install cmake `
  - Windows: [Download and install CMAKE](https://cmake.org/download/)
  - Linux: [Install CMAKE on Linux](https://vpsie.com/knowledge-base/how-to-install-cmake-on-ubuntu-20-04/)

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
