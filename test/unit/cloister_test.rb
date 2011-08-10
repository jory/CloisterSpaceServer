require 'test_helper'

class CloisterTest < ActiveSupport::TestCase

  def setup
    creator = users(:foobar)
    users = [{:email => creator.email, :colour => 'blue'}]
    @game = Game.create(:creator => creator, :users => users)
    @cloister = Cloister.create(:row => 72, :col => 72, :game => @game)
  end
  
  test "invalid row" do
    assert !Cloister.create(:col => 0, :game => @game).valid?
    
    assert !Cloister.create(:row =>  -1, :col => 0, :game => @game).valid?
    assert !Cloister.create(:row => 145, :col => 0, :game => @game).valid?
    assert !Cloister.create(:row => "n", :col => 0, :game => @game).valid?
    assert !Cloister.create(:row => 1.1, :col => 0, :game => @game).valid?
  end

  test "invalid col" do
    assert !Cloister.create(:row => 0, :game => @game).valid?
    
    assert !Cloister.create(:col =>  -1, :row => 0, :game => @game).valid?
    assert !Cloister.create(:col => 145, :row => 0, :game => @game).valid?
    assert !Cloister.create(:col => "n", :row => 0, :game => @game).valid?
    assert !Cloister.create(:col => 1.1, :row => 0, :game => @game).valid?
  end

  test "valid Cloister" do
    assert Cloister.create(:row => 0, :col => 0, :game => @game).valid?
  end

  test "sensible defaults" do
    assert !@cloister.finished
    assert_equal @cloister.size, 1
    assert @cloister.cloisterSections.empty?
  end

  test "adding a neighbour should increase size" do
    @cloister.add(72, 73)

    assert_equal @cloister.size, 2
    assert_equal @cloister.cloisterSections.length, 1
  end

  test "adding a non-neighbour shouldn't increase size" do
    @cloister.add(0, 0)
    @cloister.add(73, 74)
    @cloister.add(70, 72)

    assert_equal @cloister.size, 1
    assert_equal @cloister.cloisterSections.length, 0
  end

  test "adding all your neighbours should mark you as finished" do
    @cloister.add(71, 71)
    @cloister.add(71, 72)
    @cloister.add(71, 73)
    @cloister.add(72, 71)
    @cloister.add(72, 73)
    @cloister.add(73, 71)
    @cloister.add(73, 72)
    @cloister.add(73, 73)

    assert @cloister.finished
    assert_equal @cloister.size, 9
    assert_equal @cloister.cloisterSections.length, 8
  end
end
