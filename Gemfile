source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'mongo_mapper'
gem 'bson_ext'

# Add in ElasticSearch
# Add in PuppetDB if it ever becomes a gem

# Hiera is the target.  So we include it.
gem 'hiera'
gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-rails'
  # And what is jquery without a bunch of pre-canned stuff?
  gem 'jquery-tokeninput-rails'
  
  gem 'd3_rails', "~> 3.2.7"   # Pretty Graphs!  Yay!
  
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber'
  gem 'shoulda-matchers', '~> 2.0.0'
end