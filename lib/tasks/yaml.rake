namespace :yaml do
  task :instance_variables do
    @vex_export_directory    = ENV["VEX_EXPORT_DIRECTORY"] || "#{Dir.pwd}/export"
    @vex_import_directory    = ENV["VEX_IMPORT_DIRECTORY"] || @vex_export_directory
    @vex_importexport_target = ENV["VEX_IMPORTEXPORT_TARGET"] || nil
  end
  
  desc "Export everything to specified directory"
  task :export => [ :environment, "yaml:instance_variables"] do
    Dir::mkdir(@vex_export_directory) unless FileTest::directory?(@vex_export_directory)
      Vex::Application.config.dynamic_models.each do |type|
      Rake::Task["yaml:export:#{type.to_s.pluralize}"].invoke
    end
  end
  
  desc "Import everything from the specified directory"
  task :import => [ :environment, "yaml:instance_variables"] do
    
  end
  
  namespace :export do
    def dump_configuration(path, object)
      File.open("#{path}/#{object.name}.yaml", "w") { |file| file.write(object.to_yaml) }
    end
    
    def verify_directory(path, subpath)
      Dir::mkdir(path) unless FileTest::directory?(path)
      Dir::mkdir("#{path}/#{subpath}") unless FileTest::directory?("#{path}/#{subpath}")
    end
    
    # There has to be a better way of doing this.
    Dir["#{Rails.root}/app/models/configuration/*.rb"].map{ |a| File.basename(a, ".rb") }.each do |type|
      desc "Export a single #{type} to the specified directory"
      task type.to_s.singularize.to_sym => [ :environment, "yaml:instance_variables"] do
        verify_directory(@vex_export_directory, type.pluralize)
        object = self.class.const_get(type.to_s.singularize.camelize).find_by_name(@vex_importexport_target)
        dump_configuration("#{@vex_export_directory}/#{type.pluralize}", object) unless object.nil?
      end
      
      desc "Export all #{type.to_s.pluralize} to the specified directory"
      task type.to_s.pluralize.to_sym => [ :environment, "yaml:instance_variables"] do
        verify_directory(@vex_export_directory, type.pluralize)
        self.class.const_get(type.to_s.singularize.camelize).all.each do |object|
          dump_configuration("#{@vex_export_directory}/#{type.pluralize}", object)
        end
      end
    end
  end
  namespace :import do
    Dir["#{Rails.root}/app/models/configuration/*.rb"].map{ |a| File.basename(a, ".rb") }.each do |type|
      
    end
  end
end