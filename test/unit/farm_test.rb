require 'test_helper'

class FarmTest < ActiveSupport::TestCase

  def setup
    @farm = Farm.create(:game => Game.create)
  end
  
  test "need game" do
    assert !Farm.create().save
  end

  test "size defaults to 0" do
    assert @farm.size == 0
  end

  test "score defaults to 0" do
    assert @farm.score == 0
  end

  test "farmSections starts empty" do
    assert @farm.farmSections.empty?
  end
  
end
