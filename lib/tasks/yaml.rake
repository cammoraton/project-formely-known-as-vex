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
    Vex::Application.config.dynamic_models.each do |type|
      Rake::Task["yaml:import:#{type.to_s.pluralize}"].invoke
    end
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
    def actual_import(path, klass)
      return nil if FileTest::directory?(path)
      return nil unless FileTest::exist?(path)
      working = YAML::load(File.open(path))
      puts working.inspect
      check = klass.find_by_name(working["name"])
      if check.nil?
        check = klass.new(:name => working["name"])
      end
      working.delete("name")
      klass.vex_assignments.keys.each do |key|
        assign_klass = self.class.const_get(key.to_s.singularize.camelize)
        working_key = assign_klass.routing_path
        unless working[working_key].nil? or working[working_key].empty?
          ids = Array.new
          working[working_key].each do |item|
            find = assign_klass.find_by_name(item)
            ids.push(find) unless find.nil?
          end
          check.send(key).ids = ids.uniq.map {|a| a._id.to_s }
          working.delete(key)
        end
      end
      check.parameters = working
      check.save
    end
    
    def parse_dir(path, klass)
      return unless FileTest::directory?(path)
      Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        if FileTest::directory?(item)
          parse_dir(item, klass)
        else
          actual_import(item, klass)
        end
      end  
    end
    
    # There has to be a better way of doing this
    Dir["#{Rails.root}/app/models/configuration/*.rb"].map{ |a| File.basename(a, ".rb") }.each do |type|
      desc "Import the specified file as a #{type}"
      task type.to_s.singularize.to_sym => [ :environment, "yaml:instance_variables"] do
        actual_import(@vex_importexport_target, self.class.const_get(type.to_s.singularize.camelize))
      end
      
      desc "Import all files in the specified directory as #{type.to_s.pluralize}"
      task type.to_s.pluralize.to_sym => [ :environment, "yaml:instance_variables"] do
        parse_dir("#{@vex_import_directory}/#{type.pluralize}", self.class.const_get(type.to_s.singularize.camelize))
      end
    end
  end
end