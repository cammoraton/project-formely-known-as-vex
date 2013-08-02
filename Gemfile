source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'mongo_mapper'
gem 'bson_ext'

# Add in ElasticSearch

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
  gem 'jquery-ui-rails'
  gem 'jquery-ui-sass-rails'
  
  # Really only needed to suck in a jquery-ui theme(because we're lazy - constructively lazy, but lazy).  
  # If included normally it'll suck in all of the jquery-ui themes and really good and bloat the assets directory
  # Uncomment, bundle then run the rake jquery_ui_themes:import:themeroller[path] task, as in:
  #  f rake jquery_ui_themes:import:themeroller[~/Downloads/jquery-ui-1.10.3.custom/css/vex-custom/jquery-ui-1.10.3.custom.css,vex]
  #gem 'jquery-ui-themes'

  gem 'd3_rails', "~> 3.2.7"   # Pretty Graphs!  Yay!
  
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber'
  gem 'shoulda-matchers', '~> 2.0.0'
end