(function() {
  var City, Cloister, Edge, Farm, Road, Tile, World, adjacents, offset, oppositeDirection, print_features;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Array.prototype.remove = function(e) {
    var t, _ref;
    if ((t = this.indexOf(e)) > -1) {
      return ([].splice.apply(this, [t, t - t + 1].concat(_ref = [])), _ref);
    }
  };
  oppositeDirection = {
    "north": "south",
    "east": "west",
    "south": "north",
    "west": "east"
  };
  adjacents = {
    north: {
      row: -1,
      col: 0
    },
    east: {
      row: 0,
      col: 1
    },
    south: {
      row: 1,
      col: 0
    },
    west: {
      row: 0,
      col: -1
    }
  };
  offset = function(edge, row, col) {
    var offsets;
    offsets = adjacents[edge];
    return [row + offsets.row, col + offsets.col];
  };
  Edge = (function() {
    function Edge(type, road, city, grassA, grassB) {
      this.type = type;
      this.road = road;
      this.city = city;
      this.grassA = grassA;
      this.grassB = grassB;
    }
    return Edge;
  })();
  Tile = (function() {
    function Tile(image, north, east, south, west, hasTwoCities, hasRoadEnd, hasPennant, cityFields, isCloister, isStart) {
      this.image = image;
      this.hasTwoCities = hasTwoCities;
      this.hasRoadEnd = hasRoadEnd;
      this.hasPennant = hasPennant;
      this.cityFields = cityFields;
      this.isCloister = isCloister;
      this.isStart = isStart;
      this.edges = {
        north: north,
        east: east,
        south: south,
        west: west
      };
      this.rotation = 0;
      this.rotationClass = 'r0';
    }
    Tile.prototype.rotate = function(turns) {
      var i, tmp, _i, _ref, _results, _results2;
      if (__indexOf.call((function() {
        _results = [];
        for (var _i = _ref = -3; _ref <= 3 ? _i <= 3 : _i >= 3; _ref <= 3 ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this, arguments), turns) < 0) {
        throw 'Invalid Rotation';
      }
      if (turns !== 0) {
        switch (turns) {
          case -1:
            turns = 3;
            break;
          case -2:
            turns = 2;
            break;
          case -3:
            turns = 1;
        }
        this.rotation += turns;
        if (this.rotation > 3) {
          this.rotation -= 4;
        }
        this.rotationClass = "r" + this.rotation;
        _results2 = [];
        for (i = 1; 1 <= turns ? i <= turns : i >= turns; 1 <= turns ? i++ : i--) {
          tmp = this.edges.north;
          this.edges.north = this.edges.west;
          this.edges.west = this.edges.south;
          this.edges.south = this.edges.east;
          _results2.push(this.edges.east = tmp);
        }
        return _results2;
      }
    };
    Tile.prototype.reset = function() {
      if (this.rotation > 0) {
        return this.rotate(4 - this.rotation);
      }
    };
    Tile.prototype.connectableTo = function(from, other) {
      return this.edges[from].type === other.edges[oppositeDirection[from]].type;
    };
    return Tile;
  })();
  Road = (function() {
    function Road(row, col, edge, id, hasEnd) {
      this.tiles = {};
      this.ids = {};
      this.edges = {};
      this.length = 0;
      this.numEnds = 0;
      this.finished = false;
      this.add(row, col, edge, id, hasEnd);
    }
    Road.prototype.add = function(row, col, edge, id, hasEnd) {
      var address;
      address = "" + row + "," + col;
      if (!this.tiles[address]) {
        this.length += 1;
        this.tiles[address] = true;
      }
      this.ids[address + ("," + id)] = true;
      this.edges[address + ("," + edge)] = {
        row: row,
        col: col,
        edge: edge,
        id: id,
        hasEnd: hasEnd
      };
      if (hasEnd) {
        this.numEnds += 1;
        if (this.numEnds === 2) {
          return this.finished = true;
        }
      }
    };
    Road.prototype.has = function(row, col, id) {
      return this.ids["" + row + "," + col + "," + id];
    };
    Road.prototype.merge = function(other) {
      var e, edge, _ref, _results;
      _ref = other.edges;
      _results = [];
      for (e in _ref) {
        edge = _ref[e];
        _results.push(this.add(edge.row, edge.col, edge.edge, edge.id, edge.hasEnd));
      }
      return _results;
    };
    Road.prototype.toString = function() {
      var address, out;
      out = "Road: (";
      for (address in this.tiles) {
        out += "" + address + "; ";
      }
      return out.slice(0, -2) + ("), length: " + this.length + ", finished: " + this.finished + ", numEnds: " + this.numEnds);
    };
    return Road;
  })();
  City = (function() {
    function City(row, col, edge, id, cityFields, hasPennant) {
      this.tiles = {};
      this.ids = {};
      this.edges = {};
      this.openEdges = [];
      this.size = 0;
      this.numPennants = 0;
      this.finished = false;
      this.add(row, col, edge, id, cityFields, hasPennant);
    }
    City.prototype.add = function(row, col, edge, id, cityFields, hasPennant) {
      var address, otherAddress, otherCol, otherRow, _ref;
      address = "" + row + "," + col;
      if (!(this.tiles[address] != null)) {
        this.tiles[address] = cityFields;
        this.size += 1;
        if (hasPennant) {
          this.numPennants += 1;
        }
      }
      this.ids[address + ("," + id)] = true;
      this.edges[address + ("," + edge)] = {
        row: row,
        col: col,
        edge: edge,
        id: id
      };
      _ref = offset(edge, row, col), otherRow = _ref[0], otherCol = _ref[1];
      otherAddress = "" + otherRow + "," + otherCol + "," + oppositeDirection[edge];
      if (__indexOf.call(this.openEdges, otherAddress) >= 0) {
        this.openEdges.remove(otherAddress);
      } else {
        this.openEdges.push(address + ("," + edge));
      }
      if (this.openEdges.length === 0) {
        return this.finished = true;
      } else {
        return this.finished = false;
      }
    };
    City.prototype.has = function(row, col, id) {
      return this.ids["" + row + "," + col + "," + id];
    };
    City.prototype.merge = function(other) {
      var col, e, edge, row, _ref;
      _ref = other.edges;
      for (e in _ref) {
        edge = _ref[e];
        row = edge.row;
        col = edge.col;
        this.add(row, col, edge.edge, edge.id, other.tiles["" + row + "," + col], false);
      }
      return this.numPennants += other.numPennants;
    };
    City.prototype.toString = function() {
      var address, out;
      out = "City: (";
      for (address in this.tiles) {
        out += "" + address + "; ";
      }
      return out.slice(0, -2) + ("), size: " + this.size + ", finished: " + this.finished + ", numPennants: " + this.numPennants);
    };
    return City;
  })();
  Cloister = (function() {
    function Cloister(row, col) {
      var colOffset, otherCol, otherRow, rowOffset, _ref, _ref2;
      this.tiles = {};
      this.neighbours = {};
      this.size = 0;
      this.finished = false;
      for (rowOffset = _ref = -1; _ref <= 1 ? rowOffset <= 1 : rowOffset >= 1; _ref <= 1 ? rowOffset++ : rowOffset--) {
        for (colOffset = _ref2 = -1; _ref2 <= 1 ? colOffset <= 1 : colOffset >= 1; _ref2 <= 1 ? colOffset++ : colOffset--) {
          if (!(rowOffset === 0 && colOffset === 0)) {
            otherRow = row + rowOffset;
            otherCol = col + colOffset;
            this.neighbours[otherRow + ',' + otherCol] = {
              row: otherRow,
              col: otherCol
            };
          }
        }
      }
      this.add(row, col);
    }
    Cloister.prototype.add = function(row, col) {
      this.tiles[row + "," + col] = true;
      this.size += 1;
      if (this.size === 9) {
        return this.finished = true;
      }
    };
    Cloister.prototype.toString = function() {
      var address, out;
      out = "Cloister: (";
      for (address in this.tiles) {
        out += "" + address + "; ";
      }
      return out.slice(0, -2) + ("), size: " + this.size + ", finished: " + this.finished);
    };
    return Cloister;
  })();
  Farm = (function() {
    function Farm(row, col, edge, id) {
      this.tiles = {};
      this.ids = {};
      this.edges = {};
      this.size = 0;
      this.score = 0;
      this.add(row, col, edge, id);
    }
    Farm.prototype.add = function(row, col, edge, id) {
      var address;
      address = "" + row + "," + col;
      if (!this.tiles[address]) {
        this.tiles[address] = id;
        this.size += 1;
      }
      this.ids[address + ("," + id)] = true;
      return this.edges[address + ("," + edge)] = {
        row: row,
        col: col,
        edge: edge,
        id: id
      };
    };
    Farm.prototype.has = function(row, col, id) {
      return this.ids["" + row + "," + col + "," + id];
    };
    Farm.prototype.merge = function(other) {
      var e, edge, _ref, _results;
      _ref = other.edges;
      _results = [];
      for (e in _ref) {
        edge = _ref[e];
        _results.push(this.add(edge.row, edge.col, edge.edge, edge.id));
      }
      return _results;
    };
    Farm.prototype.calculateScore = function(cities) {
      var added, city, fields, tile, _i, _len, _results;
      if (this.score > 0) {
        throw "Score already calculated";
      }
      _results = [];
      for (_i = 0, _len = cities.length; _i < _len; _i++) {
        city = cities[_i];
        _results.push((function() {
          var _ref, _ref2, _results2;
          if (city.finished) {
            added = false;
            _ref = city.tiles;
            _results2 = [];
            for (tile in _ref) {
              fields = _ref[tile];
              _results2.push(!added && (_ref2 = this.tiles[tile], __indexOf.call(fields, _ref2) >= 0) ? (added = true, this.score += 3) : void 0);
            }
            return _results2;
          }
        }).call(this));
      }
      return _results;
    };
    Farm.prototype.toString = function() {
      var address, out;
      out = "Farm: (";
      for (address in this.tiles) {
        out += "" + address + "; ";
      }
      return out.slice(0, -2) + ("), size: " + this.size + ", score: " + this.score);
    };
    return Farm;
  })();
  World = (function() {
    function World() {
      var i;
      this.tiles = this.generateRandomTileSet();
      this.center = this.minrow = this.maxrow = this.mincol = this.maxcol = this.tiles.length;
      this.maxSize = this.center * 2;
      this.cloisters = [];
      this.cities = [];
      this.roads = [];
      this.farms = [];
      this.board = (function() {
        var _ref, _results;
        _results = [];
        for (i = 1, _ref = this.maxSize; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(new Array(this.maxSize));
        }
        return _results;
      }).call(this);
      this.placeTile(this.center, this.center, this.tiles.shift(), []);
    }
    World.prototype.generateRandomTileSet = function() {
      var city, cityFields, count, east, edge, edgeDefs, edges, grass, hasPennant, hasRoadEnd, hasTwoCities, i, image, isCloister, isStart, north, regExp, road, roadEdgeCount, south, tile, tileDef, tileDefinitions, tileSets, tiles, west, _ref;
      edgeDefs = {
        'r': 'road',
        'g': 'grass',
        'c': 'city'
      };
      tileDefinitions = ['city1rwe.png   1   start crgr    -1-1    1---    --122221    --    1', 'city1.png      5   reg   cggg    ----    1---    --111111    --    1', 'city1rse.png   3   reg   crrg    -11-    1---    --122111    --    1', 'city1rsw.png   3   reg   cgrr    --11    1---    --111221    --    1', 'city1rswe.png  3   reg   crrr    -123    1---    --122331    --    1', 'city1rwe.png   3   reg   crgr    -1-1    1---    --122221    --    1', 'city2nw.png    3   reg   cggc    ----    1--1    --1111--    --    1', 'city2nwq.png   2   reg   cggc    ----    1--1    --1111--    --    1', 'city2nwqr.png  2   reg   crrc    -11-    1--1    --1221--    --    1', 'city2nwr.png   3   reg   crrc    -11-    1--1    --1221--    --    1', 'city2we.png    1   reg   gcgc    ----    -1-1    11--22--    --   12', 'city2weq.png   2   reg   gcgc    ----    -1-1    11--22--    --   12', 'city3.png      3   reg   ccgc    ----    11-1    ----11--    --    1', 'city3q.png     1   reg   ccgc    ----    11-1    ----11--    --    1', 'city3qr.png    2   reg   ccrc    --1-    11-1    ----12--    --   12', 'city3r.png     1   reg   ccrc    --1-    11-1    ----12--    --   12', 'city4q.png     1   reg   cccc    ----    1111    --------    --    -', 'city11ne.png   2   reg   ccgg    ----    12--    ----1111    11    1', 'city11we.png   3   reg   gcgc    ----    -1-2    11--11--    11    1', 'cloister.png   4   reg   gggg    ----    ----    11111111    --    -', 'cloisterr.png  2   reg   ggrg    --1-    ----    11111111    --    -', 'road2ns.png    8   reg   rgrg    1-1-    ----    12222111    --    -', 'road2sw.png    9   reg   ggrr    --11    ----    11111221    --    -', 'road3.png      4   reg   grrr    -123    ----    11122331    --    -', 'road4.png      1   reg   rrrr    1234    ----    12233441    --    -'];
      tileSets = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = tileDefinitions.length; _i < _len; _i++) {
          tileDef = tileDefinitions[_i];
          regExp = RegExp(' +', 'g');
          tile = tileDef.replace(regExp, ' ').split(' ');
          count = tile[1];
          image = tile[0];
          isStart = tile[2] === 'start';
          hasTwoCities = tile[7] === '11';
          hasPennant = __indexOf.call(image, 'q') >= 0;
          cityFields = tile[8].split('');
          isCloister = image.indexOf("cloister") >= 0;
          edges = tile[3].split('');
          road = tile[4].split('');
          city = tile[5].split('');
          grass = tile[6].split('');
          roadEdgeCount = ((function() {
            var _j, _len2, _results2;
            _results2 = [];
            for (_j = 0, _len2 = edges.length; _j < _len2; _j++) {
              edge = edges[_j];
              if (edge === 'r') {
                _results2.push(edge);
              }
            }
            return _results2;
          })()).length;
          hasRoadEnd = roadEdgeCount === 1 || roadEdgeCount === 3 || roadEdgeCount === 4;
          north = new Edge(edgeDefs[edges[0]], road[0], city[0], grass[0], grass[1]);
          east = new Edge(edgeDefs[edges[1]], road[1], city[1], grass[2], grass[3]);
          south = new Edge(edgeDefs[edges[2]], road[2], city[2], grass[4], grass[5]);
          west = new Edge(edgeDefs[edges[3]], road[3], city[3], grass[6], grass[7]);
          _results.push((function() {
            var _results2;
            _results2 = [];
            for (i = 1; 1 <= count ? i <= count : i >= count; 1 <= count ? i++ : i--) {
              _results2.push(new Tile(image, north, east, south, west, hasTwoCities, hasRoadEnd, hasPennant, cityFields, isCloister, isStart));
            }
            return _results2;
          })());
        }
        return _results;
      })();
      tiles = (_ref = []).concat.apply(_ref, tileSets);
      return [tiles[0]].concat(_(tiles.slice(1, (tiles.length + 1) || 9e9)).sortBy(function() {
        return Math.random();
      }));
    };
    World.prototype.findValidPositions = function(tile) {
      var candidate, candidates, col, i, invalids, other, otherCol, otherRow, row, side, sortedCandidates, turns, valids, _i, _len, _ref, _ref2, _ref3, _ref4, _ref5;
      candidates = [];
      for (row = _ref = this.minrow - 1, _ref2 = this.maxrow + 1; _ref <= _ref2 ? row <= _ref2 : row >= _ref2; _ref <= _ref2 ? row++ : row--) {
        for (col = _ref3 = this.mincol - 1, _ref4 = this.maxcol + 1; _ref3 <= _ref4 ? col <= _ref4 : col >= _ref4; _ref3 <= _ref4 ? col++ : col--) {
          if (!(this.board[row][col] != null)) {
            for (turns = 0; turns <= 3; turns++) {
              tile.rotate(turns);
              valids = [];
              invalids = 0;
              for (side in adjacents) {
                _ref5 = offset(side, row, col), otherRow = _ref5[0], otherCol = _ref5[1];
                if ((0 <= otherRow && otherRow < this.maxSize) && (0 <= otherCol && otherCol < this.maxSize)) {
                  other = this.board[otherRow][otherCol];
                  if (other != null) {
                    if (tile.connectableTo(side, other)) {
                      valids.push(side);
                    } else {
                      invalids++;
                    }
                  }
                }
              }
              if (valids.length > 0 && invalids === 0) {
                candidates.push([row, col, turns, valids]);
              }
              tile.reset();
            }
          }
        }
      }
      sortedCandidates = (function() {
        var _results;
        _results = [];
        for (i = 0; i <= 3; i++) {
          _results.push(new Array());
        }
        return _results;
      })();
      for (_i = 0, _len = candidates.length; _i < _len; _i++) {
        candidate = candidates[_i];
        sortedCandidates[candidate[2]].push(candidate);
      }
      return sortedCandidates;
    };
    World.prototype.randomlyPlaceTile = function(tile, candidates) {
      var candidate, col, i, index, j, neighbours, row, subcandidates, turns, _i, _len, _ref, _ref2;
      candidates = (_ref = []).concat.apply(_ref, candidates);
      if (candidates.length > 0) {
        subcandidates = (function() {
          var _results;
          _results = [];
          for (i = 0; i <= 4; i++) {
            _results.push(new Array());
          }
          return _results;
        })();
        for (_i = 0, _len = candidates.length; _i < _len; _i++) {
          candidate = candidates[_i];
          subcandidates[candidate[3].length].push(candidate);
        }
        index = 0;
        for (i = 0; i <= 4; i++) {
          if (subcandidates[i].length > 0) {
            index = i;
          }
        }
        j = Math.round(Math.random() * (subcandidates[index].length - 1));
        _ref2 = subcandidates[index][j], row = _ref2[0], col = _ref2[1], turns = _ref2[2], neighbours = _ref2[3];
        if (turns > 0) {
          tile.rotate(turns);
        }
        return this.placeTile(row, col, tile, neighbours);
      }
    };
    World.prototype.drawBoard = function() {
      var col, row, table, tbody, td, tile, tr, _ref, _ref2, _ref3, _ref4;
      table = $("<table><tbody></tbody></table>");
      tbody = table.find("tbody");
      for (row = _ref = this.minrow - 1, _ref2 = this.maxrow + 1; _ref <= _ref2 ? row <= _ref2 : row >= _ref2; _ref <= _ref2 ? row++ : row--) {
        tr = $("<tr row='" + row + "'></tr>");
        for (col = _ref3 = this.mincol - 1, _ref4 = this.maxcol + 1; _ref3 <= _ref4 ? col <= _ref4 : col >= _ref4; _ref3 <= _ref4 ? col++ : col--) {
          if ((0 <= row && row < this.maxSize) && (0 <= col && col < this.maxSize)) {
            td = $("<td row='" + row + "' col='" + col + "'></td>");
            tile = this.board[row][col];
            if (tile != null) {
              td = $(("<td row='" + row + "' col='" + col + "'>") + ("<img src='/images/" + tile.image + "' class='" + tile.rotationClass + "'/></td>"));
              if (tile.isStart) {
                td.attr('class', 'debug');
              }
            }
            tr.append(td);
          }
        }
        tbody.append(tr);
      }
      return $("#board").empty().append(table);
    };
    World.prototype.drawCandidates = function(tile, candidates) {
      var actives, attach, candidate, col, disableAll, neighbours, row, turns;
      $('#candidate').attr('src', "/images/" + tile.image).attr('class', tile.rotationClass);
      disableAll = function() {
        var item, _i, _len;
        for (_i = 0, _len = actives.length; _i < _len; _i++) {
          item = actives[_i];
          item.attr('class', '').unbind();
        }
        $('#left').unbind().attr('disabled', 'disabled');
        $('#right').unbind().attr('disabled', 'disabled');
        return $('#next').unbind().attr('disabled', 'disabled');
      };
      attach = __bind(function(cell, row, col, neighbours) {
        return cell.unbind().click(__bind(function() {
          var area, i, j, map, name, num, size, x, xp, y, yp;
          disableAll();
          this.placeTile(row, col, tile, neighbours);
          this.drawBoard();
          map = $("<map name='clicky' id='clicky'></map>");
          num = 5;
          size = 90 / num;
          for (i = 0; 0 <= num ? i < num : i > num; 0 <= num ? i++ : i--) {
            for (j = 0; 0 <= num ? j < num : j > num; 0 <= num ? j++ : j--) {
              x = j * size;
              xp = x + size;
              y = i * size;
              yp = y + size;
              name = (i * num) + j;
              area = $("<area name='" + name + "' shape='rect' coords='" + x + "," + y + "," + xp + "," + yp + "'/>");
              area.click((function(name) {
                return function() {
                  return console.log(name);
                };
              })(name));
              map.append(area);
            }
          }
          $('#board').append(map);
          $("td[row=" + row + "][col=" + col + "]").find('img').attr('usemap', 'clicky');
          return $('#next').click(__bind(function() {
            map.remove();
            $("td[row=" + row + "][col=" + col + "]").find('img').attr('usemap', '');
            $('#next').unbind().attr('disabled', 'disabled');
            this.tiles.shift();
            return this.next();
          }, this)).attr('disabled', '');
        }, this)).attr('class', 'candidate');
      }, this);
      actives = (function() {
        var _i, _len, _ref, _results;
        _ref = candidates[tile.rotation];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          candidate = _ref[_i];
          row = candidate[0], col = candidate[1], turns = candidate[2], neighbours = candidate[3];
          _results.push(attach($("td[row=" + row + "][col=" + col + "]"), row, col, neighbours));
        }
        return _results;
      })();
      $('#left').unbind().click(__bind(function() {
        disableAll();
        tile.rotate(-1);
        return this.drawCandidates(tile, candidates);
      }, this)).attr('disabled', '');
      return $('#right').unbind().click(__bind(function() {
        disableAll();
        tile.rotate(1);
        return this.drawCandidates(tile, candidates);
      }, this)).attr('disabled', '');
    };
    World.prototype.next = function() {
      var candidates, farm, tile, _i, _len, _ref, _results;
      if (this.tiles.length > 0) {
        tile = this.tiles[0];
        candidates = this.findValidPositions(tile);
        return this.drawCandidates(tile, candidates);
      } else {
        $('#candidate').attr('style', 'visibility: hidden');
        $('#left').unbind().attr('disabled', 'disabled');
        $('#right').unbind().attr('disabled', 'disabled');
        _ref = this.farms;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          farm = _ref[_i];
          _results.push(farm.calculateScore(this.cities));
        }
        return _results;
      }
    };
    World.prototype.placeTile = function(row, col, tile, neighbours) {
      var added, cities, city, cloister, dir, edge, farm, farms, handled, n, neighbour, otherCol, otherEdge, otherFarm, otherRow, otherTile, road, roads, seen, _i, _j, _k, _l, _len, _len10, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref10, _ref11, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _results;
      if (neighbours.length === 0 && !tile.isStart) {
        throw "Invalid tile placement";
      }
      this.board[row][col] = tile;
      this.maxrow = Math.max(this.maxrow, row);
      this.minrow = Math.min(this.minrow, row);
      this.maxcol = Math.max(this.maxcol, col);
      this.mincol = Math.min(this.mincol, col);
      if (tile.isCloister) {
        cloister = new Cloister(row, col);
        _ref = cloister.neighbours;
        for (n in _ref) {
          neighbour = _ref[n];
          if ((0 <= (_ref2 = neighbour.row) && _ref2 < this.maxSize) && (0 <= (_ref3 = neighbour.col) && _ref3 < this.maxSize)) {
            if (this.board[neighbour.row][neighbour.col] != null) {
              cloister.add(neighbour.row, neighbour.col);
            }
          }
        }
        this.cloisters.push(cloister);
      }
      _ref4 = this.cloisters;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        cloister = _ref4[_i];
        if (cloister.neighbours[row + "," + col]) {
          cloister.add(row, col);
        }
      }
      handled = {
        north: false,
        south: false,
        east: false,
        west: false
      };
      farms = [];
      roads = [];
      cities = [];
      for (_j = 0, _len2 = neighbours.length; _j < _len2; _j++) {
        dir = neighbours[_j];
        edge = tile.edges[dir];
        _ref5 = offset(dir, row, col), otherRow = _ref5[0], otherCol = _ref5[1];
        otherTile = this.board[otherRow][otherCol];
        otherEdge = otherTile.edges[oppositeDirection[dir]];
        added = false;
        if (edge.grassA !== '-') {
          _ref6 = this.farms;
          for (_k = 0, _len3 = _ref6.length; _k < _len3; _k++) {
            farm = _ref6[_k];
            if (!added && farm.has(otherRow, otherCol, otherEdge.grassB)) {
              if (farms.length > 0) {
                for (_l = 0, _len4 = farms.length; _l < _len4; _l++) {
                  otherFarm = farms[_l];
                  if (!added && otherFarm.has(row, col, edge.grassA)) {
                    if (otherFarm !== farm) {
                      otherFarm.add(row, col, dir, edge.grassA);
                      otherFarm.merge(farm);
                      this.farms.remove(farm);
                      added = true;
                    }
                  }
                }
              }
              if (!added) {
                farm.add(row, col, dir, edge.grassA);
                farms.push(farm);
                added = true;
              }
            }
          }
        }
        added = false;
        if (edge.grassB !== '-') {
          _ref7 = this.farms;
          for (_m = 0, _len5 = _ref7.length; _m < _len5; _m++) {
            farm = _ref7[_m];
            if (!added && farm.has(otherRow, otherCol, otherEdge.grassA)) {
              if (farms.length > 0) {
                for (_n = 0, _len6 = farms.length; _n < _len6; _n++) {
                  otherFarm = farms[_n];
                  if (!added && otherFarm.has(row, col, edge.grassB)) {
                    if (otherFarm !== farm) {
                      otherFarm.add(row, col, dir, edge.grassB);
                      otherFarm.merge(farm);
                      this.farms.remove(farm);
                      added = true;
                    }
                  }
                }
              }
              if (!added) {
                farm.add(row, col, dir, edge.grassB);
                farms.push(farm);
                added = true;
              }
            }
          }
        }
        added = false;
        if (edge.type === 'road') {
          if (!tile.hasRoadEnd && roads.length > 0) {
            _ref8 = this.roads;
            for (_o = 0, _len7 = _ref8.length; _o < _len7; _o++) {
              road = _ref8[_o];
              if (!added && road.has(otherRow, otherCol, otherEdge.road)) {
                if (roads[0] === road) {
                  road.finished = true;
                  added = true;
                } else {
                  roads[0].merge(road);
                  this.roads.remove(road);
                  added = true;
                }
              }
            }
          } else {
            _ref9 = this.roads;
            for (_p = 0, _len8 = _ref9.length; _p < _len8; _p++) {
              road = _ref9[_p];
              if (!added && road.has(otherRow, otherCol, otherEdge.road)) {
                road.add(row, col, dir, edge.road, tile.hasRoadEnd);
                roads.push(road);
                added = true;
              }
            }
          }
        } else if (edge.type === 'city') {
          if (!tile.hasTwoCities && cities.length > 0) {
            _ref10 = this.cities;
            for (_q = 0, _len9 = _ref10.length; _q < _len9; _q++) {
              city = _ref10[_q];
              if (!added && city.has(otherRow, otherCol, otherEdge.city)) {
                city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant);
                added = true;
                if (cities[0] !== city) {
                  cities[0].merge(city);
                  this.cities.remove(city);
                }
              }
            }
          } else {
            _ref11 = this.cities;
            for (_r = 0, _len10 = _ref11.length; _r < _len10; _r++) {
              city = _ref11[_r];
              if (!added && city.has(otherRow, otherCol, otherEdge.city)) {
                city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant);
                cities.push(city);
                added = true;
              }
            }
          }
        }
        handled[dir] = true;
      }
      _results = [];
      for (dir in handled) {
        seen = handled[dir];
        _results.push((function() {
          var _len11, _len12, _len13, _len14, _ref12, _ref13, _ref14, _ref15, _s, _t, _u, _v;
          if (!seen) {
            edge = tile.edges[dir];
            added = false;
            if (edge.grassA !== '-') {
              _ref12 = this.farms;
              for (_s = 0, _len11 = _ref12.length; _s < _len11; _s++) {
                farm = _ref12[_s];
                if (!added && farm.has(row, col, edge.grassA)) {
                  farm.add(row, col, dir, edge.grassA);
                  added = true;
                }
              }
              if (!added) {
                this.farms.push(new Farm(row, col, dir, edge.grassA));
              }
            }
            added = false;
            if (edge.grassB !== '-') {
              _ref13 = this.farms;
              for (_t = 0, _len12 = _ref13.length; _t < _len12; _t++) {
                farm = _ref13[_t];
                if (!added && farm.has(row, col, edge.grassB)) {
                  farm.add(row, col, dir, edge.grassB);
                  added = true;
                }
              }
              if (!added) {
                this.farms.push(new Farm(row, col, dir, edge.grassB));
              }
            }
            added = false;
            if (edge.type === 'road') {
              _ref14 = this.roads;
              for (_u = 0, _len13 = _ref14.length; _u < _len13; _u++) {
                road = _ref14[_u];
                if (!added && road.has(row, col, edge.road)) {
                  road.add(row, col, dir, edge.road, tile.hasRoadEnd);
                  added = true;
                }
              }
              if (!added) {
                return this.roads.push(new Road(row, col, dir, edge.road, tile.hasRoadEnd));
              }
            } else if (edge.type === 'city') {
              _ref15 = this.cities;
              for (_v = 0, _len14 = _ref15.length; _v < _len14; _v++) {
                city = _ref15[_v];
                if (!added && city.has(row, col, edge.city)) {
                  city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant);
                  added = true;
                }
              }
              if (!added) {
                return this.cities.push(new City(row, col, dir, edge.city, tile.cityFields, tile.hasPennant));
              }
            }
          }
        }).call(this));
      }
      return _results;
    };
    return World;
  })();
  print_features = function(all) {
    var city, cloister, farm, road, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2, _ref3, _ref4, _results;
    console.log('------------------------------------------');
    _ref = world.cloisters;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cloister = _ref[_i];
      if (all || cloister.finished) {
        console.log(cloister.toString());
      }
    }
    _ref2 = world.cities;
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      city = _ref2[_j];
      if (all || city.finished) {
        console.log(city.toString());
      }
    }
    _ref3 = world.roads;
    for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
      road = _ref3[_k];
      if (all || road.finished) {
        console.log(road.toString());
      }
    }
    _ref4 = world.farms;
    _results = [];
    for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
      farm = _ref4[_l];
      _results.push(console.log(farm.toString()));
    }
    return _results;
  };
  $(function() {
    var world;
    world = new World();
    world.drawBoard();
    world.next();
    $('#features_all').click(function() {
      return print_features(true);
    });
    $('#features_completed').click(function() {
      return print_features(false);
    });
    $('#features_farms').click(function() {
      var farm, _i, _len, _ref, _results;
      console.log('------------------------------------------');
      _ref = world.farms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        farm = _ref[_i];
        _results.push(console.log(farm.toString()));
      }
      return _results;
    });
    $('#go').click(function() {
      var farm, tile, _i, _j, _len, _len2, _ref, _ref2;
      $('.candidate').unbind().attr('class', '');
      _ref = world.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tile = _ref[_i];
        world.randomlyPlaceTile(tile, world.findValidPositions(tile));
      }
      world.tiles = [];
      $('#candidate').attr('style', 'visibility: hidden');
      $('#left').unbind().attr('disabled', 'disabled');
      $('#right').unbind().attr('disabled', 'disabled');
      $('#go').unbind().attr('disabled', 'disabled');
      $('#step').unbind().attr('disabled', 'disabled');
      _ref2 = world.farms;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        farm = _ref2[_j];
        farm.calculateScore(world.cities);
      }
      return world.drawBoard();
    });
    return $('#step').click(function() {
      var tile;
      $('.candidate').unbind().attr('class', '');
      tile = world.tiles.shift();
      world.randomlyPlaceTile(tile, world.findValidPositions(tile));
      world.drawBoard();
      world.next();
      print_features(true);
      if (world.tiles.length === 0) {
        $('#go').unbind().attr('disabled', 'disabled');
        return $('#step').unbind().attr('disabled', 'disabled');
      }
    });
  });
}).call(this);
