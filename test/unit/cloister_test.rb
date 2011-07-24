require 'test_helper'

class CloisterTest < ActiveSupport::TestCase

  def setup
    @game = Game.create(:user => users(:foobar))
    @cloister = Cloister.create(:game => @game, :row => 72, :col => 72)
  end
  
  test "needs game" do
    assert !Cloister.create().save
  end

  test "needs row and col" do
    assert !Cloister.create(:game=> @game).save
  end

  test "row and col should respect bounds of board" do
    assert !Cloister.create(:game=> @game, :row => -1, :col => -1).save
    assert !Cloister.create(:game=> @game, :row => 145, :col => 145).save
  end
  
  test "good object should save" do
    assert @cloister.save
  end

  test "size and finished have good defaults" do
    assert @cloister.size == 1, "Cloister had size #{@cloister.size}, expected 1"
    assert @cloister.finished == false, "Cloister was finished"
  end

  test "adding a neighbour should increase size" do
    @cloister.add(72, 73)
    assert @cloister.size == 2, "Cloister had size #{@cloister.size}, expected 2"
  end

  test "adding a non-neighbour shouldn't increase size" do
    @cloister.add(0, 0)
    @cloister.add(73, 74)
    @cloister.add(70, 72)
    assert @cloister.size == 1, "Cloister had size #{@cloister.size}, expected 1"
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

    assert @cloister.size == 9, "Cloister had size #{@cloister.size}, expected 9"
    assert @cloister.finished, "Cloister should have been finished" 
  end
end
