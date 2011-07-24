require 'test_helper'

class CitySectionTest < ActiveSupport::TestCase

  def setup
    @city = City.create(:game => games(:one))
  end

  test "invalid row" do
    assert !CitySection.create(:col => 0, :edge => "north", :city => @city).valid?

    assert !CitySection.create(:row =>  -1, :col => 0, :edge => "north", :city => @city).valid?
    assert !CitySection.create(:row => 145, :col => 0, :edge => "north", :city => @city).valid?
    assert !CitySection.create(:row => "n", :col => 0, :edge => "north", :city => @city).valid?
    # assert !CitySection.create(:row => "1", :col => 0, :edge => "north", :city => @city).valid?
  end

  test "invalid col" do
    assert !CitySection.create(:row => 0, :edge => "north", :city => @city).valid?

    assert !CitySection.create(:col =>  -1, :row => 0, :edge => "north", :city => @city).valid?
    assert !CitySection.create(:col => 145, :row => 0, :edge => "north", :city => @city).valid?
    assert !CitySection.create(:col => "n", :row => 0, :edge => "north", :city => @city).valid?
    # assert !CitySection.create(:col => "1", :row => 0, :edge => "north", :city => @city).valid?
  end

  test "invalid edge" do
    assert !CitySection.create(:row => 0, :col => 0, :city => @city).valid?

    assert !CitySection.create(:edge => "n", :row => 0, :col => 0, :city => @city).valid?
    assert !CitySection.create(:edge =>   1, :row => 0, :col => 0, :city => @city).valid?
  end

  test "needs city" do
    assert !CitySection.create(:row => 0, :col => 0, :edge => "north").valid?
  end

  test "valid CitySection" do
    assert CitySection.create(:row => 0, :col => 0, :edge => "north", :city => @city).valid?
  end
end
