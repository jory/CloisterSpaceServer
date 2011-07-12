(function() {
  var City, Cloister, Farm, Road, Tile, World, adjacents, empty, offset, oppositeDirection;
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
  empty = function(obj) {
    return !(obj != null);
  };
  Tile = (function() {
    function Tile(tile, id) {
      this.id = id != null ? id : null;
      this.image = tile.image;
      this.hasTwoCities = tile.hasTwoCities;
      this.hasRoadEnd = tile.hasRoadEnd;
      this.hasPennant = tile.hasPennant;
      this.citysFields = tile.citysFields;
      this.isCloister = tile.isCloister;
      this.isStart = tile.isStart;
      this.edges = {
        north: tile.northEdge,
        east: tile.eastEdge,
        south: tile.southEdge,
        west: tile.westEdge
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
      return this.edges[from].kind === other.edges[oppositeDirection[from]].kind;
    };
    return Tile;
  })();
  Road = (function() {
    function Road(row, col, edge, num, hasEnd) {
      this.tiles = {};
      this.nums = {};
      this.edges = {};
      this.length = 0;
      this.numEnds = 0;
      this.finished = false;
      this.add(row, col, edge, num, hasEnd);
    }
    Road.prototype.add = function(row, col, edge, num, hasEnd) {
      var address;
      address = "" + row + "," + col;
      if (!this.tiles[address]) {
        this.length += 1;
        this.tiles[address] = true;
      }
      this.nums[address + ("," + num)] = true;
      this.edges[address + ("," + edge)] = {
        row: row,
        col: col,
        edge: edge,
        num: num,
        hasEnd: hasEnd
      };
      if (hasEnd) {
        this.numEnds += 1;
        if (this.numEnds === 2) {
          return this.finished = true;
        }
      }
    };
    Road.prototype.has = function(row, col, num) {
      return this.nums["" + row + "," + col + "," + num];
    };
    Road.prototype.merge = function(other) {
      var e, edge, _ref, _results;
      _ref = other.edges;
      _results = [];
      for (e in _ref) {
        edge = _ref[e];
        _results.push(this.add(edge.row, edge.col, edge.edge, edge.num, edge.hasEnd));
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
    function City(row, col, edge, id, citysFields, hasPennant) {
      this.tiles = {};
      this.ids = {};
      this.edges = {};
      this.openEdges = [];
      this.size = 0;
      this.numPennants = 0;
      this.finished = false;
      this.add(row, col, edge, id, citysFields, hasPennant);
    }
    City.prototype.add = function(row, col, edge, id, citysFields, hasPennant) {
      var address, otherAddress, otherCol, otherRow, _ref;
      address = "" + row + "," + col;
      if (empty(this.tiles[address])) {
        this.tiles[address] = citysFields;
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
      var getEdges, getTiles, haveEdges, haveTiles, i, setupBoard;
      this.center = parseInt($('#num_tiles').html());
      this.maxSize = this.center * 2;
      this.origin = window.location.origin;
      this.game_id = $('#game_id').html();
      this.timeout = 1;
      this.edges = {};
      haveEdges = false;
      this.tiles = {};
      haveTiles = false;
      this.finished = false;
      this.minrow = this.maxrow = this.mincol = this.maxcol = this.center;
      this.board = (function() {
        var _ref, _results;
        _results = [];
        for (i = 1, _ref = this.maxSize; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(new Array(this.maxSize));
        }
        return _results;
      }).call(this);
      this.cloisters = [];
      this.cities = [];
      this.roads = [];
      this.farms = [];
      this.currentTile = null;
      this.candidates = [];
      getEdges = __bind(function() {
        return $.getJSON("" + this.origin + "/edges.json", __bind(function(data) {
          var edge, obj, _i, _len;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            obj = data[_i];
            edge = obj.edge;
            this.edges[edge.id] = edge;
          }
          return haveEdges = true;
        }, this));
      }, this);
      getTiles = __bind(function() {
        if (!haveEdges) {
          return setTimeout(getTiles, this.timeout);
        } else {
          return $.getJSON("" + this.origin + "/tiles.json", __bind(function(data) {
            var obj, tile, _i, _len;
            for (_i = 0, _len = data.length; _i < _len; _i++) {
              obj = data[_i];
              tile = obj.tile;
              tile.northEdge = this.edges[tile.northEdge];
              tile.southEdge = this.edges[tile.southEdge];
              tile.westEdge = this.edges[tile.westEdge];
              tile.eastEdge = this.edges[tile.eastEdge];
              this.tiles[tile.id] = tile;
            }
            return haveTiles = true;
          }, this));
        }
      }, this);
      setupBoard = __bind(function() {
        if (!haveTiles) {
          return setTimeout(setupBoard, this.timeout);
        } else {
          return $.getJSON("" + this.origin + "/tileInstances.json", "game=" + this.game_id + "&status=placed", __bind(function(data) {
            var instance, obj, tile, _i, _len;
            for (_i = 0, _len = data.length; _i < _len; _i++) {
              obj = data[_i];
              instance = obj.tile_instance;
              tile = new Tile(this.tiles[instance.tile_id], instance.id);
              tile.rotate(instance.rotation);
              this.placeTileOnBoard(instance.x, instance.y, tile);
            }
            this.drawBoard();
            return this.next();
          }, this));
        }
      }, this);
      getEdges();
      getTiles();
      setupBoard();
    }
    World.prototype.next = function() {
      if (!this.finished) {
        return $.getJSON("" + this.origin + "/tileInstances/next.json", "game=" + this.game_id, __bind(function(obj) {
          var farm, instance, _i, _len, _ref;
          if (obj != null) {
            instance = obj.tile_instance;
            this.currentTile = new Tile(this.tiles[instance.tile_id], instance.id);
            this.candidates = this.findValidPositions();
            return this.drawCandidates();
          } else {
            this.finished = true;
            _ref = this.farms;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              farm = _ref[_i];
              farm.calculateScore(this.cities);
            }
            $('#candidate > img').attr('style', 'visibility: hidden');
            $('#left').unbind().prop('disabled', 'disabled');
            $('#right').unbind().prop('disabled', 'disabled');
            return $('#step').unbind().prop('disabled', 'disabled');
          }
        }, this));
      }
    };
    World.prototype.findValidPositions = function(tile) {
      var candidate, candidates, col, i, row, sortedCandidates, turns, valid, _i, _len, _ref, _ref2, _ref3, _ref4;
      if (tile == null) {
        tile = this.currentTile;
      }
      candidates = [];
      for (row = _ref = this.minrow - 1, _ref2 = this.maxrow + 1; _ref <= _ref2 ? row <= _ref2 : row >= _ref2; _ref <= _ref2 ? row++ : row--) {
        for (col = _ref3 = this.mincol - 1, _ref4 = this.maxcol + 1; _ref3 <= _ref4 ? col <= _ref4 : col >= _ref4; _ref3 <= _ref4 ? col++ : col--) {
          if (empty(this.board[row][col])) {
            for (turns = 0; turns <= 3; turns++) {
              tile.rotate(turns);
              valid = this.validatePosition(row, col, tile);
              if (valid != null) {
                candidates.push([row, col, turns, valid]);
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
    World.prototype.validatePosition = function(row, col, tile) {
      var invalids, other, otherCol, otherRow, side, valids, _ref;
      valids = [];
      invalids = 0;
      for (side in adjacents) {
        _ref = offset(side, row, col), otherRow = _ref[0], otherCol = _ref[1];
        other = this.getTile(otherRow, otherCol);
        if (other != null) {
          if (tile.connectableTo(side, other)) {
            valids.push(side);
          } else {
            invalids++;
          }
        }
      }
      if (valids.length > 0 && invalids === 0) {
        return valids;
      }
    };
    World.prototype.getTile = function(row, col) {
      if ((0 <= row && row < this.maxSize) && (0 <= col && col < this.maxSize)) {
        return this.board[row][col];
      }
    };
    World.prototype.placeTile = function(row, col, tile, neighbours) {
      if (neighbours.length === 0 && !tile.isStart) {
        throw "Invalid tile placement";
      }
      this.placeTileOnBoard(row, col, tile);
      this.handleCloisters(row, col, tile);
      this.handleFarms(row, col, tile, neighbours);
      this.handleRoads(row, col, tile, neighbours);
      this.handleCities(row, col, tile, neighbours);
      return $.ajax({
        url: "" + this.origin + "/tileInstances/" + tile.id,
        data: "x=" + row + "&y=" + col + "&rotation=" + tile.rotation,
        type: "PUT",
        success: __bind(function() {
          return this.next();
        }, this)
      });
    };
    World.prototype.placeTileOnBoard = function(row, col, tile) {
      this.board[row][col] = tile;
      this.maxrow = Math.max(this.maxrow, row);
      this.minrow = Math.min(this.minrow, row);
      this.maxcol = Math.max(this.maxcol, col);
      return this.mincol = Math.min(this.mincol, col);
    };
    World.prototype.handleCloisters = function(row, col, tile) {
      var cloister, n, neighbour, otherCol, otherRow, _i, _len, _ref, _ref2, _results;
      if (tile.isCloister) {
        cloister = new Cloister(row, col);
        _ref = cloister.neighbours;
        for (n in _ref) {
          neighbour = _ref[n];
          otherRow = neighbour.row;
          otherCol = neighbour.col;
          if (this.getTile(otherRow, otherCol) != null) {
            cloister.add(otherRow, otherCol);
          }
        }
        this.cloisters.push(cloister);
      }
      _ref2 = this.cloisters;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        cloister = _ref2[_i];
        _results.push(cloister.neighbours[row + "," + col] ? cloister.add(row, col) : void 0);
      }
      return _results;
    };
    World.prototype.getOtherEdge = function(dir, row, col) {
      var otherCol, otherRow, _ref;
      _ref = offset(dir, row, col), otherRow = _ref[0], otherCol = _ref[1];
      return [otherRow, otherCol, this.getTile(otherRow, otherCol).edges[oppositeDirection[dir]]];
    };
    World.prototype.handleRoads = function(row, col, tile, neighbours) {
      var added, dir, edge, otherCol, otherEdge, otherRow, road, roads, _i, _j, _len, _len2, _ref, _ref2, _results;
      roads = [];
      for (_i = 0, _len = neighbours.length; _i < _len; _i++) {
        dir = neighbours[_i];
        edge = tile.edges[dir];
        _ref = this.getOtherEdge(dir, row, col), otherRow = _ref[0], otherCol = _ref[1], otherEdge = _ref[2];
        added = false;
        if (edge.kind === 'r') {
          _ref2 = this.roads;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            road = _ref2[_j];
            if (!added && road.has(otherRow, otherCol, otherEdge.road)) {
              if (!tile.hasRoadEnd && roads.length > 0) {
                if (roads[0] === road) {
                  road.finished = true;
                  added = true;
                } else {
                  roads[0].merge(road);
                  this.roads.remove(road);
                  added = true;
                }
              } else {
                road.add(row, col, dir, edge.road, tile.hasRoadEnd);
                roads.push(road);
                added = true;
              }
            }
          }
        }
      }
      _results = [];
      for (dir in adjacents) {
        _results.push((function() {
          var _k, _len3, _ref3;
          if (!(__indexOf.call(neighbours, dir) >= 0)) {
            edge = tile.edges[dir];
            added = false;
            if (edge.kind === 'r') {
              _ref3 = this.roads;
              for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
                road = _ref3[_k];
                if (!added && road.has(row, col, edge.road)) {
                  road.add(row, col, dir, edge.road, tile.hasRoadEnd);
                  added = true;
                }
              }
              if (!added) {
                return this.roads.push(new Road(row, col, dir, edge.road, tile.hasRoadEnd));
              }
            }
          }
        }).call(this));
      }
      return _results;
    };
    World.prototype.handleCities = function(row, col, tile, neighbours) {
      var added, cities, city, dir, edge, otherCol, otherEdge, otherRow, _i, _j, _len, _len2, _ref, _ref2, _results;
      cities = [];
      for (_i = 0, _len = neighbours.length; _i < _len; _i++) {
        dir = neighbours[_i];
        edge = tile.edges[dir];
        _ref = this.getOtherEdge(dir, row, col), otherRow = _ref[0], otherCol = _ref[1], otherEdge = _ref[2];
        added = false;
        if (edge.kind === 'c') {
          _ref2 = this.cities;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            city = _ref2[_j];
            if (!added && city.has(otherRow, otherCol, otherEdge.city)) {
              city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant);
              added = true;
              if (!tile.hasTwoCities && cities.length > 0 && cities[0] !== city) {
                cities[0].merge(city);
                this.cities.remove(city);
              } else {
                cities.push(city);
              }
            }
          }
        }
      }
      _results = [];
      for (dir in adjacents) {
        _results.push((function() {
          var _k, _len3, _ref3;
          if (!(__indexOf.call(neighbours, dir) >= 0)) {
            edge = tile.edges[dir];
            added = false;
            if (edge.kind === 'c') {
              _ref3 = this.cities;
              for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
                city = _ref3[_k];
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
    World.prototype.handleFarms = function(row, col, tile, neighbours) {
      var added, dir, edge, farm, farms, otherCol, otherEdge, otherFarm, otherRow, _i, _j, _k, _l, _len, _len2, _len3, _len4, _len5, _m, _ref, _ref2, _ref3, _results;
      farms = [];
      for (_i = 0, _len = neighbours.length; _i < _len; _i++) {
        dir = neighbours[_i];
        edge = tile.edges[dir];
        _ref = this.getOtherEdge(dir, row, col), otherRow = _ref[0], otherCol = _ref[1], otherEdge = _ref[2];
        added = false;
        if (edge.grassA !== '-') {
          _ref2 = this.farms;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            farm = _ref2[_j];
            if (!added && farm.has(otherRow, otherCol, otherEdge.grassB)) {
              if (farms.length > 0) {
                for (_k = 0, _len3 = farms.length; _k < _len3; _k++) {
                  otherFarm = farms[_k];
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
          _ref3 = this.farms;
          for (_l = 0, _len4 = _ref3.length; _l < _len4; _l++) {
            farm = _ref3[_l];
            if (!added && farm.has(otherRow, otherCol, otherEdge.grassA)) {
              if (farms.length > 0) {
                for (_m = 0, _len5 = farms.length; _m < _len5; _m++) {
                  otherFarm = farms[_m];
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
      }
      _results = [];
      for (dir in adjacents) {
        _results.push((function() {
          var _len6, _len7, _n, _o, _ref4, _ref5;
          if (!(__indexOf.call(neighbours, dir) >= 0)) {
            edge = tile.edges[dir];
            added = false;
            if (edge.grassA !== '-') {
              _ref4 = this.farms;
              for (_n = 0, _len6 = _ref4.length; _n < _len6; _n++) {
                farm = _ref4[_n];
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
              _ref5 = this.farms;
              for (_o = 0, _len7 = _ref5.length; _o < _len7; _o++) {
                farm = _ref5[_o];
                if (!added && farm.has(row, col, edge.grassB)) {
                  farm.add(row, col, dir, edge.grassB);
                  added = true;
                }
              }
              if (!added) {
                return this.farms.push(new Farm(row, col, dir, edge.grassB));
              }
            }
          }
        }).call(this));
      }
      return _results;
    };
    World.prototype.drawCandidates = function(tile, candidates) {
      var actives, attach, candidate, col, disableAll, img, neighbours, row, turns;
      if (tile == null) {
        tile = this.currentTile;
      }
      if (candidates == null) {
        candidates = this.candidates;
      }
      img = $('#candidate > img').attr('src', "/images/" + tile.image);
      img.attr('class', tile.rotationClass).attr('style', '');
      disableAll = function() {
        var item, _i, _len;
        for (_i = 0, _len = actives.length; _i < _len; _i++) {
          item = actives[_i];
          item.prop('class', '').unbind();
        }
        $('#left').unbind().prop('disabled', 'disabled');
        return $('#right').unbind().prop('disabled', 'disabled');
      };
      attach = __bind(function(cell, row, col, neighbours) {
        return cell.unbind().click(__bind(function() {
          disableAll();
          this.placeTile(row, col, tile, neighbours);
          return this.drawBoard();
        }, this)).prop('class', 'candidate');
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
      }, this)).prop('disabled', '');
      return $('#right').unbind().click(__bind(function() {
        disableAll();
        tile.rotate(1);
        return this.drawCandidates(tile, candidates);
      }, this)).prop('disabled', '');
    };
    World.prototype.randomlyPlaceTile = function(tile, candidates) {
      var candidate, col, i, index, j, neighbours, row, subcandidates, turns, _i, _len, _ref, _ref2;
      if (tile == null) {
        tile = this.currentTile;
      }
      if (candidates == null) {
        candidates = this.candidates;
      }
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
            }
            tr.append(td);
          }
        }
        tbody.append(tr);
      }
      return $("#board").empty().append(table);
    };
    return World;
  })();
  $(function() {
    var print_features, world;
    world = new World();
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
    return $('#step').click(function() {
      $('.candidate').unbind().prop('class', '');
      world.randomlyPlaceTile();
      return world.drawBoard();
    });
  });
}).call(this);
