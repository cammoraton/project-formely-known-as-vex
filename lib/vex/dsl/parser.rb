Dir[File.dirname(__FILE__) + '/parser/*.rb'].each {|file| require file }

module Vex
  module Dsl
    class Parser
      def initialize(config)
        @config = config
        @caches = false
        unless @config["cache_associations"].nil?
          @caches = true
          @config.delete("cache_associations")
        end
      end
      
      def classes
        @config.keys.select{ |a| a if @config[a].is_a? Hash }
      end
      
      # Construct the class
      def load(key, base_class)
        return if @config[key].nil?
        return unless @config[key].is_a? Hash
        
        constant = key.to_s.singularize.camelize
        klass = Class.new(base_class)
        
        if @caches
          klass.class_eval do has_cache; end;
        end
        
        route_alias = @config[key]["routed_as"]
        unless route_alias.nil?
          klass.class_eval do routed_as route_alias; end
        end
        
        unless @config[key]["hiera"].nil?
          klass.class_eval do has_facts; end
        end
        
        unless @config[key]["facts"].nil?
          klass.class_eval do simulates_hiera; end
        end
        
        unless @config[key]["assigned"].nil?
          @config[key]["assigned"].each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned object.to_sym, :through => through; end
            end
          end
        end
        unless @config[key]["assigned_to"].nil?
          @config[key]["assigned_to"].each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned_to item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned_to object.to_sym, :through => through; end
            end
          end
        end
        unless @config[key]["assigned_and_assigned_to"].nil?
          @config[key]["assigned_and_assigned_to"].each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned_and_assigned_to item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned_and_assigned_to object.to_sym, :through => through; end
            end
          end
        end
        unless @config[key]["scopes"]
          klass.class_eval do has_scopes; end
        end
        
        Object.const_set(constant, klass) rescue nil
      end
      
      def load_all(base_class)
        @config.keys.each do |key|
          load(key, base_class)
        end
      end
    end
  end
end