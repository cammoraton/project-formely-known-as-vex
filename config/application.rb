require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Vex
  class Application < Rails::Application
    config.encoding = "utf-8"
    
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    
    # Load everything in subfolders in models w/o namespacing
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.threadsafe!
    
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.generators do |g|
      g.orm :mongo_mapper
    end
    
    # Development/test default to :debug, we can set it to info to get a better idea of performance metrics.
    # config.log_level = :info
    
    # Define what our ultimate dependency resolution target is
    config.dependency_resolution_target = "Node"
  end
end
