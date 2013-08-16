require 'spec_helper'

describe Vex::Dsl::Configuration::Cache do
  before :all do
    class CacheTestA < Configuration
      assigned_to :cache_test_b
       
      has_cache
      # Access the private method via a public one for testing
      def update_cache_accessor
        update_cache
      end 
    end
     
    class CacheTestB < Configuration
      assigned :cache_test_b
       
      has_cache
      # Access the private method via a public one for testing
      def update_cache_accessor
        update_cache
      end 
    end
     
    class CacheTestNone < Configuration
       
    end
  end
  
  describe "#ClassMethods" do
    describe "#vex_cached" do
      it "should default vex_cached to false" do
        CacheTestNone.vex_cached.should be_false
      end 
  
      it "should set vex_cached to true if has_cache invoked" do
        CacheTestA.vex_cached.should be_true
      end
    end
  end
  
  describe "#has_cache?" do
    it "should have the same value as the ClassMethod #vex_cached" do
      CacheTestNone.new.has_cache?().should be_false
      CacheTestA.new.has_cache?().should be_true
    end
  end
end