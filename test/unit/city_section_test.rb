require 'test_helper'

class CitySectionTest < ActiveSupport::TestCase

  test "needs city" do
    assert !CitySection.create(:row => 0, :col => 0, :edge => "north").save
  end
end
