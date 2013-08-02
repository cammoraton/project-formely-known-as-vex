require 'spec_helper'

shared_examples_for "configuration" do
  #it { testobject.should validate_uniqueness_of(:name) }
  #it { testobject.should validate_presence_of(:name) }
end

Vex::Application.config.dynamic_models.each do |item|
  klass = self.class.const_get(item.singularize.camelize)
  describe klass do
    let(:testobject) { klass.new }
    include_examples "configuration"
    klass.vex_assignments.keys.each do |association|
      describe association do
        #it "should default to an empty array" do
        #  testobject.send(association).should be_empty
        #end
      end
    end
  end 
end