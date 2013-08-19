require 'vex'

# May as well prep it for running from an init script!
ENV['VEX_CONFIGFILE'] ||= "#{Rails.root}/config/vex.cfg"

# initialize Dynamic Models to an empty array
Vex::Application.config.dynamic_models = Array.new
Vex::Application.config.dynamic_model_base_class = Configuration

app_config = Vex::ApplicationConfig.new(ENV["VEX_CONFIGFILE"])
app_config.load