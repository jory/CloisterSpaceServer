require 'test_helper'

class RoadSectionTest < ActiveSupport::TestCase

  def setup
    @road = Road.create(:game => games(:one))
  end
  
  test "invalid row" do
    assert !RoadSection.create(:col => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?

    assert !RoadSection.create(:row => -1, :col => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 145, :col => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => "n", :col => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 1.1, :col => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
  end

  test "invalid col" do
    assert !RoadSection.create(:row => 0, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?

    assert !RoadSection.create(:row => 0, :col => -1, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => 145, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => "n", :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => 1.1, :edge => "north", :num => 0,
                               :hasEnd => true, :road => @road).valid?
  end

  test "invalid edge" do
    assert !RoadSection.create(:row => 0, :col => 0, :num => 0,
                               :hasEnd => true, :road => @road).valid?

    assert !RoadSection.create(:row => 0, :col => 0, :edge => "n", :num => 0,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => 0, :edge => 1, :num => 0,
                               :hasEnd => true, :road => @road).valid?
  end

  test "invalid num" do
    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north",
                               :hasEnd => true, :road => @road).valid?

    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => -1,
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => "n",
                               :hasEnd => true, :road => @road).valid?
    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => 1.1,
                               :hasEnd => true, :road => @road).valid?
  end

  test "hasEnd" do
    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => 0,
                               :road => @road).valid?
  end
  
  test "needs road" do
    assert !RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => 0,
                               :hasEnd => true).valid?    
  end

  test "valid RoadSection" do
    assert RoadSection.create(:row => 0, :col => 0, :edge => "north", :num => 0,
                              :hasEnd => true, :road => @road).valid?
  end
end
