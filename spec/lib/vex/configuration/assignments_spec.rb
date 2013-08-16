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
    
    context "#ClassMethods" do
      describe "#assigned_to" do
        it "should set vex_dependencies correctly" do 
          AssignmentTestSingularA.vex_dependencies["triggers"].include?(:assignment_test_singular_b).should be_true
        end
        
        it "should set vex_assignments correctly" do
          AssignmentTestSingularA.vex_assignments.keys.include?(:assignment_test_singular_b).should be_true
        end
      end
      describe "#assigned" do
        it "should set vex_dependencies correctly" do 
          AssignmentTestSingularB.vex_dependencies["triggered_by"].include?(:assignment_test_singular_a).should be_true
        end
        
        it "should set vex_assignments correctly" do 
          AssignmentTestSingularB.vex_assignments.keys.include?(:assignment_test_singular_a).should be_true
        end
      end
      describe "#assigned_and_assigned_to" do
        it "should set vex_dependencies correctly" do 
          AssignmentTestSingularC.vex_dependencies["triggers"].include?(:assignment_test_singular_d).should be_true
          AssignmentTestSingularC.vex_dependencies["triggered_by"].include?(:assignment_test_singular_d).should be_true
          AssignmentTestSingularD.vex_dependencies["triggers"].include?(:assignment_test_singular_c).should be_true
          AssignmentTestSingularD.vex_dependencies["triggered_by"].include?(:assignment_test_singular_c).should be_true
        end
        
        it "should set vex_assignments correctly" do
          AssignmentTestSingularC.vex_assignments.keys.include?(:assignment_test_singular_d).should be_true
          AssignmentTestSingularD.vex_assignments.keys.include?(:assignment_test_singular_c).should be_true
        end
      end
    end
    
    describe "#[assignment]_tokens" do
      it "should respond to the token method created for the assignment" do
        AssignmentTestSingularA.new.respond_to?("assignment_test_singular_b_tokens").should be_true
        AssignmentTestSingularB.new.respond_to?("assignment_test_singular_a_tokens").should be_true
        AssignmentTestSingularC.new.respond_to?("assignment_test_singular_d_tokens").should be_true
        AssignmentTestSingularD.new.respond_to?("assignment_test_singular_c_tokens").should be_true
      end
    end
    
    describe "#[assignment]" do
      it "should respond to the method created for the assignment" do
        AssignmentTestSingularA.new.respond_to?("assignment_test_singular_b").should be_true
        AssignmentTestSingularB.new.respond_to?("assignment_test_singular_a").should be_true
        AssignmentTestSingularC.new.respond_to?("assignment_test_singular_d").should be_true
        AssignmentTestSingularD.new.respond_to?("assignment_test_singular_c").should be_true
      end
      
      it "should return a wrapper" do
        AssignmentTestSingularA.new.send("assignment_test_singular_b").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
        AssignmentTestSingularB.new.send("assignment_test_singular_a").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
        AssignmentTestSingularC.new.send("assignment_test_singular_d").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
        AssignmentTestSingularD.new.send("assignment_test_singular_c").is_a?(Vex::Dsl::Wrappers::Assignment::Wrapper).should be_true
      end
    end
    
    describe "#vex_dependencies" do
      it "should be the same value as the ClassMethod #vex_dependencies" do
        AssignmentTestSingularA.new.vex_dependencies["triggers"].include?(:assignment_test_singular_b).should be_true
        AssignmentTestSingularB.new.vex_dependencies["triggered_by"].include?(:assignment_test_singular_a).should be_true
        AssignmentTestSingularC.new.vex_dependencies["triggers"].include?(:assignment_test_singular_d).should be_true
        AssignmentTestSingularD.new.vex_dependencies["triggers"].include?(:assignment_test_singular_c).should be_true
        AssignmentTestSingularC.new.vex_dependencies["triggered_by"].include?(:assignment_test_singular_d).should be_true
        AssignmentTestSingularD.new.vex_dependencies["triggered_by"].include?(:assignment_test_singular_c).should be_true
      end
    end
    describe "#vex_assignments" do
      it "should be the same value as the ClassMethod #vex_dependencies" do
        AssignmentTestSingularA.new.vex_assignments.keys.include?(:assignment_test_singular_b).should be_true
        AssignmentTestSingularB.new.vex_assignments.keys.include?(:assignment_test_singular_a).should be_true
        AssignmentTestSingularC.new.vex_assignments.keys.include?(:assignment_test_singular_d).should be_true
        AssignmentTestSingularD.new.vex_assignments.keys.include?(:assignment_test_singular_c).should be_true
      end
    end
  end
end