source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1", ">= 7.2.1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Redis adapter to run sidekiq
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Managing test data creation [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails", "~> 6.2"

  # library for generating fake data [https://github.com/faker-ruby/faker]
  gem "faker", "~> 3.4", ">= 3.4.2"

  # ENV variable manager [https://github.com/bkeepers/dotenv]
  gem "dotenv", "~> 3.1", ">= 3.1.4"

  # Test framework [https://github.com/rspec]
  gem "rspec", "~> 3.4"
  gem "rspec-rails", "~> 7.0", ">= 7.0.1"
end

group :test do
  gem "database_cleaner-mongoid", "~> 2.0", ">= 2.0.1"

  # Provides a collection of RSpec-compatible matchers that help to test Mongoid documents [https://github.com/mongoid/mongoid-rspec]
  gem "mongoid-rspec"

  # Simple testing of Sidekiq jobs via a collection of matchers and helpers [https://github.com/wspurgin/rspec-sidekiq]
  gem "rspec-sidekiq", "~> 3.1"

  # Addon for displaying CodeLens for RSpec tests
  gem "ruby-lsp-rspec", require: false

  # Provides time travel and freezing capabilities [https://github.com/travisjeffery/timecop]
  gem "timecop", "~> 0.8.0"
end

# Use MongoDB for the database, with Mongoid as the ODM
gem "mongoid", "9.0.2"

# The Rails CLI tool for MongoDB
gem "railsmdb", "1.0.0.alpha3"

# For background job processing [https://github.com/sidekiq/sidekiq]
gem "sidekiq", "~> 7.1", ">= 7.1.2"

# A library that simplifies making HTTP requests
gem "httparty", "~> 0.22.0"
