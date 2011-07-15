# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

tileDefinitions = ['city1rwe.png   1   start crgr   -1-1   1---   --122221   --   1',
                   'city1.png      5   reg   cggg   ----   1---   --111111   --   1',
                   'city1rse.png   3   reg   crrg   -11-   1---   --122111   --   1',
                   'city1rsw.png   3   reg   cgrr   --11   1---   --111221   --   1',
                   'city1rswe.png  3   reg   crrr   -123   1---   --122331   --   1',
                   'city1rwe.png   3   reg   crgr   -1-1   1---   --122221   --   1',
                   'city2nw.png    3   reg   cggc   ----   1--1   --1111--   --   1',
                   'city2nwq.png   2   reg   cggc   ----   1--1   --1111--   --   1',
                   'city2nwqr.png  2   reg   crrc   -11-   1--1   --1221--   --   1',
                   'city2nwr.png   3   reg   crrc   -11-   1--1   --1221--   --   1',
                   'city2we.png    1   reg   gcgc   ----   -1-1   11--22--   --   3',
                   'city2weq.png   2   reg   gcgc   ----   -1-1   11--22--   --   3',
                   'city3.png      3   reg   ccgc   ----   11-1   ----11--   --   1',
                   'city3q.png     1   reg   ccgc   ----   11-1   ----11--   --   1',
                   'city3qr.png    2   reg   ccrc   --1-   11-1   ----12--   --   3',
                   'city3r.png     1   reg   ccrc   --1-   11-1   ----12--   --   3',
                   'city4q.png     1   reg   cccc   ----   1111   --------   --   -',
                   'city11ne.png   2   reg   ccgg   ----   12--   ----1111   11   1',
                   'city11we.png   3   reg   gcgc   ----   -1-2   11--11--   11   1',
                   'cloister.png   4   reg   gggg   ----   ----   11111111   --   -',
                   'cloisterr.png  2   reg   ggrg   --1-   ----   11111111   --   -',
                   'road2ns.png    8   reg   rgrg   1-1-   ----   12222111   --   -',
                   'road2sw.png    9   reg   ggrr   --11   ----   11111221   --   -',
                   'road3.png      4   reg   grrr   -123   ----   11122331   --   -',
                   'road4.png      1   reg   rrrr   1234   ----   12233441   --   -']

tileDefinitions.each do |definition|
  tile = definition.gsub(/ +/, ' ').split(' ')

  # What to do with this count variable?
  # Where, in the grand schema of things, does it belong?
  count = tile[1]

  image = tile[0]
  hasPennant = (image['q'] != nil)
  isCloister = (image["cloister"] != nil)
  
  isStart = (tile[2] == 'start')
  
  edges = tile[3].split('')
  road  = tile[4].split('')
  city  = tile[5].split('')
  grass = tile[6].split('')

  hasTwoCities = (tile[7] == '11')
  
  citysFields = tile[8]

  roadEdgeCount = tile[3].count 'r'
  hasRoadEnd = (roadEdgeCount == 1 or roadEdgeCount == 3 or roadEdgeCount == 4)

  northEdge = Edge.find_or_create(edges[0], road[0], city[0], grass[0], grass[1]).id
  eastEdge  = Edge.find_or_create(edges[1], road[1], city[1], grass[2], grass[3]).id
  southEdge = Edge.find_or_create(edges[2], road[2], city[2], grass[4], grass[5]).id
  westEdge  = Edge.find_or_create(edges[3], road[3], city[3], grass[6], grass[7]).id
  
  Tile.create(:image => image, :count => count, :northEdge => northEdge,
              :eastEdge => eastEdge, :southEdge => southEdge,
              :westEdge => westEdge, :hasTwoCities => hasTwoCities,
              :hasRoadEnd => hasRoadEnd, :hasPennant => hasPennant,
              :citysFields => citysFields, :isCloister => isCloister,
              :isStart => isStart)
end
