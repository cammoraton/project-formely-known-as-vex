# Assume the file name matches the model name matches the route name
Vex::Application.config.dynamic_models = Dir["#{Rails.root}/app/models/configuration/*.rb"].map{ |a| File.basename(a, ".rb") }
