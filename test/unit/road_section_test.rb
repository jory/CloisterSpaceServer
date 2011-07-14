require 'test_helper'

class RoadSectionTest < ActiveSupport::TestCase

  test "needs road feature" do
    assert !RoadSection.create().save
  end
  
end
