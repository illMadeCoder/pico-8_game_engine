pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--[[
  a pico-8 game engine

  mission:
  the purpose of this framework is to provide a suite of useful functions in game development
  and to reduce the intellectual complexity of handling a project such as this through an
  entity component system who will provide a scaffolding in which a game is built on.

  developed by : jesse bergerstock
  email : illmadecoder@gmail.com
  website : http://illmadecoder.com
  github : https://github.com/illmadecoder/pico-8_game_engine

  a unit tested entity based game development framework built to run on the pico-8 client.

  index :
  	1. pico-8 constants & enums
      1.1 buttons
      1.2 colors
      1.3 screen
      1.4 mouse
  	2. global helper routines
      2.1 a zero function
      2.2 maths
      2.3 strings
      2.4 tables
      2.5 drawing
    3. data types
      3.1 rect : a rectangle who is defined by a vector position in space along with a width and a height.
      3.2 vector : a 2d vector composed of an x, and y.
      3.3 sprite : a persistent sprite data structure to be drawn by pico-8.
      3.4 hitbox : a hitbox to be used in a body for the physics module.
      3.5 body : a collection of hitboxes that compose an entity to be used by the physics module.
    4. physics module
    5. a game engine
  	6. an entity component system
    7. pico-8 events
    8. a minimal unit testing suite (used to test this production code)
    
  TODO : 
    1. data types unit tests
    2. modulize game engine from physics engine from entity module
    3. consider and work on g_entity
    4. develop and test a particle module
    5. develop and test an animation type
    6. develop and test a tweening library
     
]]--

--[[
	section header
	1. pico-8 constants & enums
    buttons : relates each keyboard input to its pico-8 numeric.
    colors : relates each supported color to its pico-8 numeric.
    screen : the pico-8 pixel dimensions of height and width.
    mouse : routines who access pico-8's mouse related data.
    pico_memory : a collection of each enumerated category of pico-8 memory's start and end
]]--

buttons = {
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  z = 4,
  x = 5
}

colors = {
  black = 0,
  dark_blue =  1,
  dark_purple = 2,
  dark_green = 3,
  brown = 4,
  dark_gray = 5,
  light_gray = 6,
  white = 7,
  red = 8,
  orange = 9,
  yellow = 10,
  green = 11,
  blue = 12,
  indigo = 13,
  pink = 14,
  peach = 15
}

screen = {
  width = 128,
  height = 128
}

mouse = {
  initialize = function ()
    poke(0x5f2d,1)
  end,
  get_x_coordinate = function ()
    return stat(32)
  end,
  get_y_coordinate = function ()
    return stat(33)
  end,
  get_left_down = function ()
    return stat(34) == 1
  end,
  get_right_down = function ()
    return stat(34) == 2
  end,
  get_middle_down = function ()
    return stat(34) == 4
  end,
}

pico_memory = {
  sprite_sheet = {starts = 0x0, ends = 0x0fff},
  sprite_sheet_share_map = {starts = 0x1000, ends = 0x1fff},
  map = {starts = 0x2000, ends = 0x2fff},
  sprite_flags = {starts = 0x3000, ends = 0x30ff},
  music = {starts = 0x3100, ends = 0x31ff},
  sound_effects = {starts = 0x3200, ends = 0x42ff},
  general_use  = {starts = 0x4300, ends = 0x5dff},
  persistent_cart_data = {starts = 0x5e00, ends = 0x5eff},
  draw_state = {starts = 0x5f00, ends = 0x5f3f},
  hardware_state  = {starts = 0x5f40, ends = 0x5f7f},
  gpio_pins  = {starts = 0x5f80, ends = 0x5fff},
  screen_data  = {starts = 0x6000, ends = 0x7fff}
}

--[[
	section header
	2. global helper routines
    2.1 a zero function : an oddball function who does nothing but fill space.
    2.2 maths : functions who work primarly on numbers.
    2.3 strings : functions who work primarly on strings.
    2.4 tables : functions who work primarly on tables.
    2.5 drawing : abstractions of drawing patterns that come up often.
    2.6 memory : do stuff with the pico-8 memory array
]]--

--[[
  subsection header
  2.1 zero
    empty() -> void
      a function who does nothing and returns nothing.
      use as a paperweight if it comes up rather than having multiple do nothing functions in memory.
]]--

function empty()
end

--[[
  subsection header
  2.2 maths
    ceil(_x : number) -> number
      returns a whole number from a real number _x rounded up.

    sign(_x : number) -> number
      returns the -,+,0 sign associated with _x as -1,1,0 respectively.

    round(_x : number) -> number
      returns a whole number from a real number _x rounded away towards zero when the decimal is < .5 and otherwise away from zero.

    in_range(_x : number, _min : number, _max : number) -> boolean
      returns a boolean that is true when _x is greater than or equal to min and less than or equal to max, otherwise false.

    clamp(_x : number, _min : number, _max : number) -> number
      returns _min when _x is less than _min, returns _max when _x is greater than _max, otherwise returns _x. this effectively limits the range of _x.

    normalize(_x : number, _min : number, _max : number) -> number
      returns a real number between 0 and 1 who acts as a percentage of the distance _x is from _min to _max.
      as in if _min is 0, _max is 100, an _x of 0 would be 0%, an _x of 50 would be 50%, and an _x of 100 would be 100%.

    approx(_a : number, _b : number, _thresh : number) -> boolean
      returns a boolean who is true when _a is close enough to _b such that their difference is 0 or less than the _thresh.

    lerp(_percent : number, _min : number, _max : number) -> number
      lerp stands for linear interperlation and will return a number who falls between _min and _max where _percent specifies a number between 0 and 1.
      the inverse idea of normalize.
      as in if _min is 0, _max is 100, and _percent is .5 the return is 50.
]]--

function ceil(_x)
  return (_x % 1 == 0) and _x or flr(_x)+1
end

function sign(_x)
  return _x > 0 and 1 or _x < 0 and -1 or 0
end

function round(_x)
  if _x % 1 == 0 then
    return _x
  elseif abs(_x) % 1 >= .5 then
    return sign(_x) == 1 and ceil(_x) or flr(_x)
  else
    return sign(_x) == 1 and flr(_x) or ceil(_x)
  end
end

function in_range(_x,_min,_max)
  return _x >= _min and _x <= _max
end

function clamp(_x,_min,_max)
  return _x <= _min and _min or _x >= _max and _max or _x
end

function normalize(_x,_min,_max)
  return clamp( (_x-_min)/(_max-_min), 0, 1)
end

function approx(_a,_b,_thresh)
  return in_range(abs(_a-_b),0,_thresh)
end

function lerp(_percent,_min,_max)
  return clamp((_max-_min)*_percent+_min, _min, _max)
end

--[[
  subsection header
  2.3 strings
    split(_string : string, _split : string) -> array of strings
      returns an array of strings where each element of the array is a substring of _string whom are seperated on each occurance of a string of length 1 _split.

    cut(_string : string, _cut : string) -> string
      returns a string who is _string with each occurance of a string of length 1 _cut removed.
]]--

function split(_string,_split)
  if _string == "" or not _string then
    return {}
  end
  local ret = {}
  local cur = ""
  for i=1,#_string do
    local char = sub(_string,i,i)
    if char == _split then
      add(ret,cur)
      cur = ""
    else
      cur = cur .. char
    end
  end
  add(ret,cur)
  return ret
end

function cut(_string,_cut)
  local ret = ""
  local split = split(_string,_cut)
  for i=1,#split do
    ret = ret .. split[i]
  end
  return ret
end

--[[
  subsection header
  2.4 tables
    stringify_table(_table : table, _tab : number) -> string
      returns a string who is made to resemble the logical structure of the key value pairs associated with _table, and who is willing to move _tab distance through nested tables.

    exists(_search : any, _table : table) -> boolean
      returns a boolean who is true if a value exists in a table.
    
    equal_tables(_a : table, _b : table) -> boolean
      returns whether or not two tables are equal in content with a depth of 1

    concat(_a : table, _b : table) -> table
      without modifying input tables by reference, concat will return a table who is the union of tables _a and _b.

    deep_copy(_table) -> table
      returns a table who has each key value pair _table has but as a new object in memory.
      beware of circular loops where a table nested in _table references _table itself, the deep copy process will never end.
]]--

function stringify_table(_table,_tab)
  local function num_to_tab(_num)
    local ret = ""
    for i=1,_num do
      ret = ret .. "    "
    end
    return ret
  end
  _table = _table or {}
  _tab = _tab or 0
  local ret = "\n" .. num_to_tab(_tab) .. "{\n"
  for k,v in pairs(_table) do
    if type(v) == "function" then
      ret = ret .. num_to_tab(_tab) .. k .. "=" .. k .. "()" .. '\n'
    elseif type(v) == "table" then
      ret = ret .. num_to_tab(_tab) .. k .. "=" .. stringify_table(v,_tab+1) .. '\n'
    elseif type(v) == "boolean" then
      ret = ret .. num_to_tab(_tab) .. k .. "=" .. tostr(v) .. '\n'
    else
      ret = ret .. num_to_tab(_tab) .. k .. "=" .. v .. '\n'
    end
  end
  return ret .. num_to_tab(_tab) .. "}\n"
end

function exists(_search,_table)
  for v in all(_table) do
    if v == _search then
      return true
    end
  end
  for k,v in pairs(_table) do
    if v == _search then
      return true
    end
  end
  return false
end

function equal_tables(_a,_b)
  for k,v in pairs(_a) do
    if _b[k] != v then
      return false
    end
  end
  
  for k,v in pairs(_b) do
    if _a[k] != v then
      return false
    end
  end
  
  for i=1,#_a do
    if _b[i] != _a[i] then
      return false
    end
  end
  
  for i=1,#_b do
    if _a[i] != _b[i] then
      return false
    end
  end
  
  return true
end

function concat(_a,_b)
  local a = deep_copy(_a)
  local b = deep_copy(_b)
  for elem in all(b) do
    add(a,elem)
  end
  for k,v in pairs(b) do
    a[k] = v
  end
  return a
end

function deep_copy(_table)
  local ret = {}
  for k,v in pairs(_table) do
    if type(_table[k]) != "table" then
      ret[k] = _table[k]
    else
      ret[k] = deep_copy(_table[k])
    end
  end
  return ret
end

--[[
  subsection header
  2.5 drawing
    print_center(_str : string, _x : number, _y : number, _col : enum colors) -> void
      draws to the screen a string who's position is offset from x and y such that the center of the text block is x and y.
]]--

--print a string to pico-8 centered at a location
function print_center(_str,_x,_y,_col)
  print(_str,_x+((4-#_str*4)/2),_y,_col)
end

--[[
  subsection header
  2.6 memory
    serialize_screen() -> 128 by 128 array
        serialization of the pico-8 screen into a pico-8 table where each row accounts for 128 cells from 0 to 127 on the pico-8 screen
]]

function serialize_screen()
  local virtual_screen = {}
  local row_count = 128
  local row_size = 64
  for row = 0, row_count-1 do
    virtual_screen[row+1] = {}
    for col = 0, row_size-1 do
      local pixel_pair = peek(pico_memory.screen_data.starts+col+(row*row_size)) 
      virtual_screen[row+1][(col*2)+1] = band(pixel_pair, 0x0f)
      virtual_screen[row+1][(col*2)+2] = shr(band(pixel_pair, 0xf0),4)
    end
    row_string = ""
  end
  return virtual_screen
end

--[[
	section header
	3. data types
    3.1 rect : a rectangle who is defined by a vector position in space along with a width and a height.
    3.2 vector : a 2d vector composed of an x, and y.
    3.3 sprite : a persistent sprite data structure to be drawn by pico-8.
    3.4 hitbox : a hitbox to be used in a body for the physics module.
    3.5 body : a collection of hitboxes that compose an entity to be used by the physics module.
]]--

--[[
  subsection header
  3.1 rect
    g_rect.new(_position : vector, _width : number, _height : number) -> rect
      constructor method to create a table of type rect
    binary operations
      rect + rect -> rect
      rect - rect -> rect
]]--

g_rect = {}

g_rect.metatable = {}

g_rect.metatable.__index = function(_table,_key)
  return g_rect.metatable[_key]
end

g_rect.metatable.__add = function(_rect_a, _rect_b)
  return g_rect.new(_rect_a.position + _rect_b.position, _rect_a.width+_rect_b.width, _rect_a.height+_rect_b.height)
end

g_rect.metatable.__sub = function(_rect_a, _rect_b)
  return g_rect.new(_rect_a.position - _rect_b.position, _rect_a.width-_rect_b.width, _rect_a.height-_rect_b.height)
end

g_rect.new = function(_position,_width,_height)
  local rect = {position=_position,x=_x,y=_y}
  setmetatable(rect,g_rect.metatable)
  return rect
end

--[[
  subsection header
  3.2 {x : number, y : number} : vector
    constructors
      vector.new(_x : number, _y : number) -> vector
        factory method to generate a table of type vector
      vector.from_array(_array : array) -> vector
      vector.copy(_vector : vector) -> vector
      vector.scalar_mult(_vec : vector, _scalar : number) -> vector
      vector.normalize(_vector : vector) -> vector
      vector.scale(_vector_a : vector, _vector_b : vector) -> vector
      vector.inv(_a : vector) -> vector
    binary vector operations
      vector + vector -> vector
      vector - vector -> vector
      vector == vector -> boolean
    methods of mutation
      vector:set(_x : number, _y : number) -> void
      vector:set_to(_self,_other) -> void
      vector:to_whole(_self) -> void
      vector:lerp(_self,_t,_start,_end) -> void
      vector:move_towards(_self,_to,_speed) -> void
    helper functions
      vector.dot(_a : vector, _b : vector) -> number
      vector.magnitude(_vec : vector) -> number
      vector.unit_twards(_from : vector, _to : vector) -> vector
      vector.distance(_veca : vector, _vecb : vector) -> vector
      vector.approx_equal(_a : vector, _b : vector, _thresh : number) -> boolean
    constants
      vector.up
      vector.down
      vector.left
      vector.right
]]--

--2d vector
--represents a position in space given a numerica x,y coordinate.
g_vector = {}
g_vector.metatable = {}
g_vector.metatable.__index = function(_table,_key)
  return g_vector.metatable[_key]
end
--l_operand + r_operand  operation, given a left hand vector and right hand vector, return the numeric addition of each element index pair.
g_vector.metatable.__add = function(_a,_b)
  return g_vector.new(_a.x+_b.x,_a.y+_b.y)
end
--l_operand - r_operand, given a left hand vector and right hand vector, return the numeric subtraction of each element index pair.
g_vector.metatable.__sub = function(_a,_b)
  return g_vector.new(_a.x-_b.x,_a.y-_b.y)
end
--l_operand == r_operand, given a left hand vector and right hand vector, return the numeric equal of each element index pair.
g_vector.metatable.__eq = function(_a,_b)
  return _a.x == _b.x and _a.y == _b.y
end
--a mutator operation on a vector, given a numeric x and y, set the respective vector elements to the x and y.
g_vector.metatable.set = function(_self,_x,_y)
  _self.x,_self.y = _x, _y
end
--a mutator operation on a vector, given another vector, set the respective vector to the other vector's elements respectively.
g_vector.metatable.set_to = function(_self,_other)
  _self:set(_other.x,_other.y)
end
--a mutator operation on a vector, given a vector, round each element to a whole number.
g_vector.metatable.to_whole = function(_self)
  _self:set(round(_self.x),round(_self.y))
end
--a mutator operation on a vector, given a start vector, an end vector, and a percentage distance, mutate the vector over the linear interperlation from start to end.
g_vector.metatable.lerp = function(_self,_t,_start,_end)
  _self:set(lerp(_t,_start.x,_end.x),lerp(_t,_start.y,_end.y))
end
--a mutator operation on a vector, given a vector to move towards, and a speed in pixels to move by, mutate the vector to move closer by speed distance.
g_vector.metatable.move_towards = function(_self,_to,_speed)
  --[[
  --if the vector is close enough that a movement towards it by speed will move to or passed it, move to it.
  --otherwise mutate the vector to be closer to the target vector by determining the unit vector towards the vector * speed.
  --]]
  if g_vector.approx_equal(_self,_to,_speed) then
    _self:set_to(_to)
  else
    _self:set_to(_self + g_vector.scalar_mult(g_vector.unit_towards(_self,_to),_speed))
  end
end
--given an x and y numeric coordinate, return a vector with the appropriate coordinates and metatable.
g_vector.new = function(_x,_y)
  local vector = {x=_x,y=_y}
  setmetatable(vector,g_vector.metatable)
  return vector
end
--construct a vector from an array, [x1,x2] == vector.new(x1,x2)
g_vector.from_array = function(_array)
  return g_vector.new(_array[1],_array[2])
end
--given a vector, return a deep copy of the vector.
g_vector.copy = function(_vector)
  return g_vector.new(_vector.x,_vector.y)
end
--given a vector and a numeric scalar, multiply each element of the vector by the scalar and return the modified vector.
g_vector.scalar_mult = function(_vec,_scalar)
  return g_vector.new(_vec.x*_scalar,_vec.y*_scalar)
end
--given a vector, return a normalized vector who is in the same direction but of a magnitude of 1.
g_vector.normalize = function(_vec)
  return g_vector.new(_vec.x/g_vector.magnitude(_vec),_vec.y/g_vector.magnitude(_vec))
end
--given a vector a and vector b, return a vector whos components are multiplied.
g_vector.scale = function(_veca,_vecb)
  return g_vector.new(_veca.x*_vecb.x,_veca.y*_vecb.y)
end
--given a vector a and a vector b, return the dot product of a * b.
--the dot of two vectors determines the commonality in angle between two vectors where 1 is the same direction, -1 if opposite directions, and 0 if perpendicular.
g_vector.dot = function(_a,_b)
  return _a.x*_b.x+_a.y*_b.y
end
--given a vector, return a vector of the same magnitude and opposite direction.
g_vector.inv = function(_a)
  return g_vector.scalar_mult(_a,-1)
end
--given a vector, return the length of the vector.
g_vector.magnitude = function(_vec)
  return sqrt(_vec.x*_vec.x + _vec.y*_vec.y)
end
--given a vector from, and a vector to, return the vector who's angle is between from and to and is of length 1.
g_vector.unit_towards = function(_from,_to)
  return g_vector.normalize(_to-_from)
end
--given a vector a and vector b, return the length between a and b.
g_vector.distance = function(_veca,_vecb)
  return g_vector.magnitude(_veca-_vecb)
end
--given a vector a and vector b, return whether the distance between them is within the threshold
g_vector.approx_equal = function (_a,_b,_thresh)
  return in_range(abs(g_vector.distance(_a,_b)),0,_thresh)
end
--an enumeration of each cardinal direction a vector can take
g_vector.up = g_vector.new(0,-1)
g_vector.down = g_vector.new(0,1)
g_vector.left = g_vector.new(-1,0)
g_vector.right = g_vector.new(1,0)

--sprite
g_sprite = {}
g_sprite.metatable = {}
g_sprite.metatable.__index = function (_table,_key)
  return g_sprite.metatable[_key]
end
--given a sprite and an entity, draw the g_sprite to the screen relative to the entity's position.
g_sprite.metatable.draw = function (_sprite,_entity)
  spr(_sprite.n,_entity.position.x+_sprite.position.x,_entity.position.y+_sprite.position.y,_sprite.width,_sprite.height,_sprite.flipx,_sprite.flipy)
end
--given a sprite index, a local position vector, a width, a height, a flip over the x axis, and a flip over the y axis, return a new sprite object.
g_sprite.new = function (_n,_position,_width,_height,_flipx,_flipy)
  local sprite = {
    n=_n,
    position=_position,
    width=_width,
    height=_height,
    flipx = flipx or false,
    flipy = flipy or false
  }
  setmetatable(sprite,g_sprite.metatable)
  return sprite
end
--instantiate a new sprite from an array; [n,x,y,width,height,flipx,flipy]
g_sprite.from_array = function (_array)
  return g_sprite.new(_array[1],_array[2],_array[3],_array[4],_array[5],_array[6])
end
--hitbox
g_hitbox = {}
g_hitbox.metatable = {}
g_hitbox.metatable__index = function(_table,_key)
  return g_hitbox.metatable[_key]
end
--given a hitbox and an entity it's attatched to, return its vertices as {x=left, y=top, w=right, z=bottom}
g_hitbox.metatable.border = function(_self,_entity)
  local absolute_position = g_hitbox.world_position(_self,_entity)
  return {x=absolute_position.x,y=absolute_position.y,w=absolute_position.x+_self.width,z=absolute_position.y+_self.height}
end
g_hitbox.world_position = function(_self,_entity)
  return _self.position + _entity.position
end
--given a hitbox and an entity, draw a rect around the hitbox on the screen.
g_hitbox.metatable.draw = function(_self,_entity)
  draw_border(_self:border(),11)
end
--given a vector position, numeric width, numeric height, string name, and boolean enabled, return a hitbox.
g_hitbox.new = function (_position,_width,_height,_name,_enabled)
  local hitbox = {
    position=_position,
    width=_width,
    height=_height,
    name=_name or "hitbox",
    enabled=_enabled or true,
    collisions = {},
  }
  setmetatable(hitbox,g_hitbox.metatable)
  return hitbox
end
--given an array return an object from that array; [position,width,height,name,enabled]
g_hitbox.from_array = function(_array)
  return g_hitbox.new(_array[1],_array[2],_array[3],_array[4],_array[5])
end

--body
g_body = {}
g_body.metatable = {}
g_body.metatable.__index = function(_table,_key)
  return g_body.metatable[_key]
end
--given a body, draw each hitbox in the body
g_body.metatable.draw = function(_self,_entity)
  for hitbox in all(_self.hitboxes) do
    hitbox:draw(_entity)
  end
end
--given a body, get each hitbox collision
g_body.metatable.get_collisions = function(_self)
  local ret = {}
  for hitbox in all(_self.hitboxes) do
    if #hitbox.collision > 0 then
      add(ret,hitbox)
    end
  end
  return ret
end
--given a body, clear each hitbox collision
g_body.metatable.clear_collisions = function(_self)
  for hitbox in all(_self.hitboxes) do
    hitbox.collisions = {}
  end
end
--given a body and a string name, return a each hitbox of the name
g_body.metatable.locate_hitbox = function(_self,_name)
  local ret = {}
  for hitbox in all(_self.hitboxes) do
    if hitbox.name == _name then
      add(ret,hitbox)
    end
  end
  return ret
end
--given a collection of hitboxes and a collision callback, return a new body.
g_body.new = function(_hitboxes,_collision_callback)
  local body = {hitboxes=_hitboxes or {},collision=_collision_callback or empty}
  setmetatable(body,body.metatable)
  return body
end


--[[
  section header
  5. physics
    physics() :

]]--
--2d, rect based physics
--depends on primatives, along with the entity type and therefor body and hitbox datatypes.
g_physics = {}
--given two intervals, a number x1 to a number x2, a number y1 to y2, detect if the range from x1 to x2 falls in the range of y1 to y2
g_physics.interval_intersect = function (_x1,_x2,_y1,_y2)
  return max(_x1,_y1) <= min(_x2,_y2)
end
--given two rects, a location x,y and a width height, determine if one rect falls into the range of the other
g_physics.rect_intersect = function (_x1,_y1,_width1,_height1,_x2,_y2,_width2,_height2)
  return g_physics.interval_intersect(_x1,_x1+_width1,_x2,_x2+_width2) and
  g_physics.interval_intersect(_y1,_y1+_height1,_y2,_y2+_height2)
end
--given two hitboxs and their corresponding entities, return if they intersect in world space
g_physics.hitbox_intersect = function (_hitbox1, _entity1, _hitbox2, _entity2)
  local world_position1, world_position2 = g_hitbox.world_position(_hitbox1,_entity1), g_hitbox.world_position(_hitbox2,_entity2)
  return g_physics.rect_intersect(world_position1.x, world_position1.y, _hitbox1.width, _hitbox1.height, world_position2.x, world_position2.y, _hitbox2.width, _hitbox2.height)
end
--given two entities, detect if their bodies collide in world space, if so
--create collision data object for each relevent hitbox to hold in its collision pool.
g_physics.entity_intersect = function(_entity1, _entity2)
  for hitbox1 in all(_entity1.body.hitboxes) do
    for hitbox2 in all(_entity2.body.hitboxes) do
      if hitbox1.enabled and hitbox2.enabled and g_physics.hitbox_intersect(hitbox1, _entity1, hitbox2, _entity2) then
        _entity1.body.collision(_entity1,_entity2)
        _entity2.body.collision(_entity2,_entity1)
      end
    end
  end
end
--given a rect in world space, return a list of collision data
g_physics.rectcast = function(_rectcast, _entity_pool)
  local collisions = {}
  for entity in all(_entity_pool) do
    for hitbox in all(entity.body.hitboxes) do
      if g_physics.rect_intersect(_rectcast.position.x, _rectcast.position.y, _rectcast.width, _rectcast.height, hitbox.position.x + entity.position.x, hitbox.position.y + entity.position.y, hitbox.width, hitbox.height) then
        add(collisions,entity)
      end
    end
  end
  return collisions
end
--given an entity pool, detect any collisions between a pair of entities and add collision data to their respective bodies.
g_physics.update = function(_entity_pool)
  for i=1,#_entity_pool-1 do
    _entity_pool[i].body:clear_collisions()
    for j=i+1,#_entity_pool do
      g_physics.entity_intersect(_entity_pool[i],_entity_pool[j])
    end
  end
end

--[[
  section header
  6. game engine
]]--
g_game = {}
g_game.metatable = {}
g_game.metatable.__index = function(_table,_key)
  return g_game.metatable[_key]
end
g_game.new = function(_starting_scene)
--given a scene instance, run the scene and return a game.ame.new = function(_starting_scene)
  local game = {
    entity_pool = {},
    camera = {x=0,y=0,w=127,z=127},
    debug_hitboxes = false,
    pause = false,
    sample_rate = 1,
    frame = 0,
    active_scene = _starting_scene
  }
  setmetatable(game,g_game.metatable)
  game.active_scene.starting(game.active_scene.model,game)
  return game
end
--given a game, return the game's numeric frame
g_game.metatable.get_frame = function(_self)
  return _self.frame
end

--given a game, run a routine that updates the entities
--1. update the active scene
--2. detect ollisions and run collision callbacks
--3. update entities
g_game.metatable.update = function(_self)
  local entities = _self:get_entities()
  --update scene
  _self.active_scene.update(_self.active_scene.model,_self)
  _self.active_scene.frame += 1
  if not _self.pause and _self.frame % _self.sample_rate == 0 then
    --update entities
    for entity in all(entities) do
      entity.update(entity,_self)
      entity.frame += 1
    end
    --collision detection
    g_physics.update(entities)
  end
  _self.active_scene.late_update(_self.active_scene.model)
  _self.frame += 1
end

--given a game, run a rendering routine
--1. render the active scene
--2. render the each entity
g_game.metatable.draw = function(_self)
  local entities = _self:get_entities()
  if _self.frame % _self.sample_rate == 0 then
    cls()
    camera(-_self.camera.x,-_self.camera.y)
    _self.active_scene.draw(_self.active_scene.model,_self)
    for entity in all(entities) do
      entity.draw(entity)
      if _self.draw_hitboxes then
        entity.body:draw(entity,_self)
      end
    end
    _self.active_scene.late_draw(_self.active_scene.model,_self)
  end
end

--given a game and a scene, switch the active scene of the game to the new scene
g_game.metatable.switch_scene = function (_self, _scene)
  _self.active_scene.ending(_self.active_scene.model,_self)
  _self.active_scene = _scene
  _self.active_scene.starting(_self.active_scene.model,_self)
end

--given a game and entity, add the entity to the game, return the entity for reuse
g_game.metatable.add_entity = function(_self, _entity)
  if type(_entity) == "table" and _entity.name != nil then
    if _self.entity_pool[_entity.z] == nil then
      for i=#_self.entity_pool,_entity.z do
        _self.entity_pool[i] = {}
      end
    end
    add(_self.entity_pool[_entity.z],_entity)
  end
  return _entity
end

--given a game and entity in the game, remove the entity from the game
g_game.metatable.remove_entity = function(_self, _entity)
  del(_self.entity_pool[_entity.z],_entity)
end

--given a game, remove all entities from that game
g_game.metatable.empty_entities = function(_self)
  _self.entity_pool = {}
end

--given a game, return the entities in the game
g_game.metatable.get_entities = function(_self)
  local ret = {}
  for ent_index in all(_self.entity_pool) do
    concat(ret,ent_index)
  end
  return ret
end

--given a game,
g_game.metatable.rectcast = function(_self,_rect)
  return g_physics.rectcast(_rect,_self:get_entities())
end

--given a game and a tag, return a list of entities who contain the given tag.
g_game.metatable.locate_entity_tag = function(_self, _tag)
  local ret = {}
  local entities = _self:get_entities()
  for entity in all(entities) do
    if exists(_tag,entity.tags) then
      add(ret,entity)
    end
  end
  return ret
end

--given a game and a name, return a list of each entity who has the name.
g_game.metatable.locate_entity_name = function(_self, _name)
  local ret = {}
  local entities = _self:get_entities()
  for entity in all(entities) do
    if entity.name == _name then
      add(ret,entity)
    end
  end
  return ret
end

--[[
  7. entity component system
]]--
--entity
g_entity = {}
g_entity.new = function(_name,_tag,_position,_update,_draw,_body,_model,_z)
  --[[an entity is a data structure meant to be used by the game to create some effect
  --an entity is defined by the following:
  --name is a string to identify the object in memory
  --vector is an object of the vector.new function to provide a spatial vector to the object
  --update is a function to be called each frame
  --draw is a function to be called each render
  --model is a table container for an entity's state
  --z is the z index to be drawn

  --if you want a 'start' function, a function to be called on the first frame of the entity's existense,
  --do a if (entity.frame == 0) check
  --]]
  return {
          name=_name or "entity",
          tag=_tag or {},
          position=_position or g_vector.new(),
          update=_update or empty,
          draw=_draw or empty,
          body=_body or g_body.new(),
          model=_model or {},
          z=_z or 0,
          frame=0
        }
end
--entity data
g_entity_data = {}
g_entity_data.unit = function()
end
--scene
g_scene = {}
g_scene.new = function(_starting,_ending,_update,_draw,_late_update,_late_draw,_model)
--[[
--a scene is a manager for any particular segments of a game and should be used as a tool
--to control game state. each game runs an initial scene, and then from there a scene may
--transition via game.switch_scene(scene) where first the ending function of a scene will be called
--followed then by the new scene's starting() function.
--game.active_scene is the current running scene
]]--
  return {
        starting=_starting or empty,
        ending=_ending or empty,
        update=_update or empty,
        draw=_draw  or empty,
        late_update=_late_update or empty,
        late_draw=_late_draw or empty,
        model=_model or {},
        frame=0
      }
end
--scene data
g_scene_data = {}
g_scene_data.init = g_scene.new()

--[[
  section header
  8. pico-8 events
    _init() :
    _update() :
    _update60() :
    _draw() :
]]--

function _init()
  punit.run()
  this_game = g_game.new(g_scene_data.init)
end
function _update60()
  this_game:update()
end
function _draw()
  this_game:draw()
  if this_game:get_frame() == 5 then
    serialize_screen()
  end
end

--[[
	section header
	8. a minimal unit testing suite (mostly for use of helper routines)
    punit : {
      tests : array of functions() -> void,
        tests is a collection of unit test functions to be ran. (you do this)
      run(self) -> void,
        run iteratively invokes each function in tests and counts the passed/failed tests and which to pico-8 and terminal.
      assert_that(_self, _test_name : string, _assumption : boolean) -> void,
        assert_that is the main tool which each function test in tests will use to report the result of a unit test.
      new_log(test_name : string, status : boolean) -> {test_name : string, status : boolean}
        construct new instances of type log
      logs : [{test_name : string, status : boolean}]
        each assert invocation will log its result as a type log and push it on the logs collection
    }
]]--

punit = {
  tests = {
    --2 global helper routines
    --2.1 zero
    --empty() -> void
    function() 
      punit.assert_that("empty returns nothing", empty() == nil)
    end,
    --2.2 maths
    --ceil(_x : number) -> number
    function() 
      punit.assert_that("ceil at 0 is 0", ceil(0) == 0, ceil(0))
      punit.assert_that("ceil at -.4 is 0", ceil(-.4) == 0, ceil(-.4))
      punit.assert_that("ceil at -.5 is 0", ceil(-0.5)  == 0, ceil(-0.5))
      punit.assert_that("ceil at .4 is 1", ceil(.4) == 1, ceil(.4))
      punit.assert_that("ceil at .5 is 1", ceil(.5) == 1, ceil(.5))
      punit.assert_that("ceil at 1 is 1", ceil(1)  == 1, ceil(1))
    end,
    --sign(_x : number) -> number
    function() 
      punit.assert_that("sign at 0 is 0", sign(0) == 0)
      punit.assert_that("sign at -2 is -1", sign(-2) == -1)
      punit.assert_that("sign at 2 is 1", sign(2) == 1)
    end,
    --round(_x : number) -> number
    function() 
      punit.assert_that("round at 0 is 0", round(0) == 0)
      punit.assert_that("round at .4 is 0", round(.4) == 0)
      punit.assert_that("round at .5 is 1", round(.5) == 1)
      punit.assert_that("round at 1 is 1", round(1) == 1)
      punit.assert_that("round at -.4 is 0", round(-.4) == 0)
      punit.assert_that("round at -.5 is -1", round(-.5) == -1)
      punit.assert_that("round at -1 is -1", round(-1) == -1)
    end,
    --in_range(_x : number, _min : number, _max : number) -> boolean
    function() 
      punit.assert_that("in_range x is mid is true", in_range(0,-2,2))
      punit.assert_that("in_range x is min is true", in_range(-2,-2,2))
      punit.assert_that("in_range x is max is true", in_range(2,-2,2))
      punit.assert_that("in_range x is less than min is false", not in_range(-3,-2,2))
      punit.assert_that("in_range x is greater than max is false", not in_range(3,-2,2))
    end,
    --clamp(_x : number, _min : number, _max : number) -> number
    function() 
      punit.assert_that("clamp x is mid is x", clamp(0,-2,2) == 0)
      punit.assert_that("clamp x is min is min", clamp(-2,-2,2) == -2)
      punit.assert_that("clamp x is max is max", clamp(2,-2,2) == 2)
      punit.assert_that("clamp x is less than min is min", clamp(-3,-2,2) == -2)
      punit.assert_that("clamp x is greater than max is max", clamp(3,-2,2) == 2)
    end,
    --normalize(_x : number, _min : number, _max : number) -> number
    function()
      punit.assert_that("normalize x is min is 0", normalize(-2,-2,2) == 0)
      punit.assert_that("normalize x is max is 1", normalize(2,-2,2) == 1)
      punit.assert_that("normalize x is centered is .5", normalize(0,-2,2) == .5)
      punit.assert_that("normalize x is less than min is 0", normalize(-3,-2,2) == 0)
      punit.assert_that("normalize x is greater than max is 1", normalize(3,-2,2) == 1)
    end,
    --approx(_a : number, _b : number, _thresh : number) -> boolean
    function() 
      punit.assert_that("approx a is b is 0 with a threshold of 0 is true", approx(0,0,0))
      punit.assert_that("approx a is b is -1 with a threshold of 0 is true", approx(-1,-1,0))
      punit.assert_that("approx a is b is 1 with a threshold of 0 is true", approx(1,1,0))
      punit.assert_that("approx a is 0 b is 1 with a threshold of 1 is true", approx(0,1,1))
      punit.assert_that("approx a is -1 b is 0 with a threshold of 1 is true", approx(-1,0,1))
      punit.assert_that("approx a is -1 b is 1 with a threshold of 2 is true", approx(-1,1,2))
      punit.assert_that("approx a is 0 b is .5 with a threshold of .5 is true", approx(0,.5,.5))
      punit.assert_that("approx a is .5 b is -.5 with a threshold of 1 is true", approx(.5,-.5,1))
      punit.assert_that("approx a is 0 b is -1 with a threshold of 0 is false", not approx(0,-1,0))
      punit.assert_that("approx a is 0 b is 1 with a threshhold of .5 is false", not approx(0,1,.5))
    end,
    --lerp(_percent : number, _min : number, _max : number) -> number
    function() 
      punit.assert_that("lerp 0 percent returns min", lerp(0,-1,1) == -1)
      punit.assert_that("lerp .5 percent returns the number between min and max", lerp(.5,-1,1) == 0)
      punit.assert_that("lerp 100 percent returns max", lerp(1,-1,1) == 1)
      punit.assert_that("lerp less than 0 percent returns min", lerp(-1.5,-1,1) == -1)
      punit.assert_that("lerp greater than 100 percent returns max", lerp(1.5,-1,1) == 1)
    end,
    --2.3 strings
    --split(_string : string, _split : string) -> array of strings
    function() 
      punit.assert_that("split an empty string returns an empty array", #split("", "|") == 0)
      local split_to_test = split("1|2|3", "|")
      punit.assert_that("split a populated string returns an array of substrings by its split", #split_to_test == 3  and split_to_test[1] == "1" and split_to_test[2] == "2" and split_to_test[3] == "3")
      split_to_test = split(",,",",")
      punit.assert_that("splits return array of empty strings if there is no characters between split", #split_to_test == 3 and split_to_test[1] == "" and split_to_test[2] == "" and split_to_test[3] == "")
    end,
    --cut(_string : string, _cut : string) -> string
    function() 
      punit.assert_that("cut an empty string return an empty string", cut("",",") == "")
      punit.assert_that("cut a string such that no occurances of the cut exists now", cut("|1|","|") == "1")
      punit.assert_that("cut a string composed entirely of occurances of the string to cut returns an empty string", cut("|||","|") == "")
    end,
    --2.4 tables
    --stringify_table(_table : table, _tab : number) -> string
    function() 
      punit.assert_that("stringify_table with an empty table and 0 tab is \n{\n}\n", stringify_table({},0) == "\n{\n}\n")
    end,
    --exists(_search : any, _table : table) -> boolean
    function()
      punit.assert_that("exists an empty table will return false", not exists(0,{}))
      punit.assert_that("exists an array style table with the value returns true", exists(0,{0}))
      punit.assert_that("exists a dictionary style table with the value returns true", exists(0,{zero=0}))
      punit.assert_that("exists a populated table without the value returns false", not exists(0,{1,2,3}))
    end,
    --equal_tables(_a : table, _b : table) -> boolean
    function()
      punit.assert_that("equal_tables two empty tables are equal", equal_tables({},{}))
      punit.assert_that("equal_tables two populated but same tables are equal", equal_tables({1,2,three=3},{1,2,three=3}))
      punit.assert_that("equal_tables one table is populated one is not so they are not equal left", not equal_tables({1,2,three=3},{}))
      punit.assert_that("equal_tables one table is populated one is not so they are not equal right", not equal_tables({},{1,2,three=3}))
      punit.assert_that("equal_tables both tables are populated but maintain a difference", not equal_tables({1,2,three=2},{1,2,three=3}))
    end,
    --concat(_a : table, _b : table) -> table
    function() 
      punit.assert_that("concat two empty tables returns an empty table", equal_tables(concat({},{}),{}))
      punit.assert_that("concat two empty tables returns an empty table", #concat({},{}) == 0)
    end,
    --deep_copy(_table) -> table
    function() 
      local a = {reference = "1"}
      local a_deep_copy = deep_copy(a)
      a_deep_copy.reference = "2"
      punit.assert_that("deep_copy a reference property will be deep copied", not equal_tables(a,a_deep_copy))
      a = nil
      a_deep_copy = nil

      a = {table = { property = 0 } }
      a_deep_copy = deep_copy(a)
      a_deep_copy.table.property = 1
      punit.assert_that("deep_copy a nested table will be deep copied", not equal_tables(a.table,a_deep_copy.table))
      a = nil
      a_deep_copy = nil
    end,
    --2.5 drawing (not applicable because it depends on the pico-8 system)
    --3 data types
    --3.1 rect
    --rect.new
    function() 
      local a_rect = g_rect.new(g_vector.new(0,0),0,0)
      
      punit.assert_that("rect.new is with 0s is well formed", a_rect.position.x == 0, a_rect.position.y == 0)
    end,
    function()
    end
  },

  run = function() 
    punit.logs = {}

    for test in all(punit.tests) do
      test()
    end

    local total = #punit.logs
    local passed = 0
    local failed = 0
    local failed_logs = {}
    printh('\n\n\n-------------------------------running tests-----------------------------------\n\n\n')
    for log in all(punit.logs) do
      punit.print_log(log)
      printh('-------------------------------------------------------------------------------')
      if log.status then
        passed += 1
      else
        failed += 1
        add(failed_logs, log)
      end
    end

    printh('\n\n\n----------------------------failed tests---------------------------------------\n\n\n')
    printh('-------------------------------------------------------------------------------')
    for failed_log in all(failed_logs) do
      punit.print_log(failed_log)
      printh('-------------------------------------------------------------------------------')
    end
    printh("\n\ntotal : " .. total .. " passed : " .. passed .. " failed : " .. failed .. " status of : " .. (failed == 0 and "v" or "x") .. "\n\n")
    printh('\n\n\n----------------------------------fin------------------------------------------\n\n\n')
  end,


  assert_that = function(_test_name, _assumption, _optional_got)
    add(punit.logs,punit.new_log(_test_name, _assumption,_optional_got))
  end,

  new_log = function(_test_name, _status, _optional_got) 
    return {test_name = _test_name, status = _status, optional_got = _optional_got != nil and tostr(_optional_got) or ""}
  end,
  
  print_log = function(_log)
    printh(_log.test_name .. " had a status of " .. (_log.status == true and 'v' or 'x') .. (_log.optional_got != "" and (' and got ' .. _log.optional_got) or ""))
  end,

  logs = {}
}

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

