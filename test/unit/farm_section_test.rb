require 'test_helper'

class FarmSectionTest < ActiveSupport::TestCase

  def setup
    @farm = Farm.create(:game => Game.create)
  end

  test "need farm" do
    assert !FarmSection.create(:row => 0, :col => 0,
                               :edge => "north", :num => 0).save
  end
  
  test "need row" do
    assert !FarmSection.create(:farm => @farm, :col => 0,
                               :edge => "north", :num => 0).save
  end

  test "need col" do
    assert !FarmSection.create(:farm => @farm, :row => 0,
                               :edge => "north", :num => 0).save
  end

  test "need edge" do
    assert !FarmSection.create(:farm => @farm, :row => 0, :col => 0,
                               :num => 0).save
  end

  test "need num" do
    assert !FarmSection.create(:farm => @farm, :row => 0, :col => 0,
                               :edge => "north").save
  end
end
