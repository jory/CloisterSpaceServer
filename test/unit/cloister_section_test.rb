require 'test_helper'

class CloisterSectionTest < ActiveSupport::TestCase
  def setup
    @cloister = Cloister.create(:game => games(:one), :row => 0, :col => 0)
  end

  test "invalid row" do
    assert !CloisterSection.create(:col => 0, :cloister => @cloister).valid?

    assert !CloisterSection.create(:row =>  -1, :col => 0, :cloister => @cloister).valid?
    assert !CloisterSection.create(:row => 145, :col => 0, :cloister => @cloister).valid?
    assert !CloisterSection.create(:row => "n", :col => 0, :cloister => @cloister).valid?
    # assert !CloisterSection.create(:row => "1", :col => 0, :cloister => @cloister).valid?
  end

  test "invalid col" do
    assert !CloisterSection.create(:row => 0, :cloister => @cloister).valid?

    assert !CloisterSection.create(:col =>  -1, :row => 0, :cloister => @cloister).valid?
    assert !CloisterSection.create(:col => 145, :row => 0, :cloister => @cloister).valid?
    assert !CloisterSection.create(:col => "n", :row => 0, :cloister => @cloister).valid?
    # assert !CloisterSection.create(:col => "1", :row => 0, :cloister => @cloister).valid?
  end

  test "needs cloister" do
    assert !CloisterSection.create(:row => 0, :col => 0).valid?
  end

  test "valid CloisterSection" do
    assert CloisterSection.create(:row => 0, :col => 0, :cloister => @cloister).valid?
  end
end
