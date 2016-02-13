------------------------------------------------------------------------
--  CONNECTIONS
------------------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2016 Andrew Apted
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
------------------------------------------------------------------------


--class CONN
--[[
    kind : keyword  -- "normal", "teleporter", "secret"

    lock : LOCK

    id : number  -- debugging aid

    -- The two areas are the vital (compulsory) information,
    -- especially for the quest system.  For teleporters the edge
    -- info will be absent (and area info done when pads are placed)

    R1 : source ROOM
    R2 : destination ROOM

    E1 : source EDGE
    E2 : destination EDGE

    A1 : source AREA
    A2 : destination AREA

    F1, F2 : EDGE  -- for "split" connections, the other side

    door_h : floor height for doors straddling the connection

    where1  : usually NIL, otherwise a FLOOR object
    where2  :
--]]


CONN_CLASS = {}


function CONN_CLASS.new(kind, R1, R2, dir)
  local C =
  {
    kind = kind
    id   = alloc_id("conn")
    R1   = R1
    R2   = R2
    dir  = dir
  }

  C.name = string.format("CONN_%d", C.id)

  table.set_class(C, CONN_CLASS)

  table.insert(LEVEL.conns, C)

  return C
end


function CONN_CLASS.kill_it(C)
  table.remove(LEVEL.conns, C)

  C.name = "DEAD_CONN"
  C.kind = "DEAD"
  C.id   = -1

  C.R1  = nil ; C.A1 = nil
  C.R2  = nil ; C.A2 = nil
  C.dir = nil
end


function CONN_CLASS.tostr(C)
  return assert(C.name)
end


function CONN_CLASS.swap(C)
  C.R1, C.R2 = C.R2, C.R1
  C.E1, C.E2 = C.E2, C.E1
  C.F1, C.F2 = C.F2, C.F1
  C.A1, C.A2 = C.A2, C.A1

  -- for split conns, keep E1 on left, F1 on right
  -- [ not strictly necessary, handy for debugging though ]
  if C.F1 then
    C.E1, C.F1 = C.F1, C.E1
    C.E2, C.F2 = C.F2, C.E2
  end
end


function CONN_CLASS.other_area(C, A)
  if A == C.A1 then
    return C.A2
  else
    return C.A1
  end
end


function CONN_CLASS.other_room(C, R)
  if R == C.R1 then
    return C.R2
  else
    return C.R1
  end
end


function CONN_CLASS.set_where(C, R, floor)
  if R == C.R1 then  -- broken
    C.where1 = floor
  else
    C.where2 = floor
  end
end


function CONN_CLASS.get_where(C, R)
  if R == C.R1 then  -- broken
    return C.where1
  else
    return C.where2
  end
end


------------------------------------------------------------------------


function Connect_merge_groups(A1, A2)  -- NOTE : only used for internal conns now
  local gr1 = A1.conn_group
  local gr2 = A2.conn_group

  assert(gr1 and gr2)
  assert(gr1 != gr2)

  if gr1 > gr2 then gr1,gr2 = gr2,gr1 end

  each A in LEVEL.areas do
    if A.conn_group == gr2 then
       A.conn_group = gr1
    end
  end
end



function Connect_through_sprout(P)

--stderrf("Connecting... %s <--> %s\n", P.R1.name, P.R2.name)

  local C = CONN_CLASS.new("normal", P.R1, P.R2)

  table.insert(C.R1.conns, C)
  table.insert(C.R2.conns, C)


  local S1   = P.S
  local long = P.long

  if P.split then long = P.split end


  local E1, E2 = Seed_create_edge_pair(S1, P.dir, long, "nothing")

  E1.kind = "arch"

  C.E1 = E1 ; E1.conn = C
  C.E2 = E2 ; E2.conn = C

  C.A1 = assert(E1.S.area)
  C.A2 = assert(E2.S.area)

--[[
gui.debugf("Creating conn %s from %s --> %s\n", C.name, C.R1.name, C.R2.name)
gui.debugf("  seed %s  dir:%d  long:%d\n", P.S.name, P.dir, P.long)
gui.debugf("  area %s(%s) --> %s(%s)\n", C.A1.name, C.A1.mode, C.A2.name, C.A2.mode)
--]]


  -- handle split connections
  if P.split then
    assert(not S1.diagonal)
    local S2 = S1:raw_neighbor(geom.RIGHT[P.dir], P.long - P.split)
    assert(not S2.diagonal)

    local F1, F2 = Seed_create_edge_pair(S2, P.dir, long, "nothing")

    F1.kind = "arch"

    C.F1 = F1 ; F1.conn = C
    C.F2 = F2 ; F2.conn = C
  end
end



function Connect_teleporters()

  -- FIXME : COMPLETELY BROKEN!!!  FIX FOR 'TRUNKS' FROM GROWER
  
  local function eval_room(R)
    -- never in hallways
    if R.kind == "hallway"   then return -1 end
    if R.kind == "stairwell" then return -1 end

    -- can only have one teleporter per room
    -- TODO : relax this to one per area [ but require a big room ]
    if R:has_teleporter() then return -1 end

    -- score based on size, ignore if too small
    if R.svolume < 10 then return -1 end

    local score = 100

    -- tie breaker
    return score + gui.random()
  end


  local function collect_teleporter_locs()
    local list = {}

    each R in LEVEL.rooms do
      local score = eval_room(R)

      if score > 0 then
        table.insert(list, { R=R, A=rand.pick(R.areas), score=score })
      end
    end

    return list
  end


  local function connect_is_possible(loc1, loc2)
    local A1 = loc1.A
    local A2 = loc2.A

    if A1.room == A2.room then
      return false
    end

-- FIXME
    return (A1.conn_group != A2.conn_group)
  end


  local function add_teleporter(loc1, loc2)
    local A1 = loc1.A
    local A2 = loc2.A

    gui.debugf("Teleporter connection: %s -- >%s\n", A1.name, A2.name)

---##  Connect_merge_groups(A1, A2)

    local C = CONN_CLASS.new("teleporter", A1, A2)

    table.insert(A1.room.conns, C)
    table.insert(A2.room.conns, C)

    -- setup tag information
    C.tele_tag1 = alloc_id("tag")
    C.tele_tag2 = alloc_id("tag")

    table.insert(A1.room.teleporters, C)
    table.insert(A2.room.teleporters, C)
  end


  local function try_add_teleporter()
    local loc_list = collect_teleporter_locs()

    -- sort the list, best score at the front
    table.sort(loc_list, function(A, B) return A.score > B.score end)

    -- need at least a source and a destination
    -- [we try all possible combinations of rooms)

gui.debugf("Teleport locs: %d\n", #loc_list)
    while #loc_list >= 2 do
      local loc1 = table.remove(loc_list, 1)

      -- try to find a room we can connect to
      each loc2 in loc_list do
        if connect_is_possible(loc1, loc2) then
          add_teleporter(loc1, loc2)
          return true
        end
      end
    end

    return false
  end


  ---| Connect_teleporters |---

  -- check if game / theme supports them
  if not PARAM.teleporters or
     OB_CONFIG.mode == "ctf"  -- TODO: support in CTF maps
  then
    gui.printf("Teleporters: not supported\n", quota)
    return
  end

  -- determine number to make
  local skip_prob = style_sel("teleporters", 100, 50, 25, 0)
  local quota     = style_sel("teleporters", 0, 0.5, 1.0, 2.5)

  if rand.odds(skip_prob) then
    gui.printf("Teleporters: skipped by style\n")
    return
  end

  quota = quota * SEED_W / rand.irange(15, 25)

  gui.printf("Teleporters: %d (%1.2f)\n", int(quota), quota)

  for i = 1, quota do
    try_add_teleporter()
  end
end


----------------------------------------------------------------


function Connect_stuff()


  -- this is not used, but may be useful
  local function is_near_another_conn(S, N)
    -- returns 0 for OK, 1 for meh, 2 for OMG

    local near_S = 0
    local near_N = 0

    each dir in geom.ALL_DIRS do
      local S2 = S:neighbor(dir)
      local N2 = N:neighbor(dir)

      if S2 and S2.area == S.area and S2.conn then near_S = near_S + 1 end
      if N2 and N2.area == N.area and N2.conn then near_N = near_N + 1 end
    end

    return math.min(near_S + near_N, 2)
  end


  local function connect_grown_rooms()
    -- turn the preliminary connections into real ones

    each P in LEVEL.prelim_conns do
      Connect_through_sprout(P)
    end
  end


  ---| Connect_stuff |---

  gui.printf("\n---| Connect_stuff |---\n")


  -- TODO Connect_teleporters()

  connect_grown_rooms()
end



function Connect_areas_in_rooms()

  local function check_internally_connected(R)
    each A in R.areas do
      if A.conn_group and A.conn_group != R.canary_area.conn_group then
        return false
      end
    end

    return true
  end


  local function pick_internal_seed(R, A1, A2)
    local DIRS = table.copy(geom.ALL_DIRS)

    if #A1.seeds > #A2.seeds then
      A1, A2 = A2, A1
    end

    local seed_list = rand.shuffle(table.copy(A1.seeds))

    each S in seed_list do
      rand.shuffle(DIRS)

      each dir in DIRS do
        local N = S:neighbor(dir)

        if N and N.area == A2 then
          return S, dir, N
        end
      end
    end

    error("pick_internal_seed failed.")
  end


  local function make_an_internal_connection(R)
    local best_A1
    local best_A2
    local best_score = 0

    each A in R.areas do
    each N in A.neighbors do
      if N.room != R then continue end

      if not A.conn_group then continue end
      if not N.conn_group then continue end

      -- only try each pair ONCE
      if N.id > A.id then continue end

      if A.conn_group != N.conn_group then
        local score = 1 + gui.random()

        if score > best_score then
          best_A1 = A
          best_A2 = N
          best_score = score
        end
      end
    end -- A, N
    end

    if not best_A1 then
      error("Failed to internally connect " .. R.name)
    end

    -- OK --

    local A1 = best_A1
    local A2 = best_A2

    local S, dir = pick_internal_seed(R, A1, A2)

    local AREA_CONN =
    {
      A1 = A1, A2 = A2
      S1 = S,  S2 = S:neighbor(dir)
      dir = dir
    }

    table.insert(R.area_conns, AREA_CONN)

    Connect_merge_groups(A1, A2)
  end


  local function internal_connections(R)
    -- connect the areas inside each room (including hallways)

    R.area_conns = {}

stderrf("internal_connections @ %s\n", R.name)
    each A in R.areas do
stderrf("   %s mode = %s\n", A.name, tostring(A.mode))
      if A.mode == "floor" then
        A.conn_group = assert(A.id)
        R.canary_area = A
      end
    end

    assert(R.canary_area)

    while not check_internally_connected(R) do
      make_an_internal_connection(R)
    end

    if R.sister then
      assert(check_internally_connected(R.sister))
    end
  end


  ---| Connect_areas_in_rooms |---

  each R in LEVEL.rooms do
    if not R.brother then
      internal_connections(R)
    end
  end
end


