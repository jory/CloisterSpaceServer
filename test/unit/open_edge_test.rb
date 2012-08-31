require 'test_helper'

class OpenEdgeTest < ActiveSupport::TestCase

  def setup
    @city = City.create(:game => games(:one))
  end

  test "invalid row" do
    assert !OpenEdge.create(:col => 0, :edge => "north",
                            :city => @city).valid?

    assert !OpenEdge.create(:row => -1, :col => 0, :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 145, :col => 0, :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => "n", :col => 0, :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 1.1, :col => 0, :edge => "north",
                            :city => @city).valid?
  end

  test "invalid col" do
    assert !OpenEdge.create(:row => 0, :edge => "north",
                            :city => @city).valid?    

    assert !OpenEdge.create(:row => 0, :col => -1, :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 0, :col => 145, :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 0, :col => "n", :edge => "north",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 0, :col => 1.1, :edge => "north",
                            :city => @city).valid?
  end

  test "invalid edge" do
    assert !OpenEdge.create(:row => 0, :col => 0,
                            :city => @city).valid?    

    assert !OpenEdge.create(:row => 0, :col => 0, :edge => "n",
                            :city => @city).valid?
    assert !OpenEdge.create(:row => 0, :col => 0, :edge => 1,
                            :city => @city).valid?
  end

  test "needs city" do
    assert !OpenEdge.create(:row => 0, :col => 0, :edge => "north").valid?
  end

  test "valid OpenEdge" do
    assert OpenEdge.create(:row => 0, :col => 0, :edge => "north",
                           :city => @city).valid?
  end
end
