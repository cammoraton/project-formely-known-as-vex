require 'spec_helper'

describe Vex::Dsl::Configuration::Assignments do
  context "single relationship" do
    before :all do
      class AssignmentTestSingularA < Configuration
        assigned_to :assignment_test_singular_b
      end
      
      class AssignmentTestSingularB < Configuration
        assigned :assignment_test_singular_a
      end
      
      class AssignmentTestSingularC < Configuration
        assigned_and_assigned_to :assignment_test_singular_d
      end
      
      class AssignmentTestSingularD < Configuration
        assigned_and_assigned_to :assignment_test_singular_c
      end
    end
    
    it "should set dependency class variables correctly" do
      AssignmentTestSingularA.vex_dependencies["triggers"].include?(:assignment_test_singular_b).should be_true
      AssignmentTestSingularB.vex_dependencies["triggered_by"].include?(:assignment_test_singular_a).should be_true
      AssignmentTestSingularC.vex_dependencies["triggers"].include?(:assignment_test_singular_d).should be_true
      AssignmentTestSingularC.vex_dependencies["triggered_by"].include?(:assignment_test_singular_d).should be_true
      AssignmentTestSingularD.vex_dependencies["triggers"].include?(:assignment_test_singular_c).should be_true
      AssignmentTestSingularD.vex_dependencies["triggered_by"].include?(:assignment_test_singular_c).should be_true
    end
    
    it "should see dependencies in a new class instance" do
      AssignmentTestSingularA.new.vex_dependencies.should == AssignmentTestSingularA.vex_dependencies
      AssignmentTestSingularB.new.vex_dependencies.should == AssignmentTestSingularB.vex_dependencies
      AssignmentTestSingularC.new.vex_dependencies.should == AssignmentTestSingularC.vex_dependencies
      AssignmentTestSingularD.new.vex_dependencies.should == AssignmentTestSingularD.vex_dependencies
    end
    
    it "should set assignment class variables correctly" do
      AssignmentTestSingularA.vex_assignments.keys.include?(:assignment_test_singular_b).should be_true
      AssignmentTestSingularB.vex_assignments.keys.include?(:assignment_test_singular_a).should be_true
      AssignmentTestSingularC.vex_assignments.keys.include?(:assignment_test_singular_d).should be_true
      AssignmentTestSingularD.vex_assignments.keys.include?(:assignment_test_singular_c).should be_true
    end
    
    it "should see the same assignments as the class methods via a new instance" do
      AssignmentTestSingularA.new.vex_assignments.should == AssignmentTestSingularA.vex_assignments
      AssignmentTestSingularB.new.vex_assignments.should == AssignmentTestSingularB.vex_assignments
      AssignmentTestSingularC.new.vex_assignments.should == AssignmentTestSingularC.vex_assignments
      AssignmentTestSingularD.new.vex_assignments.should == AssignmentTestSingularD.vex_assignments
    end
    
    it "should respond to token method" do
      AssignmentTestSingularA.new.respond_to?("assignment_test_singular_b_tokens").should be_true
      AssignmentTestSingularB.new.respond_to?("assignment_test_singular_a_tokens").should be_true
      AssignmentTestSingularC.new.respond_to?("assignment_test_singular_d_tokens").should be_true
      AssignmentTestSingularD.new.respond_to?("assignment_test_singular_c_tokens").should be_true
    end
    
    it "should respond to the assignment" do
      AssignmentTestSingularA.new.respond_to?("assignment_test_singular_b").should be_true
      AssignmentTestSingularB.new.respond_to?("assignment_test_singular_a").should be_true
      AssignmentTestSingularC.new.respond_to?("assignment_test_singular_d").should be_true
      AssignmentTestSingularD.new.respond_to?("assignment_test_singular_c").should be_true
    end
    
    it "should return a wrapper for the assignment" do
      AssignmentTestSingularA.new.send("assignment_test_singular_b").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
      AssignmentTestSingularB.new.send("assignment_test_singular_a").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
      AssignmentTestSingularC.new.send("assignment_test_singular_d").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
      AssignmentTestSingularD.new.send("assignment_test_singular_c").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
    end
  end
  
  context "when a nested relationship is defined" do
    before :all do
      class AssignmentTestNestedA < Configuration
        
      end
      
      class AssignmentTestNestedB < Configuration
        
      end
    end
  end
end