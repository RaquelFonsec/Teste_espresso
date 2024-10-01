source "https://rubygems.org"

ruby "3.1.2"

# Use Rails 7.1.4
gem "rails", "~> 7.1.4"

# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sidekiq for background jobs in production
group :production do
  gem 'sidekiq'
end

# Development and test gems
group :development, :test do
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'database_cleaner'
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
  gem 'redis'
  
  # Choose one or two HTTP libraries
  gem 'http'
  gem 'httparty'
   gem 'rest-client'
end

# Development-only gems
group :development do
  # Uncomment if needed
   gem "spring"
   gem "rack-cors"
end
