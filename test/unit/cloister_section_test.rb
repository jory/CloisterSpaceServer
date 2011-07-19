require 'test_helper'

class CloisterSectionTest < ActiveSupport::TestCase
  test "needs cloister" do
    assert !CloisterSection.create(:row => 0, :col => 0).save
  end

  test "valid section saves" do
    cloister = Cloister.create(:game => Game.first, :row => 0, :col => 0)
    assert CloisterSection.create(:row => 0, :col => 0, :cloister => cloister).save
  end
end
