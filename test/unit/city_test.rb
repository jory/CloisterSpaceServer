require 'test_helper'

class CityTest < ActiveSupport::TestCase

  def setup
    @game = Game.first
    @city = City.create(:game => @game)
  end

  test "needs game" do
    assert !City.create().save
  end

  test "sensible defaults" do
    assert !@city.finished, "Finished should be false."
    assert @city.size == 0, "Size should be 0."
    assert @city.pennants == 0, "Should have 0 pennants."
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
  
  test "adding new tile should increase size" do
    assert @city.size == 0, "City was size #{@city.size}, expected 0."

    @city.add(0, 0, :north, 1, 3, false)
    assert @city.size == 1, "City was size #{@city.size}, expected 1."

    @city.add(0, 0, :south, 1, 3, false)
    assert @city.size == 1, "City was size #{@city.size}, should have still been 1."
  end

  test "adding a pennant should increase size, once" do
    assert @city.pennants == 0, "City had #{@city.pennants} pennants, expected 0."

    @city.add(0, 0, :north, 1, 3, true)
    assert @city.pennants == 1, "City had #{@city.pennants} pennants, expected 1."

    @city.add(0, 0, :south, 1, 3, true)
    assert @city.pennants == 1,
        "City had #{@city.pennants} pennants, should have still been 1."
  end

  ##########################################
  # TODO!
  ##########################################
  # test "don't add to finished" do
  # end
  
end
