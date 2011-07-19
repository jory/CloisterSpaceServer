require 'test_helper'

class CloisterTest < ActiveSupport::TestCase

  def setup
    @game = Game.first
  end
  
  test "needs game" do
    assert !Cloister.create().save
  end

  test "needs row and col" do
    assert !Cloister.create(:game=> @game).save
  end

  test "good object should save" do
    cloister = Cloister.create(:game => @game, :row => 0, :col => 0)
    assert cloister.save
  end

  test "size and finished have good defaults" do
    cloister = Cloister.create(:game => @game, :row => 0, :col => 0)
    assert cloister.size == 1, "Cloister had size #{cloister.size}, expected 1"
    assert cloister.finished == false, "Cloister was finished"
  end

end
