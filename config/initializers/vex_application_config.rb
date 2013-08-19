ENV['VEX_CONFIGFILE'] ||= "#{Rails.root}/config/vex.cfg"

app_config = Vex::ApplicationConfig.new(ENV["VEX_CONFIGFILE"])
app_config.load