# Assume the file name matches the model name matches the route name
require 'vex'

parser = Vex::Dsl::Parser.new(YAML::load(File.open("#{Rails.root}/config/models.yml", "r")))
Vex::Application.config.dynamic_models = parser.classes.map{ |a| a.to_s.singularize }
puts Vex::Application.config.dynamic_models.inspect
parser.load_all(Configuration)