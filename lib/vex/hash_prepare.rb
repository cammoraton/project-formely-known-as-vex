module Vex
  module PrepareHash
    extend ActiveSupport::Concern
    module ClassMethods
      # Callback Hooks
      def before_prep_methods
        @before_prep_methods ||= []
      end
          
      def after_prep_methods
        @after_prep_methods ||= []
      end
      
      def before_prep(method)
        @before_prep_methods = [] if @before_prep_methods.nil?
        @before_prep_methods.push(method) unless @before_prep_methods.include?(method)
      end
      
      def after_prep(method)
        @after_prep_methods = [] if @after_prep_methods.nil?
        @after_prep_methods.push(method) unless @after_prep_methods.include?(method)
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    private
    def prep_hash
      merge_hash = {}
      self.class.before_prep_methods.each do |method|
        merge_hash.merge(self.send(method))
      end
      self.vex_assignments.keys.each do |key|
        route = self.class.const_get(key.to_s.singularize.camelize).routing_path
        items = self.send(key).to_a
        if route.to_s != key.to_s
          merge_hash[route] = items.map{ |a| a["name"] }
        else
          merge_hash[key]   = items.map{ |a| a["name"] }
        end
      end
      result = { :name => self.name }.merge(self.data).merge(merge_hash)
      
      self.class.after_prep_methods.each do |method|
        result.merge(self.send(method))
      end
      return result
    end
    
  end
end