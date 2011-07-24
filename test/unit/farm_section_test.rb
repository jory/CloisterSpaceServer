require 'test_helper'

class FarmSectionTest < ActiveSupport::TestCase

  def setup
    @farm = Farm.create(:game => games(:one))
  end

  test "invalid row" do
    assert !FarmSection.create(:col => 0, :edge => "north",
                               :num => 0, :farm => @farm).valid?    

    assert !FarmSection.create(:row =>  -1, :col => 0, :edge => "north",
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:row => 145, :col => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:row => "n", :col => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:row => 1.1, :col => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?
  end

  test "invalid col" do
    assert !FarmSection.create(:row => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    

    assert !FarmSection.create(:col =>  -1, :row => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:col => 145, :row => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:col => "n", :row => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:col => 1.1, :row => 0, :edge => "north", 
                               :num => 0, :farm => @farm).valid?    
  end

  test "invalid edge" do
    assert !FarmSection.create(:col =>  0, :row => 0, 
                               :num => 0, :farm => @farm).valid?    
    
    assert !FarmSection.create(:col =>  0, :row => 0, :edge => "n", 
                               :num => 0, :farm => @farm).valid?    
    assert !FarmSection.create(:col =>  0, :row => 0, :edge => 1, 
                               :num => 0, :farm => @farm).valid?    
  end

  test "invalid num" do
    assert !FarmSection.create(:row =>  0, :col => 0, :edge => "north",
                               :farm => @farm).valid?    
    
    assert !FarmSection.create(:row =>  0, :col => 0, :edge => "north", 
                               :num => -1, :farm => @farm).valid?    
    assert !FarmSection.create(:row =>  0, :col => 0, :edge => "north", 
                               :num => "n", :farm => @farm).valid?    
    assert !FarmSection.create(:row =>  0, :col => 0, :edge => "north", 
                               :num => 1.1, :farm => @farm).valid?    
  end

  test "needs farm" do
    assert !FarmSection.create(:row => 0, :col => 0, :edge => "north", 
                               :num => 0).valid?
  end

  test "valid FarmSection" do
    assert FarmSection.create(:row => 0, :col => 0, :edge => "north", 
                              :num => 0, :farm => @farm).valid?
  end
end
