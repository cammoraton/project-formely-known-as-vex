module Vex
  module Dsl
    module ClassFactory
      private
      def destroy_class(klass)
        
      end
      
      def create_class(constant, config, base_class)
        raise(ArgumentError, "Must pass the constant") if constant.class.nil?
        raise(ArgumentError, "Must pass a configuration") if config.class.nil?
        raise(ArgumentError, "Must specify a base_class") if base_class.nil?
        
        raise(ArgumentError, "Must pass the constant") unless constant.is_a? String
        raise(ArgumentError, "Must pass configuration as a hash") unless config.is_a? Hash
        raise(ArgumentError, "Base class must be a class") unless base_class.class.is_a? Class
        
        const = constant.singularize.camelize
        
        # This is a fun little kludge
        begin 
          raise(ArgumentError, "Constant can't already exist") unless Object.const_get(const).nil?
        rescue
          nil
        end
        
        klass = Class.new(base_class)
        overriden_cache = config['cache']
        
        if Vex::Application.config.cache_associations or overriden_cache
          unless !overriden_cache and !overriden_cache.nil?
            klass.class_eval do has_cache; end
          end
        end
        
        if config["has_facts"]
          klass.class_eval do has_facts; end
        end
        
        if config["simulates_hiera"]
          klass.class_eval do simulates_hiera; end
        end
        
        route_alias = config['routed_as']
        unless route_alias.nil?
          klass.class_eval do routed_as route_alias; end
        end
        
        assigned =  config["assigned"]
        unless assigned.nil?
          assigned.each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned object.to_sym, :through => through; end
            end
          end
        end
        
        assigned_to = config["assigned_to"]
        unless assigned_to.nil?
          assigned_to.each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned_to item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned_to object.to_sym, :through => through; end
            end
          end
        end
        
        assigned_and_assigned_to = config["assigned_and_assigned_to"]
        unless assigned_and_assigned_to.nil?
          assigned_and_assigned_to.each do |item|
            unless item.is_a? Hash
              klass.class_eval do assigned_and_assigned_to item.to_sym; end
            else
              object = item.keys.first
              through = item[object].map{|a| a.to_sym }
              klass.class_eval do assigned_and_assigned_to object.to_sym, :through => through; end
            end
          end
        end
        
        scopes = config["scopes"]
        unless scopes.nil?
          klass.class_eval do has_scopes; end
          # TODO: Actual scope config
        end
        
        Object.const_set(const, klass)
      end
    end
  end
end