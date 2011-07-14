require 'test_helper'

class RoadSectionTest < ActiveSupport::TestCase

  test "needs road feature" do
    assert !RoadSection.create(:x => 0, :y => 0, :edge => "north", :num => 0,
                               :hasEnd => true).save
  end

  test "valid section saves" do
    assert RoadSection.create(:x => 0, :y => 0, :edge => "north", :num => 0,
                              :hasEnd => true,
                              :road_feature =>
                              RoadFeature.create(:game => Game.first)).save
  end
  
end
