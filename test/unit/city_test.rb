require 'test_helper'

class CityTest < ActiveSupport::TestCase

  def setup
    @game = Game.create(:user => users(:foobar))
    @city = City.create(:game => @game)
  end

  test "needs game" do
    assert !City.create().valid?
  end

  test "sensible defaults" do
    assert !@city.finished, "Finished should be false."
    assert_equal @city.size,  0, "Size should be 0."
    assert_equal @city.pennants, 0, "Should have 0 pennants."
    assert @city.citySections.empty?
    assert @city.openEdges.empty?
  end

  test "no nil arguments to add" do
    assert !@city.add(nil, nil, nil, nil, nil, nil)
    assert !@city.add(nil, 0, :north, 1, 3, false)
    assert !@city.add(0, nil, :north, 1, 3, false)
    assert !@city.add(0, 0, nil, 1, 3, false)
    assert !@city.add(0, 0, :north, nil, 3, false)
    assert !@city.add(0, 0, :north, 1, nil, false)
    assert !@city.add(0, 0, :north, 1, 3, nil)
  end

  test "don't add exactly the same edge twice" do
    assert @city.add(0, 0, :north, 1, 3, false)
    assert !@city.add(0, 0, :north, 1, 3, false)
  end
  
  test "adding new tile should increase size (once)" do
    @city.add(0, 0, :north, 1, 3, false)
    assert_equal @city.size, 1, "City was size #{@city.size}, expected 1."

    @city.add(0, 0, :south, 1, 3, false)
    assert_equal @city.size, 1, "City was size #{@city.size}, should have still been 1."
  end

  test "adding a pennant should increase size, once" do
    @city.add(0, 0, :north, 1, 3, true)
    assert_equal @city.pennants, 1, "City had #{@city.pennants} pennants, expected 1."

    @city.add(0, 0, :south, 1, 3, true)
    assert_equal @city.pennants, 1,
    "City had #{@city.pennants} pennants, should have still been 1."
  end

  test "openEdges should count properly, and finish the city" do
    @city.add(72, 72, :north, 1, 1, false)
    assert !@city.finished, "City was finished, but shouldn't have been"

    @city.add(71, 72, :south, 1, 1, false)
    assert @city.finished, "City wasn't finished, but should have been"
  end

  test "created CitySection is associated to us" do
    @city.add(71, 72, :south, 1, 1, false)
    assert @city.citySections.any?
  end
  
  test "can't merge with nil" do
    assert !@city.merge(nil)
  end
  
  test "only merge within game" do
    other = City.create(:game => Game.create(:user => users(:foobar)))
    assert !@city.merge(other)
  end
  
  test "can't merge with yourself" do
    assert !@city.merge(@city)
  end

  test "has shouldn't accept nil" do
    assert !@city.has(nil, nil, nil)
    assert !@city.has(nil, 0, :north)
    assert !@city.has(0, nil, :north)
    assert !@city.has(0, 0, nil)
  end

  test "has should return false if it doesn't haz" do
    assert !@city.has(0, 0, 0)

    @city.add(1, 1, :north, 1, 1, true)
    assert !@city.has(0, 0, 0)
  end

  test "has should return true when it haz" do
    @city.add(0, 0, :north, 0, 0, false)
    assert @city.has(0, 0, 0)
  end

end
