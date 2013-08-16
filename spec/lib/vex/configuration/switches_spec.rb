describe Vex::Dsl::Configuration::Switches do
  before :all do
    class SwitchTestClassAllSet < Configuration
      has_facts
      simulates_hiera
    end
    
    class SwitchTestClassNoneSet < Configuration; end;
  end
  context "#ClassMethods" do
    describe "#fact_source" do
      it "should default to false" do
        SwitchTestClassNoneSet.fact_source.should be_false
      end
    
      it "should be true when has_facts has been called" do
        SwitchTestClassAllSet.fact_source.should be_true
      end
    end
  
    describe "#hiera_view" do
      it "should default to false" do
        SwitchTestClassNoneSet.hiera_view.should be_false
      end
    
      it "should be true when simulates_hiera has been called" do
        SwitchTestClassAllSet.hiera_view.should be_true
      end
    end
  end
  
  describe "#has_facts?" do
    it "should have the same value as the ClassMethod #fact_source" do
      SwitchTestClassNoneSet.new.has_facts?().should be_false
      SwitchTestClassAllSet.new.has_facts?().should be_true
    end
  end
  
  describe "#simulates_hiera?" do
    it "should have the same value as the ClassMethod #hiera_view" do
      SwitchTestClassNoneSet.new.simulates_hiera?().should be_false
      SwitchTestClassAllSet.new.simulates_hiera?().should be_true
    end
  end
end