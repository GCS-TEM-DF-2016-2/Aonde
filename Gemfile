source 'https://rubygems.org'

# Code coverage from CodeClimate
gem "codeclimate-test-reporter", group: :test, require: nil

gem "factory_girl"

# Internationalization and localization
gem 'rails-i18n'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '~> 0.3.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
gem 'execjs'

#Gem for materialize
gem 'materialize-sass'

# Tests with cucumber
gem 'capybara', '2.4.4'
gem 'cucumber'	

group :test do
gem "factory_girl_rails"
	gem 'database_cleaner'
    gem 'cucumber-rails', require: false
end

#Gem for test the connection with fake page web
gem "fakeweb", "~> 1.3"
#Gem to create a DSN
gem 'rest-client'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Gem to create the table style 1: data table with jQuery
#gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  
  # Capistrano to automatize deploy
  gem 'capistrano-rails', '~> 1.1'
end

