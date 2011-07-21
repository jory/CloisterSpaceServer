require 'test_helper'

class TileInstanceTest < ActiveSupport::TestCase

  def setup
    @game = games(:one)

    @startingTile = tiles(:start)
    @otherTile = tiles(:city1rwe)
  end
  
  test "needs game" do
    assert !TileInstance.create(:tile => @startingTile).save
  end

  test "needs tile" do
    assert !TileInstance.create(:game => @game).save
  end

  test "not negative" do
    instance = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !instance.place(-1, -1, 0)
  end

  test "no overlapping" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(0, 0, 0)

    q = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !q.place(0, 0, 0)
  end

  test "no double placement" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    assert p.place(0, 0, 0)
    assert !p.place(1, 1, 1)
  end

  test "must set all" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !p.place(nil, 0, 0)
    assert !p.place(0, nil, 0)
    assert !p.place(0, 0, nil)
  end

  test "must be adjacent" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(0, 0, 0), "Placed a tile far away"
    assert q.place(72, 73, 0)
  end

  test "must match edges" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(71, 72, 0)
    assert q.place(72, 73, 0)
  end

  test "must match rotated edges" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert q.place(73, 72, 2), "Couldn't place rotated next to non-rotated."

    r = TileInstance.create(:tile => @otherTile, :game => @game)
    assert r.place(73, 73, 2), "Couldn't place rotated next to rotated."

    s = TileInstance.create(:tile => @otherTile, :game => @game)
    assert s.place(73, 74, 0), "Couldn't place non-rotated next to rotated."

    t = TileInstance.create(:tile => @otherTile, :game => @game)
    assert t.place(72, 73, 0), "Couldn't place non-rotated next to both."
  end

  test "next returns current" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)
    q.status = "current"
    q.save

    r = TileInstance.create(:tile => tiles(:city4q), :game => @game)
    
    assert q === TileInstance.next(@game)
  end
  
  test "next returns a tile" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)

    r = TileInstance.create(:tile => tiles(:city4q), :game => @game)
    
    assert TileInstance.next(@game)
  end

  ##########################################
  # TODO: Uncomment this test, and handle it.
  ##########################################
  # test "shouldn't return unusable tiles" do
  #   p = TileInstance.create(:tile => @startingTile, :game => @game)
  #   p.place(72, 72, 0)

  #   q = TileInstance.create(:tile => @otherTile, :game => @game)
  #   q.place(71, 72, 2)
    
  #   r = TileInstance.create(:tile => tiles(:city4q), :game => @game)
  #   assert !TileInstance.next(@game)
  # end
  ##########################################

  ##########################################
  # Because @game is a fixture, it doesn't seem to support looking up
  # the Roads via @game.roads
  #
  # TODO: Figure out how to get that style of lookup working.
  ##########################################

  test "starting tile should create a road" do
    assert Road.where(:game_id => @game).empty?

    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    assert !Road.where(:game_id => @game).empty?, "Roads is still empty!"
  end

  test "starting tile should create a *single* road" do
    assert Road.where(:game_id => @game).empty?

    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    roads = Road.where(:game_id => @game)
    
    assert roads.length == 1, "Found #{roads.length} roads, expected 1."
  end

  test "starting tile's road should be of length 1, numEnds 0, finished false" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)
    road = Road.where(:game_id => @game).first

    assert road.length == 1
    assert road.numEnds == 0
    assert !road.finished
  end

  test "road3 has three roads, all with length 1 and 1 end" do
    p = TileInstance.create(:tile => tiles(:sroad3), :game => @game)
    p.place(72, 72, 0)

    roads = Road.where(:game_id => @game)

    assert roads.length == 3, "Found #{roads.length} roads, but was expecting 3."

    roads.each do |road|
      assert road.length == 1
      assert road.numEnds == 1
      assert !road.finished
    end
  end

  test "a road can be finished" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city3r), :game => game)
    q = TileInstance.create(:tile => tiles(:city3r), :game => game)

    assert p.place(72, 73, 1)
    assert q.place(72, 71, 3)

    roads = game.roads
    assert roads.length == 1, "Found #{roads.length} roads, expected 1"

    road = roads.first
    assert road.length == 3, "Road was length #{road.length}, expecting 3"
    assert road.numEnds == 2, "Road had #{road.numEnds}, expected 2"
    assert road.finished, "Road wasn't fnished"
  end

  test "roads can merge" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city1rsw), :game => game)
    q = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    r = TileInstance.create(:tile => tiles(:road2sw), :game => game)

    assert p.place(71, 72, 2)
    assert q.place(72, 73, 1)
    assert r.place(71, 73, 0)

    roads = game.roads
    assert roads.length == 1, "Found #{roads.length} roads, expected 1"

    road = roads.first
    assert road.length == 4, "Road was length #{road.length}, expecting 4"
    assert road.numEnds == 0, "Road had #{road.numEnds}, expected 0"
    assert !road.finished, "Road was finished, but shouldn't have been"
  end

  test "loops can close" do
    p = TileInstance.create(:tile => tiles(:sroad2sw), :game => @game)
    q = TileInstance.create(:tile => tiles(:road2sw), :game => @game)
    r = TileInstance.create(:tile => tiles(:road2sw), :game => @game)
    s = TileInstance.create(:tile => tiles(:road2sw), :game => @game)

    roads = Road.where(:game_id => @game)
    assert roads.length == 0, "Found #{roads.length} roads, expected 0 (no tiles)"

    assert p.place(72, 72, 0)

    roads = Road.where(:game_id => @game)
    assert roads.length == 1, "Found #{roads.length} roads, expected 1 (one tile)"

    assert q.place(73, 72, 1)

    roads = Road.where(:game_id => @game)
    assert roads.length == 1, "Found #{roads.length} roads, expected 1 (two tiles)"

    assert r.place(73, 71, 2)

    roads = Road.where(:game_id => @game)
    assert roads.length == 1, "Found #{roads.length} roads, expected 1 (three tiles)"

    assert s.place(72, 71, 3)

    roads = Road.where(:game_id => @game)
    assert roads.length == 1, "Found #{roads.length} roads, expected 1 (all tiles)"

    road = roads.first
    assert road.length == 4, "Road was length #{road.length}, expecting 4"
    assert road.numEnds == 0, "Road had #{road.numEnds}, expected 0"
    assert road.finished, "Road wasn't finished, but should have been"
  end

  test "cloister tile should create a cloister" do
    game = Game.create()
    
    p = TileInstance.create(:tile => tiles(:cloister), :game => game)

    cloisters = Cloister.where(:game_id => game)
    assert cloisters.length == 0, "Found #{cloisters.length} cloisters, expected 0"

    assert p.place(73, 72, 0)

    cloisters = Cloister.where(:game_id => game)
    assert cloisters.length == 1, "Found #{cloisters.length} cloisters, expected 1"
  end

  test "cloister tile should see exisiting neighbours" do
    game = Game.create()
    
    p = TileInstance.create(:tile => tiles(:cloister), :game => game)

    assert p.place(73, 72, 0)

    cloisters = Cloister.where(:game_id => game)
    cloister = cloisters.first

    assert cloister.size == 2, "Cloister's size was #{cloister.size}, expected 2"
  end
  
  test "surrounded cloister is finished" do
    game = Game.create()
    
    p = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    q = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    r = TileInstance.create(:tile => tiles(:road2ns), :game => game)
    s = TileInstance.create(:tile => tiles(:road2ns), :game => game)
    t = TileInstance.create(:tile => tiles(:road2ns), :game => game)
    u = TileInstance.create(:tile => tiles(:road2ns), :game => game)
    v = TileInstance.create(:tile => tiles(:city1), :game => game)

    assert p.place(72, 71, 3)
    assert q.place(72, 73, 0)
    assert r.place(73, 71, 0)
    assert s.place(73, 73, 0)
    assert t.place(74, 71, 0)
    assert u.place(74, 73, 0)
    assert v.place(74, 72, 2)
    
    c = TileInstance.create(:tile => tiles(:cloister), :game => game)
    assert c.place(73, 72, 0)

    cloisters = Cloister.where(:game_id => game)
    cloister = cloisters.first

    assert cloister.size == 9, "Cloister's size was #{cloister.size}, expected 9"
    assert cloister.finished, "Cloister wasn't finished"
  end

  test "cloister tile should see new neighbours" do
    game = Game.create()
    
    p = TileInstance.create(:tile => tiles(:cloister), :game => game)

    assert p.place(73, 72, 0)

    q = TileInstance.create(:tile => tiles(:road2sw), :game => game)

    assert q.place(72, 73, 0)

    cloisters = Cloister.where(:game_id => game)
    assert cloisters.length == 1, "Found #{cloisters.length} Cloisters, was expecting 1"

    cloister = cloisters.first
    assert cloister.size == 3, "Cloister's size was #{cloister.size}, expected 3"
  end

  test "cloisters can be neighbours" do
    game = Game.create()
    
    p = TileInstance.create(:tile => tiles(:cloister), :game => game)

    assert p.place(73, 72, 0)

    q = TileInstance.create(:tile => tiles(:cloister), :game => game)

    assert q.place(73, 73, 0)

    cloisters = Cloister.where(:game_id => game)
    assert cloisters.length == 2, "Found #{cloisters.length} Cloisters, was expecting 2"

    cloister = cloisters.first
    assert cloister.size == 3, "Cloister's size was #{cloister.size}, expected 3"

    second = cloisters[1]
    assert second.size == 3, "Cloister's size was #{second.size}, expected 3"
  end

  test "starting tile should create a city" do
    game = Game.create()
    assert !game.cities.empty?, "Starting tile didn't create a City."

    city = game.cities.first

    assert city.size == 1
    assert city.pennants == 0
  end

  test "minimal finished city" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city1), :game => game)

    assert p.place(71, 72, 2)

    assert game.cities.count == 1, "Found #{game.cities.count} Cities, expected 1"

    city = game.cities.first

    assert city.size == 2, "City was size #{city.size}, expected 2"
    assert city.pennants == 0, "City has #{city.pennants} pennants, expected 0"
    assert city.finished, "City wasn't finished"
  end

  test "merge two minimals" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    q = TileInstance.create(:tile => tiles(:city1), :game => game)
    r = TileInstance.create(:tile => tiles(:city2nw), :game => game)

    assert p.place(72, 71, 3)
    assert q.place(71, 71, 1)

    assert game.cities.count == 2

    assert r.place(71, 72, 3)

    assert game.cities.count == 1

    city = game.cities.first

    assert city.size == 3
    assert city.finished, "City wasn't finished, but should have been."
  end

  test "merge three minimals" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    q = TileInstance.create(:tile => tiles(:city1), :game => game)
    r = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    s = TileInstance.create(:tile => tiles(:city1), :game => game)
    t = TileInstance.create(:tile => tiles(:city3), :game => game)

    assert p.place(72, 71, 3)
    assert q.place(71, 71, 1)

    assert game.cities.count == 2

    assert r.place(70, 71, 1)
    assert s.place(70, 72, 2)

    assert game.cities.count == 3

    assert t.place(71, 72, 3)

    assert game.cities.count == 1

    city = game.cities.first

    assert city.size == 4, "City was size #{city.size}, expected 4"
    assert city.finished, "City wasn't finished, but should have been."
  end    

  test "merge four minimals" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    q = TileInstance.create(:tile => tiles(:city1), :game => game)
    r = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    s = TileInstance.create(:tile => tiles(:city1), :game => game)
    t = TileInstance.create(:tile => tiles(:road2sw), :game => game)
    u = TileInstance.create(:tile => tiles(:city1), :game => game)
    v = TileInstance.create(:tile => tiles(:city4q), :game => game)

    assert p.place(72, 71, 3)
    assert q.place(71, 71, 1)

    assert game.cities.count == 2

    assert r.place(70, 71, 1)
    assert s.place(70, 72, 2)

    assert game.cities.count == 3

    assert t.place(70, 73, 2)
    assert u.place(71, 73, 3)

    assert game.cities.count == 4

    assert v.place(71, 72, 0)

    assert game.cities.count == 1

    city = game.cities.first

    assert city.size == 5, "City was size #{city.size}, expected 5"
    assert city.finished, "City wasn't finished, but should have been."
  end
  
  test "two cities on one tile only add to size of a single city once" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city3), :game => game)
    q = TileInstance.create(:tile => tiles(:city11ne), :game => game)
    r = TileInstance.create(:tile => tiles(:city2nw), :game => game)
    s = TileInstance.create(:tile => tiles(:city2nw), :game => game)

    assert p.place(71, 72, 3)
    assert q.place(71, 71, 0)
    assert r.place(70, 72, 3)
    assert s.place(70, 71, 2)

    assert game.cities.count == 1

    city = game.cities.first

    assert city.size == 5, "City was size #{city.size}, expected 5"
    assert city.finished, "City wasn't finished, but should have been."
  end

  test "starting tile has two farms" do
    game = Game.create()

    assert game.farms.length == 2, "Found #{game.farms.length} farms, expected 2"
  end

  test "weird bug I saw in the browser?" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city4q), :game => game)
    p.place(71, 72, 0)

    assert game.farms.length == 2, "Found #{game.farms.length} farms, expected 2"

    game.farms.each do |farm|
      assert farm.size == 1
    end
  end

  test "another weird browser bug" do
    game = Game.create()
    p = TileInstance.create(:tile => tiles(:city2weq), :game => game)
    p.place(71, 72, 1)

    assert game.farms.length == 4, "Found #{game.farms.length} farms, expected 2"

    game.farms.each do |farm|
      assert farm.size == 1
    end

    assert game.cities.length == 1, "Found #{game.cities.length} cities, expected 1"

    city = game.cities.first
    assert city.size == 2
    assert city.pennants == 1
  end
end
