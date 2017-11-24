pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--[[
  a pico-8 game engine

  mission:
  provide a unit tested framework to lift the development process to the game development problem domain.

  developed by  :   jesse bergerstock
  email         :   illmadecoder@gmail.com
  website       :   http://illmadecoder.com
  github        :   https://github.com/illmadecoder/pico-8_game_engine
  documentation :   https://docs.google.com/document/d/1j6kmR_kGTOsoIGCCqRT858PN3Q9CDZWIrbuMwhTgwkQ/edit?usp=sharing
]]--

--[[
	section header
	1. pico-8 constants & enums
]]--

enum_buttons = {
  left =  0,
  right = 1,
  up =    2,
  down =  3,
  z =     4,
  x =     5
}

enum_colors = {
  black =       0,
  dark_blue =   1,
  dark_purple = 2,
  dark_green =  3,
  brown =       4,
  dark_gray =   5,
  light_gray =  6,
  white =       7,
  red =         8,
  orange =      9,
  yellow =      10,
  green =       11,
  blue =        12,
  indigo =      13,
  pink =        14,
  peach =       15
}

const_pico_memory = {
  sprite_sheet =              {starts = 0x0000, ends = 0x0fff},
  sprite_sheet_share_map =    {starts = 0x1000, ends = 0x1fff},
  map =                       {starts = 0x2000, ends = 0x2fff},
  sprite_flags =              {starts = 0x3000, ends = 0x30ff},
  music =                     {starts = 0x3100, ends = 0x31ff},
  sound_effects =             {starts = 0x3200, ends = 0x42ff},
  general_use  =              {starts = 0x4300, ends = 0x5dff},
  persistent_cart_data =      {starts = 0x5e00, ends = 0x5eff},
  draw_state =                {starts = 0x5f00, ends = 0x5f3f},
  hardware_state  =           {starts = 0x5f40, ends = 0x5f7f},
  gpio_pins  =                {starts = 0x5f80, ends = 0x5fff},
  screen_data  =              {starts = 0x6000, ends = 0x7fff}
}

--[[
	section header
	2. global helper routines
]]--

--[[
  subsection header
  2.1 a zero function
]]--

function empty()
end

--[[
  subsection header
  2.2 maths
]]--

function ceil(_x)
  return -flr(-_x)
end

function sign(_x)
  return _x > 0
          and 1
          or _x < 0
          and -1
          or 0
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

function in_range(_x, _min, _max)
  return _x >= _min and _x <= _max
end

function clamp(_x, _min, _max)
  return _x <= _min
          and _min
          or _x >= _max
          and _max
          or _x
end

function normalize(_x, _min, _max)
  return clamp((_x - _min)/(_max - _min), 0, 1)
end

function approx(_a, _b, _thresh)
  return in_range(abs(_a - _b), 0, _thresh)
end

function lerp(_percent, _min, _max)
  return clamp((_max - _min) * _percent + _min, _min, _max)
end

--[[
  subsection header
  2.3 strings
]]--

function split(_string, _split)
  if _string == "" or not _string then
    return {}
  end

  local ret = {}
  local cur = ""

  for i = 1, #_string do
    local char = sub(_string, i, i)
    if char == _split then
      add(ret, cur)
      cur = ""
    else
      cur = cur .. char
    end
  end

  add(ret, cur)

  return ret
end

function cut(_string, _cut)
  local ret = ""
  local split = split(_string, _cut)

  for i = 1, #split do
    ret = ret .. split[i]
  end

  return ret
end

--[[
  subsection header
  2.4 tables
]]--

function stringify_table(_table, _tab)
  local function num_to_tab(_num)
    local ret = ""
    for i = 1, _num do
      ret = ret .. "    "
    end
    return ret
  end

  _table = _table or {}
  _tab = _tab or 0
  local ret = " \n" .. num_to_tab(_tab) .. "{ \n"

  for k, v in pairs(_table) do
    if type(v) == "function" then
      ret = ret .. num_to_tab(_tab) .. k .. " = " .. k .. "()" .. ' \n'
    elseif type(v) == "table" then
      ret = ret .. num_to_tab(_tab) .. k .. " = " .. stringify_table(v, _tab + 1) .. ' \n'
    else
      ret = ret .. num_to_tab(_tab) .. k .. " = " .. tostr(v) .. ' \n'
    end
  end

  return ret .. num_to_tab(_tab) .. "} \n"
end

function exists(_search, _table)
  for v in all(_table) do
    if v == _search then
      return true
    end
  end

  for k, v in pairs(_table) do
    if v == _search then
      return true
    end
  end

  return false
end

function equal_tables(_a, _b)
  for k, v in pairs(_a) do
    if _b[k] != v then
      return false
    end
  end

  for k, v in pairs(_b) do
    if _a[k] != v then
      return false
    end
  end

  for i = 1, #_a do
    if _b[i] != _a[i] then
      return false
    end
  end

  for i = 1, #_b do
    if _a[i] != _b[i] then
      return false
    end
  end

  return true
end

function mixin(_a, _b)
  local a = deep_copy(_a)
  local b = deep_copy(_b)

  for elem in all(b) do
    add(a, elem)
  end

  for k, v in pairs(b) do
    a[k] = v
  end

  return a
end

function deep_copy(_table)
  local ret = {}

  for k, v in pairs(_table) do
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
]]--

function print_center(_str, _x, _y, _col)
  print(_str, _x + ((4 - #_str * 4)/2), _y, _col)
end

--[[
  subsection header
  2.6 memory
]]

function serialize_screen()
  local virtual_screen = {}
  local row_count = 128
  local row_size = 64

  for row = 0, row_count - 1 do
    virtual_screen[row + 1] = {}
    for col = 0, row_size - 1 do
      local pixel_pair = peek(const_pico_memory.screen_data.starts + col + (row * row_size))
      virtual_screen[row + 1][(col * 2) + 1] = band(pixel_pair, 0x0f)
      virtual_screen[row + 1][(col * 2) + 2] = shr(band(pixel_pair, 0xf0), 4)
    end
    row_string = ""
  end

  return virtual_screen
end

--[[
  subsection header
  2.7 functional
]]--

function f_map(_func, _collection)
  local mapped_collection = {}

  for item in all(_collection) do
    add(mapped_collection, _func(item))
  end

  return mapped_collection
end

function f_filter(_func, _collection)
  local filtered_collection = {}

  for item in all(_collection) do
    if _func(item) then
      add(filtered_collection, item)
    end
  end

  return filtered_collection
end

function f_reduce(_func, _collection, _default)
  local reduced_total = _default

  for item in all(_collection) do
    reduced_total = _func(reduced_total, item)
  end

  return reduced_total
end

--[[
	section header
	3. data types
]]--


--[[
  subsection header
  3.1 vector : {x : number, y : number}
]]--

--[[
  type setup
]]--

_g_vector = {}
_g_vector.metatable = {}
function _g_vector.metatable.__index(_table, _key)
  return _g_vector.metatable[_key]
end

--[[
  constructors
]]--

function _g_vector.new(_x, _y)
  return setmetatable({x = _x, y = _y}, _g_vector.metatable)
end

function _g_vector.from_array(_array)
  return _g_vector.new(_array[1], _array[2])
end

function _g_vector.from_copy(_vector)
  return _g_vector.new(_vector.x, _vector.y)
end

function _g_vector.scalar_multiply(_vector, _scalar)
  return _g_vector.new(_vector.x * _scalar, _vector.y * _scalar)
end

function _g_vector.normalize(_vector)
  return _g_vector.new(_vector.x/_g_vector.magnitude(_vector), _vector.y/_g_vector.magnitude(_vector))
end

function _g_vector.scale(_vector_a, _vector_b)
  return _g_vector.new(_vector_a.x * _vector_b.x, _vector_a.y * _vector_b.y)
end

function _g_vector.inverse(_vector)
  return _g_vector.scalar_multiply(_vector, -1)
end

--[[
    meta operations
--]]

function _g_vector.metatable.__add(_a, _b)
  return _g_vector.new(_a.x + _b.x, _a.y + _b.y)
end

function _g_vector.metatable.__sub(_a, _b)
  return _g_vector.new(_a.x - _b.x, _a.y - _b.y)
end

function _g_vector.metatable.__eq(_a, _b)
  return _a.x == _b.x and _a.y == _b.y
end

--[[
    methods of mutation
--]]

function _g_vector.metatable.set(_self, _x, _y)
  _self.x, _self.y = _x, _y
end

function _g_vector.metatable.set_to(_self, _other)
  _self:set(_other.x, _other.y)
end

function _g_vector.metatable.to_whole(_self)
  _self:set(round(_self.x), round(_self.y))
end

function _g_vector.metatable.lerp(_self, _t, _start, _end)
  _self:set(lerp(_t, _start.x, _end.x), lerp(_t, _start.y, _end.y))
end

function _g_vector.metatable.move_towards(_self, _to, _speed)
  if _g_vector.approx_equal(_self, _to, _speed) then
    _self:set_to(_to)
  else
    _self:set_to(_self + _g_vector.scalar_multiply(_g_vector.unit_towards(_self, _to), _speed))
  end
end

--[[
  helper functions
]]--

function _g_vector.dot(_a, _b)
  return _a.x * _b.x + _a.y * _b.y
end

function _g_vector.magnitude(_vector)
  return sqrt(_vector.x * _vector.x + _vector.y * _vector.y)
end

function _g_vector.unit_towards(_from, _to)
  return _g_vector.normalize(_to - _from)
end

function _g_vector.distance(_vector_a, _vector_b)
  return _g_vector.magnitude(_vector_a - _vector_b)
end

function _g_vector.approx_equal(_vector_a, _vector_b, _thresh)
  return in_range(abs(_g_vector.distance(_vector_a, _vector_b)), 0, _thresh)
end

--[[
  constants & enums
]]--

_g_vector.zero = _g_vector.new(0, 0)

_g_vector.up = _g_vector.new(0, -1)
_g_vector.down = _g_vector.new(0, 1)
_g_vector.left = _g_vector.new(-1, 0)
_g_vector.right = _g_vector.new(1, 0)

--[[
  subsection header
  3.2 rect
]]--

--[[
  type setup
--]]

_g_rect = {}
_g_rect.metatable = {}
function _g_rect.metatable.__index(_table, _key)
  return _g_rect.metatable[_key]
end

--[[
  constructors
]]--

function _g_rect.new(_position, _width, _height)
  return setmetatable({
                        position = _position,
                        width = _width,
                        height = _height
                      },
                      _g_rect.metatable)
end


--[[
  meta operations
]]--

function _g_rect.metatable.__add(_rect_a, _rect_b)
  return _g_rect.new(_rect_a.position + _rect_b.position, _rect_a.width + _rect_b.width, _rect_a.height + _rect_b.height)
end

function _g_rect.metatable.__sub(_rect_a, _rect_b)
  return _g_rect.new(_rect_a.position - _rect_b.position, _rect_a.width -_rect_b.width, _rect_a.height -_rect_b.height)
end

--[[
    methods of mutation
--]]

--[[
  helper functions
]]--

function _g_rect.center(_rect)
  return _g_vector.new(_rect.position.x + _rect.width/2, _rect.position.y + _rect.height/2)
end

function _g_rect.x_max(_rect)
  return max(_rect.position.x, _rect.position.x + _rect.width)
end

function _g_rect.x_min(_rect)
  return min(_rect.position.x, _rect.position.x + _rect.width)
end

function _g_rect.y_max(_rect)
  return max(_rect.position.y, _rect.position.y + _rect.height)
end

function _g_rect.y_min(_rect)
  return min(_rect.position.y, _rect.position.y + _rect.height)
end

function _g_rect.get_corners(_rect)
  local x_max, x_min, y_max, y_min = _g_rect.x_max(_rect), _g_rect.x_min(_rect), _g_rect.y_max(_rect), _g_rect.y_min(_rect)
  return {
            _g_vector.new(x_min, y_min),
            _g_vector.new(x_min, y_max),
            _g_vector.new(x_max, y_min),
            _g_vector.new(x_max, y_max)
         }
end

function _g_rect.contains(_rect, _vector)
  return _vector.x >= _g_rect.x_min(_rect) and
         _vector.x <= _g_rect.x_max(_rect) and
         _vector.y >= _g_rect.y_min(_rect) and
         _vector.y <= _g_rect.y_max(_rect)
end

function _g_rect.overlaps(_rect_a, _rect_b)
  local _rect_b_corners = _g_rect.get_corners(_rect_a)

  for corner in all(_rect_b_corners) do
    if _g_rect.contains(_rect_a(corner)) then
      return true
    end
  end

  return false
end



--[[
  constants & enums
]]--

_g_rect.zero = _g_rect.new(_g_vector.zero, 0, 0)

--[[
  subsection header
  3.3 sprite : {
                  n : number,
                  associated_entity : entity
                  rect : rect,
                  flipx : boolean,
                  flipy : boolean
                }
]]--

--[[
  type setup
--]]

_g_sprite = {}
_g_sprite.metatable = {}
function _g_sprite.metatable.__index(_table, _key)
  return _g_sprite.metatable[_key]
end

--[[
  constructors
]]--

function _g_sprite.new(_n, _rect, _associated_entity, _flipx, _flipy)
  return setmetatable({
      n = _n,
      rect = _rect,
      associated_entity = _associated_entity,
      flipx = _flipx or false,
      flipy = _flipy or false
    }, _g_sprite.metatable)
end

function _g_sprite.from_array(_array)
  return _g_sprite.new(_array[1],
                      _array[2],
                      _array[3],
                      _array[4],
                      _array[5],
                      _array[6])
end

--[[
  methods of mutation
--]]

--[[
  helper functions
]]--
function _g_sprite.get_global_position(_sprite)
  return _sprite.rect.position + _sprite.associated_entity.position
end

function _g_sprite.metatable.draw(_sprite)
  local position = _g_sprite.get_global_position(_sprite)
  spr(_sprite.n,
      position.x,
      position.y,
      _sprite.width,
      _sprite.height,
      _sprite.flipx,
      _sprite.flipy)
end

--[[
  constants & enums
]]--

--[[
  meta operations
]]--

--[[
  subsection header
  3.4 hitbox : {  rect : rect,
                  name : string,
                  tags : array of strings,
                  enabled : boolean, collisions : array of hitboxes,
                  associated_entity : entity }
]]--

--[[
  type setup
--]]

_g_hitbox = {}
_g_hitbox.metatable = {}
function _g_hitbox.metatable__index(_table, _key)
  return _g_hitbox.metatable[_key]
end

--[[
  constructors
]]--

function _g_hitbox.new(_position, _width, _height, _name, _enabled)
  return setmetatable({
    position = _position,
    width = _width,
    height = _height,
    name = _name or "hitbox",
    enabled = _enabled or true,
    collisions = {},
  },
  _g_hitbox.metatable)
end

function _g_hitbox.from_array(_array)
  return _g_hitbox.new(_array[1],
                      _array[2],
                      _array[3],
                      _array[4],
                      _array[5])
end

--[[
  methods of mutation
--]]

--[[
  helper functions
]]--

function _g_hitbox.get_global_position(_self, _entity)
  return _self.position + _entity.position
end

function _g_hitbox.metatable.draw(_self, _entity)
  draw_border(_self:border(), 11)
end

function _g_hitbox.metatable.border(_self, _entity)
  local absolute_position = _g_hitbox.get_global_position(_self, _entity)
  return {x = absolute_position.x, y = absolute_position.y, w = absolute_position.x + _self.width, z = absolute_position.y + _self.height}
end

--[[
  constants & enums
]]--

--[[
  meta operations
]]--

--[[
  subsection header
  3.5 body : {
                rect : rect,
                name : string,
                tags : array of strings,
                enabled : boolean,
                collisions : array of hitboxes,
                associated_entity : entity
              }
]]--

--[[
  type setup
--]]

_g_body = {}
_g_body.metatable = {}
function _g_body.metatable.__index(_table, _key)
  return _g_body.metatable[_key]
end

--[[
  constructors
]]--

--given a collection of hitboxes and a collision callback, return a new body.
function _g_body.new(_hitboxes, _collision_callback)
  return setmetatable({hitboxes = _hitboxes or {}, collision = _collision_callback or empty}, body.metatable)
end

--[[
  methods of mutation
--]]

--[[
  helper functions
]]--

--given a body, draw each hitbox in the body
function _g_body.metatable.draw(_self, _entity)
  for hitbox in all(_self.hitboxes) do
    hitbox:draw(_entity)
  end
end

--given a body, get each hitbox collision
function _g_body.metatable.get_collisions(_self)
  local ret = {}
  for hitbox in all(_self.hitboxes) do
    if #hitbox.collision > 0 then
      add(ret, hitbox)
    end
  end
  return ret
end

--given a body, clear each hitbox collision
function _g_body.metatable.clear_collisions(_self)
  for hitbox in all(_self.hitboxes) do
    hitbox.collisions = {}
  end
end

--given a body and a string name, return a each hitbox of the name
function _g_body.metatable.locate_hitbox(_self, _name)
  local ret = {}
  for hitbox in all(_self.hitboxes) do
    if hitbox.name == _name then
      add(ret, hitbox)
    end
  end
  return ret
end

--[[
  constants & enums
]]--

--[[
  meta operations
]]--

--[[
  subsection header
  3.6 animation : {}
]]--

--[[
  subsection header
  3.7 particle_effect : {}
]]--

--[[
  subsection header
  3.8 entity : {}
]]--

_g_entity = {}
function _g_entity.new(_name, _tag, _position, _update, _draw, _body, _model, _z)
  return {
          name = _name or "entity",
          tag = _tag or {},
          position = _position or _g_vector.new(),
          update = _update or empty,
          draw = _draw or empty,
          body = _body or _g_body.new(),
          model = _model or {},
          z = _z or 0,
          frame = 0
        }
end
_g_entity_data = {}

--[[
  subsection header
  3.9 scene : {}
]]--

_g_scene = {}
function _g_scene.new(_starting, _ending, _update, _late_update, _model)
  return {
        starting = _starting or empty,
        ending = _ending or empty,
        update = _update or empty,
        late_update = _late_update or empty,
        model = _model or {},
        frame = 0
      }
end
_g_scene_data = {}
_g_scene_data.init = _g_scene.new()

--[[
  section header
  4. modules
]]--

--[[
  subsection header
  4.1 entity_controller
]]

entity_controller = {
  entities = {}
}

function entity_controller.add_entity(_self, _entity)
  if type(_entity) == "table" and _entity.name != nil then
    if _self.entity_pool[_entity.z] == nil then
      for i = #_self.entity_pool, _entity.z do
        _self.entity_pool[i] = {}
      end
    end
    add(_self.entity_pool[_entity.z], _entity)
  end
  return _entity
end

function entity_controller.remove_entity(_self, _entity)
  del(_self.entity_pool[_entity.z], _entity)
end

function entity_controller.empty_entities(_self)
  _self.entity_pool = {}
end

function entity_controller.get_entities(_self)
  local ret = {}
  for ent_index in all(_self.entity_pool) do
    mixin(ret, ent_index)
  end
  return ret
end

function entity_controller.locate_entities_tag(_self, _tag)
  local ret = {}
  local entities = _self:get_entities()
  for entity in all(entities) do
    if exists(_tag, entity.tags) then
      add(ret, entity)
    end
  end
  return ret
end

function entity_controller.locate_entities_name(_self, _name)
  local ret = {}
  local entities = _self:get_entities()
  for entity in all(entities) do
    if entity.name == _name then
      add(ret, entity)
    end
  end
  return ret
end

--[[
  subsection header
  4.2 entity_physics
]]

entity_physics = {}

function entity_physics.entity_intersect(_entity1, _entity2)
  --[[
  for hitbox1 in all(_entity1.body.hitboxes) do
    for hitbox2 in all(_entity2.body.hitboxes) do
      if hitbox1.enabled and hitbox2.enabled and entity_physics.hitbox_intersect(hitbox1, _entity1, hitbox2, _entity2) then
        _entity1.body.collision(_entity1, _entity2)
        _entity2.body.collision(_entity2, _entity1)
      end
    end
  end
  --]]
end

function entity_physics.rectcast(_rectcast, _entity_pool)
  local collisions = {}
  --[[
  for entity in all(_entity_pool) do
    for hitbox in all(entity.body.hitboxes) do
      if entity_physics.rect_intersect(_rectcast.position.x, _rectcast.position.y, _rectcast.width, _rectcast.height, hitbox.position.x + entity.position.x, hitbox.position.y + entity.position.y, hitbox.width, hitbox.height) then
        add(collisions, entity)
      end
    end
  end
  ]]
  return collisions
end

function entity_physics.update(_entity_pool)
  for i = 1, #_entity_pool - 1 do
    _entity_pool[i].body:clear_collisions()
    for j = i + 1, #_entity_pool do
      entity_physics.entity_intersect(_entity_pool[i], _entity_pool[j])
    end
  end
end

--[[
  subsection header
  4.3 mouse_controller
]]

mouse_controller = {
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

--[[
  subsection header
  4.4 camera_controller
]]

camera_controller = {
  camera = {
    x = 0,
    y = 0,
    w = 127,
    z = 127
  }
}

function camera_controller.set_camera(_self, _x, _y)
  
end

--[[
  subsection header
  4.6 game_automata
]]

game_automata = {
  entity_prefabs = {},
  scene_prefabs = {
    starting_scene = _g_scene.new()
  },
  active_scene = {}
}

function game_automata.update(_self)
end

function game_automata.late_update(_self)
end

--[[
  subsection header
  4.5 entity_game_engine
]]

entity_game_engine = {
                        entity_controller = entity_controller,
                        entity_physics = entity_physics,
                        camera_controller = camera_controller,
                        game_automata = game_automata,
                        debug_hitboxes = false,
                        pause = false,
                        sample_rate = 1,
                        frame = 0,
                        frames_drawn = 0
                      }

function entity_game_engine.update(_self)
  local entities = _self.entity_controller:get_entities()

  _self.game_automata:update(_self)

  if not _self.pause and _self.frame % _self.sample_rate == 0 then
    entity_physics:update(entities)

    for entity in all(entities) do
      entity:update(_self)
    end
        
    _self.game_automata:late_update(_self)
  end
  
  _self.game_automata:late_update(_self)
  _self.frame += 1
end

function entity_game_engine.draw(_self)
  local entities = _self.entity_controller:get_entities()
  
  if _self.frame % _self.sample_rate == 0 then
    cls()
    --TODO update camera
    
    for entity in all(entities) do
      entity:draw()
      if _self.draw_hitboxes then
        entity.body:draw(entity, _self)
      end
    end
    
    _self.frames_drawn += 1
  end
end
--[[
function entity_game_engine.switch_scene(_self, _scene)
  _self.game_automata.ending(_self.active_scene.model, _self)
  _self.active_scene = _scene
  _self.active_scene.starting(_self.active_scene.model, _self)
end
]]
function entity_game_engine.rectcast(_self, _rect)
  return entity_physics.rectcast(_rect, _self.entity_controller:get_entities())
end

--[[
  section header
  5. pico-8 events
    5.1 _init()
    5.2 _update()
    5.3 _update60()
    5.4 _draw()
]]--

function _init()
  punit.run()
end

function _update60()
  entity_game_engine:update()
end

function _draw()
  entity_game_engine:draw()
end

--[[
	section header
	6. punit
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
          punit.assert_that("in_range x is mid is true", in_range(0, -2, 2))
          punit.assert_that("in_range x is min is true", in_range(-2, -2, 2))
          punit.assert_that("in_range x is max is true", in_range(2, -2, 2))
          punit.assert_that("in_range x is less than min is false", not in_range(-3, -2, 2))
          punit.assert_that("in_range x is greater than max is false", not in_range(3, -2, 2))
        end,
        --clamp(_x : number, _min : number, _max : number) -> number
        function()
          punit.assert_that("clamp x is mid is x", clamp(0, -2, 2) == 0)
          punit.assert_that("clamp x is min is min", clamp(-2, -2, 2) == -2)
          punit.assert_that("clamp x is max is max", clamp(2, -2, 2) == 2)
          punit.assert_that("clamp x is less than min is min", clamp(-3, -2, 2) == -2)
          punit.assert_that("clamp x is greater than max is max", clamp(3, -2, 2) == 2)
        end,
        --normalize(_x : number, _min : number, _max : number) -> number
        function()
          punit.assert_that("normalize x is min is 0", normalize(-2, -2, 2) == 0)
          punit.assert_that("normalize x is max is 1", normalize(2, -2, 2) == 1)
          punit.assert_that("normalize x is centered is .5", normalize(0, -2, 2) == .5)
          punit.assert_that("normalize x is less than min is 0", normalize(-3, -2, 2) == 0)
          punit.assert_that("normalize x is greater than max is 1", normalize(3, -2, 2) == 1)
        end,
        --approx(_a : number, _b : number, _thresh : number) -> boolean
        function()
          punit.assert_that("approx a is b is 0 with a threshold of 0 is true", approx(0, 0, 0))
          punit.assert_that("approx a is b is -1 with a threshold of 0 is true", approx(-1, -1, 0))
          punit.assert_that("approx a is b is 1 with a threshold of 0 is true", approx(1, 1, 0))
          punit.assert_that("approx a is 0 b is 1 with a threshold of 1 is true", approx(0, 1, 1))
          punit.assert_that("approx a is -1 b is 0 with a threshold of 1 is true", approx(-1, 0, 1))
          punit.assert_that("approx a is -1 b is 1 with a threshold of 2 is true", approx(-1, 1, 2))
          punit.assert_that("approx a is 0 b is .5 with a threshold of .5 is true", approx(0, .5, .5))
          punit.assert_that("approx a is .5 b is -.5 with a threshold of 1 is true", approx(.5, -.5, 1))
          punit.assert_that("approx a is 0 b is -1 with a threshold of 0 is false", not approx(0, -1, 0))
          punit.assert_that("approx a is 0 b is 1 with a threshhold of .5 is false", not approx(0, 1, .5))
        end,
        --lerp(_percent : number, _min : number, _max : number) -> number
        function()
          punit.assert_that("lerp 0 percent returns min", lerp(0, -1, 1) == -1)
          punit.assert_that("lerp .5 percent returns the number between min and max", lerp(.5, -1, 1) == 0)
          punit.assert_that("lerp 100 percent returns max", lerp(1, -1, 1) == 1)
          punit.assert_that("lerp less than 0 percent returns min", lerp(-1.5, -1, 1) == -1)
          punit.assert_that("lerp greater than 100 percent returns max", lerp(1.5, -1, 1) == 1)
        end,
      --2.3 strings
        --split(_string : string, _split : string) -> array of strings
        function()
          punit.assert_that("split an empty string returns an empty array", #split("", "|") == 0)
          local split_to_test = split("1|2|3", "|")
          punit.assert_that("split a populated string returns an array of substrings by its split", #split_to_test == 3  and split_to_test[1] == "1" and split_to_test[2] == "2" and split_to_test[3] == "3")
          split_to_test = split("x,x,x", ",")
          punit.assert_that("splits return array of empty strings if there is no characters between split", #split_to_test == 3 and split_to_test[1] == "x" and split_to_test[2] == "x" and split_to_test[3] == "x", stringify_table(split_to_test))
        end,
        --cut(_string : string, _cut : string) -> string
        function()
          punit.assert_that("cut an empty string return an empty string", cut("", ", ") == "")
          punit.assert_that("cut a string such that no occurances of the cut exists now", cut("|1|", "|") == "1")
          punit.assert_that("cut a string composed entirely of occurances of the string to cut returns an empty string", cut("|||", "|") == "")
        end,
      --2.4 tables
        --stringify_table(_table : table, _tab : number) -> string
        function()
          punit.assert_that("stringify_table with an empty table and 0 tab is \n{ \n} \n", stringify_table({}, 0) == " \n{ \n} \n")
        end,
        --exists(_search : any, _table : table) -> boolean
        function()
          punit.assert_that("exists an empty table will return false", not exists(0, {}))
          punit.assert_that("exists an array style table with the value returns true", exists(0, {0}))
          punit.assert_that("exists a dictionary style table with the value returns true", exists(0, {zero = 0}))
          punit.assert_that("exists a populated table without the value returns false", not exists(0, {1, 2, 3}))
        end,
        --equal_tables(_a : table, _b : table) -> boolean
        function()
          punit.assert_that("equal_tables two empty tables are equal", equal_tables({}, {}))
          punit.assert_that("equal_tables two populated but same tables are equal", equal_tables({1, 2, three = 3}, {1, 2, three = 3}))
          punit.assert_that("equal_tables one table is populated one is not so they are not equal left", not equal_tables({1, 2, three = 3}, {}))
          punit.assert_that("equal_tables one table is populated one is not so they are not equal right", not equal_tables({}, {1, 2, three = 3}))
          punit.assert_that("equal_tables both tables are populated but maintain a difference", not equal_tables({1, 2, three = 2}, {1, 2, three = 3}))
        end,
        --mixin(_a : table, _b : table) -> table
        function()
          punit.assert_that("mixin two empty tables returns an empty table", #mixin({}, {}) == 0)
        end,
        --deep_copy(_table) -> table
        function()
          local a
          local a_deep_copy

          a = {reference = "1"}
          a_deep_copy = deep_copy(a)
          a_deep_copy.reference = "2"
          punit.assert_that("deep_copy a reference property will be deep copied", not equal_tables(a, a_deep_copy))

          a = {table = {property = 0 } }
          a_deep_copy = deep_copy(a)
          a_deep_copy.table.property = 1
          punit.assert_that("deep_copy a nested table will be deep copied", not equal_tables(a.table, a_deep_copy.table))
        end,
      --2.5 drawing (not applicable because it depends on the pico-8 system)
      --2.6 memory
      --2.7 functional
        --f_map(_func : function(_element : a) -> b, _collection : array of type a) -> array of type b
        function()
          local add_1 = function(_number) return _number + 1 end

          punit.assert_that("f_map over an empty collection will return an empty collection", equal_tables(f_map(add_1, {}), {}))
          punit.assert_that("f_map over a collection of size 1 will return the mapped result", equal_tables(f_map(add_1, {1}), {2}))

          local large_collection = {}
          local mapped_large_collection = {}
          for i = 1, 100 do
            add(large_collection, i)
            add(mapped_large_collection, add_1(i))
          end
          punit.assert_that("f_map over a large collection will return the mapped result", equal_tables(f_map(add_1, large_collection), mapped_large_collection))
        end,
        --f_filter(_predicate : function(_element : a) -> boolean, _collection : array of a) -> array of a
        function()
          local greater_than_0 = function(_number) return _number > 0 end

          punit.assert_that("f_filter over an empty collection will return an empty collection", equal_tables(f_filter(greater_than_0, {}), {}))
          punit.assert_that("f_filter over a populated collection of number will return only numbers who obey the predicate", equal_tables(f_filter(greater_than_0, {-2, -1, 0, 1, 2}), {1, 2}))
        end,
        --f_reduce(_func : function(_fst : a, _scnd : a) -> a, _collection : array of a) -> a
        function()
          local sum = function(_left, _right) return _left + _right end

          punit.assert_that("f_reduce over an empty collection will return the default", f_reduce(sum, {}, 0) == 0)
          punit.assert_that("f_reduce over a populated collection of numbers w/ sum will return their sum", f_reduce(sum, {-2, -1, 0, 1, 2}, 0) == 0)

          local join_string = function(_left, _right) return _left .. _right end

          punit.assert_that("f_reduce over a string with join_string will return a single string composed of all strings", f_reduce(join_string, {"Hello", " world"}, "") == "Hello world")
        end,

    --3 data types
      --3.1 vector {x : number, y : number}
        --constructors
          --_g_vector.new(_x : number, _y : number) -> vector
          function()
            local typical_vector = _g_vector.new(1, -1)
            punit.assert_that("_g_vector.new of 1, -1 has an x component of 1 and a y component of -1", typical_vector.x == 1 and typical_vector.y == -1)
          end,
          --_g_vector.from_array(_array : array) -> vector
          function()
            local typical_vector = _g_vector.from_array({-1, 1})
            punit.assert_that("_g_vector.from_array of [-1, 1] returns an x component of -1 and y component of 1", typical_vector.x == -1 and typical_vector.y == 1)
          end,
          --_g_vector.from_copy(_vector : vector) -> vector
          function()
            local typical_vector = _g_vector.new(1, -1)
            local copy_of_typical_vector = _g_vector.from_copy(typical_vector)
            copy_of_typical_vector.y = 0
            punit.assert_that("_g_vector.from_copy a vector of x = 1, y = -1 will construct a new value type of the vector", copy_of_typical_vector.y == 0 and typical_vector.y == -1 and copy_of_typical_vector.x == typical_vector.x)
          end,
          --_g_vector.scalar_multiply(_vector : vector, _scalar : number) -> vector
          function()
            local typical_vector = _g_vector.new(1, -1)
            punit.assert_that("_g_vector.scalar_multiply by 2 will double the x and y components value", _g_vector.scalar_multiply(typical_vector, 2).x == 2 and _g_vector.scalar_multiply(typical_vector, 3).y == -3)
          end,
          --_g_vector.normalize(_vector : vector) -> vector
          function()
            local typical_vector = _g_vector.new(1, -1)
            punit.assert_that("_g_vector.normalize a vector x = 1, y = -1 will return a normalized vector of magnitude 1 and the same angle", approx(_g_vector.magnitude(_g_vector.normalize(typical_vector)),1,.1))
          end,
          --_g_vector.scale(_vector_a : vector, _vector_b : vector) -> vector
          function()
            local typical_vector_a = _g_vector.new(1, -1)
            local typical_vector_b = _g_vector.new(1, -2)
            local scaled_vector = _g_vector.scale(typical_vector_a, typical_vector_b)
            punit.assert_that("_g_vector.typical_vector a vector x = 1, y = -1 by a vector x = 1, y = -2 returns a vector x = 1, y = 2", scaled_vector.x == 1 and scaled_vector.y == 2)
          end,
          --_g_vector.inverse(_vector : vector) -> vector
          function()
            local typical_vector = _g_vector.new(1, -1)
            local inverted_vector = _g_vector.inverse(typical_vector)
            punit.assert_that("_g_vector.inverse a vector x = 1, y = -1 will result in a vector x = -1, y = 1", inverted_vector.x == -1 and inverted_vector.y == 1)
          end,

        --meta operations
          --vector + vector -> vector
          function()
            local typical_vector_a = _g_vector.new(1, 1)
            local typical_vector_b = _g_vector.new(-1, -1)
            local added_vectors = typical_vector_a + typical_vector_b
            punit.assert_that("vector + vector of inverses returns zero vector", equal_tables(added_vectors, _g_vector.zero))

            local typical_vector = _g_vector.new(1, 1)
            local added_to_self_vector = typical_vector + typical_vector
            punit.assert_that("vector + vector of the same vectors returns the vector doubled", equal_tables(added_to_self_vector, _g_vector.scalar_multiply(typical_vector, 2)))
            
            punit.assert_that("vector + vector of some vector summed with the zero vector returns some vector", equal_tables(typical_vector + _g_vector.zero, typical_vector))
          end,
          --vector - vector -> vector
          function()
            local typical_vector_a = _g_vector.new(1, 1)
            local typical_vector_b = _g_vector.new(-1, -1)
            local subbed_vectors = typical_vector_a - typical_vector_b
            punit.assert_that("vector - vector of inverses returns a double", equal_tables(subbed_vectors, _g_vector.scalar_multiply(typical_vector_a, 2)))

            local typical_vector = _g_vector.new(1, 1)
            local subbed_to_self_vector = typical_vector - typical_vector
            punit.assert_that("vector - vector of the same vectors returns zero vector", equal_tables(subbed_to_self_vector, _g_vector.zero))
            
            punit.assert_that("vector - vector of some vector summed with the zero vector returns some vector", equal_tables(typical_vector - _g_vector.zero, typical_vector))
          end,
          --vector == vector -> boolean
          function()
            local other_zero_vector = _g_vector.new(0, 0)
            punit.assert_that("vector - vector a vector instance that is 0 is equal to the zero vector", equal_tables(other_zero_vector, _g_vector.zero))
          end,

        --methods of mutation
          --vector:set(_x : number, _y : number) -> void
          function()
            local some_vector = _g_vector.new(1, 1)
            some_vector:set(0, 0) 
            punit.assert_that("vector:set() a new vector of 1, 1 to 0, 0 will mutate the vector to the zero vector", some_vector == _g_vector.zero)
          end,
          --vector:set_to(_self : vector, _other : vector) -> void
          function()
            local some_vector = _g_vector.new(1, 1)
            some_vector:set_to(_g_vector.zero)
            punit.assert_that("vector:set_to() of the zero vector turns the vector into the zero vector", some_vector == _g_vector.zero)
          end,
          --vector:to_whole(_self : vector) -> void
          function()
            local some_vector = _g_vector.new(0.4, -0.4)
            some_vector:to_whole()
            punit.assert_that("vector:to_whole() of .4, and -.4 return the zero vector", some_vector == _g_vector.zero)
          end,
          --vector:lerp(_self : vector, _t : number, _start : vector, _end : vector) -> void
          function()
            local some_vector = _g_vector.new(0, 0)
            local start_vector = _g_vector.new(0, 0)
            local middle_vector = _g_vector.new(50, 50)
            local end_vector = _g_vector.new(100, 100)
            
            some_vector:lerp(0, start_vector, end_vector)
            punit.assert_that("vector:lerp() at 0 from 0,0 to 100, 100 is 0, 0", some_vector == start_vector)

            some_vector:lerp(.5, start_vector, end_vector)
            punit.assert_that("vector:lerp() at .5 from 0,0 to 100, 100 is 50, 50", some_vector == middle_vector)

            some_vector:lerp(1, start_vector, end_vector)
            punit.assert_that("vector:lerp() at 1 from 0,0 to 100, 100 is 100, 100", some_vector == end_vector)

            some_vector:lerp(2, start_vector, end_vector)
            punit.assert_that("vector:lerp() at 2 from 0,0 to 100, 100 is 100, 100", some_vector == end_vector)            

            some_vector:lerp(-1, start_vector, end_vector)
            punit.assert_that("vector:lerp() at -1 from 0,0 to 100, 100 is 0, 0", some_vector == start_vector)            
          end,
          --vector:move_towards(_self : vector, _to : vector, _speed : number) -> void
          function()
            local some_vector = _g_vector.new(0, 0)
            local to_vector = _g_vector.new(0, -100)
            local speed = 1
            
            local single_step = _g_vector.new(0, -1)
            some_vector:move_towards(to_vector, speed)
            punit.assert_that("vector:move_towards() from a vector 0, 0 to a vector 0, -100 at speed 1 will result in a vector 0, -1", some_vector == single_step, stringify_table(some_vector))
          
            local second_step = _g_vector.new(0, -2)
            some_vector:move_towards(to_vector, speed)
            punit.assert_that("vector:move_towards() from a vector 0, -1 to a vector 0, -100 at a speed 1 will result in a vector 0, -2", some_vector == second_step, stringify_table(some_vector))
            
            for i=1,98 do
              some_vector:move_towards(to_vector, speed)
            end
            punit.assert_that("vector:move_towards() from a vector 0, -2 to a vector 0, -100 at a speed 1 after 98 invokes results in a vector 0, -100", some_vector == to_vector, stringify_table(some_vector))
            
            local dont_skip_vector =_g_vector.new(0, 0)
            local dont_skip_me_vector = _g_vector.new(1, 1)
            local skip_speed = 2
            
            dont_skip_vector:move_towards(dont_skip_me_vector, skip_speed)
            punit.assert_that("vector:move_towards() from a vector 0, 0 to a vector 1, 1 at a speed of 2 will result in a vector 1, 1", dont_skip_vector == dont_skip_me_vector, stringify_table(some_vector))
          end,

        --helper functions
          --_g_vector.dot(_vector_a : vector, _vector_b : vector) -> number
          function()
            local some_vector = _g_vector.new(-1, 0)
            local some_vector_a = _g_vector.new(1, 1)
            local some_vector_b = _g_vector.new(1, 0)

            punit.assert_that("_g_vector.dot() of some vector and the zero vector results in 0", _g_vector.dot(some_vector, _g_vector.zero) == 0)
            
            punit.assert_that("_g_vector.dot() of a vector -1, 0 and a vector 1, 0 results in 0", _g_vector.dot(some_vector, some_vector_b) == 0)
            
            punit.assert_that("_g_vector.dot() of a vector 1, 1 and itself results in a vector 4", _g_vector.dot(some_vector_a, some_vector_a) == 4)            
          end,
          --_g_vector.magnitude(_vector : vector) -> number
          function()
          end,
          --_g_vector.unit_twards(_from : vector, _to : vector) -> vector
          function()
          end,
          --_g_vector.distance(_vector_a : vector, _vector_b : vector) -> vector
          function()
          end,
          --_g_vector.approx_equal(_vector_a : vector, _vector_b : vector, _thresh : number) -> boolean
          function()
          end,
    --3.2 rect {position : vector, width : number, height : number}

      --rect.new
      function()
        local rect = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        punit.assert_that("_g_rect.new is with 0s is well formed", rect.position.x == 0, rect.position.y == 0)
      end,

    --meta operations
      -- rect + rect
      function()
        local zero_rect = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        local rect_a
        local rect_b

        rect_a = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        rect_b = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        punit.assert_that("rect + rect two zero rects returns a zero rect", equal_tables(rect_a + rect_b, zero_rect))

        rect_a = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        rect_b = _g_rect.new(_g_vector.new(-1, -1), -1, -1)
        punit.assert_that("rect + of a negative and positive rect of the same magnitude equal zero", equal_tables(rect_a + rect_b, zero_rect))
      end,
      -- rect - rect
      function()
        local rect_a
        local rect_b

        rect_a = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        rect_b = _g_rect.new(_g_vector.new(0, 0), 0, 0)
        punit.assert_that("rect - rect two zero rects returns a zero rect", equal_tables(rect_a - rect_b, _g_rect.zero))

        rect_a = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        rect_b = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        punit.assert_that("rect - rect two equal non-zero rects return a zero rect", equal_tables(rect_a - rect_b, _g_rect.zero))
      end,

    --helper functions
      --_g_rect.center
      function()
        punit.assert_that("_g_rect.center zero rect centers at zero vector", equal_tables(_g_rect.center(_g_rect.zero), _g_vector.zero))

        local typical_rect = _g_rect.new(_g_vector.new(5,10), 10, 5)
        punit.assert_that("_g_rect.center typical_rect returns typical center", equal_tables(_g_rect.center(typical_rect), _g_vector.new(5 + 10/2, 10 + 5/2)))
      end,

      --_g_rect.x_max
      function()
        punit.assert_that("_g_rect.x_max zero rect returns zero", _g_rect.x_max(_g_rect.zero) == 0)

        local positive_rect = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        punit.assert_that("_g_rect.x_max positive rect", _g_rect.x_max(positive_rect) == 2)

        local negative_rect = _g_rect.new(_g_vector.new(-1, -1), -1, -1)
        punit.assert_that("_g_rect.x_max negative rect", _g_rect.x_max(negative_rect) == -1, _g_rect.x_max(negative_rect))

        local mixed_rect = _g_rect.new(_g_vector.new(1, 1), -1, -1)
        punit.assert_that("_g_rect.x_max mixed rect", _g_rect.x_max(mixed_rect) == 1, _g_rect.x_max(mixed_rect))

        local inverted_mixed_rect = _g_rect.new(_g_vector.new(-1, -1), 1, 1)
        punit.assert_that("_g_rect.x_max inverted mixed rect", _g_rect.x_max(inverted_mixed_rect) == 0, _g_rect.x_max(inverted_mixed_rect))
      end,
      --_g_rect.x_min
      function()
        punit.assert_that("_g_rect.x_min zero rect returns zero", _g_rect.x_min(_g_rect.zero) == 0)

        local positive_rect = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        punit.assert_that("_g_rect.x_min positive rect", _g_rect.x_min(positive_rect) == 1)

        local negative_rect = _g_rect.new(_g_vector.new(-1, -1), -1, -1)
        punit.assert_that("_g_rect.x_min negative rect", _g_rect.x_min(negative_rect) == -2, _g_rect.x_min(negative_rect))

        local mixed_rect = _g_rect.new(_g_vector.new(1, 1), -1, -1)
        punit.assert_that("_g_rect.x_min mixed rect", _g_rect.x_min(mixed_rect) == 0, _g_rect.x_min(mixed_rect))

        local inverted_mixed_rect = _g_rect.new(_g_vector.new(-1, -1), 1, 1)
        punit.assert_that("_g_rect.x_min inverted mixed rect", _g_rect.x_min(inverted_mixed_rect) == -1, _g_rect.x_min(inverted_mixed_rect))
      end,
      --_g_rect.y_max
      function()
        punit.assert_that("_g_rect.y_max zero rect returns zero", _g_rect.y_max(_g_rect.zero) == 0)

        local positive_rect = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        punit.assert_that("_g_rect.y_max positive rect", _g_rect.y_max(positive_rect) == 2)

        local negative_rect = _g_rect.new(_g_vector.new(-1, -1), -1, -1)
        punit.assert_that("_g_rect.y_max negative rect", _g_rect.y_max(negative_rect) == -1, _g_rect.y_max(negative_rect))

        local mixed_rect = _g_rect.new(_g_vector.new(1, 1), -1, -1)
        punit.assert_that("_g_rect.y_max mixed rect", _g_rect.y_max(mixed_rect) == 1, _g_rect.y_max(mixed_rect))

        local inverted_mixed_rect = _g_rect.new(_g_vector.new(-1, -1), 1, 1)
        punit.assert_that("_g_rect.y_max inverted mixed rect", _g_rect.y_max(inverted_mixed_rect) == 0, _g_rect.y_max(inverted_mixed_rect))
      end,
      --_g_rect.y_min
      function()
        punit.assert_that("_g_rect.y_min zero rect returns zero", _g_rect.y_min(_g_rect.zero) == 0)

        local positive_rect = _g_rect.new(_g_vector.new(1, 1), 1, 1)
        punit.assert_that("_g_rect.y_min positive rect", _g_rect.y_min(positive_rect) == 1)

        local negative_rect = _g_rect.new(_g_vector.new(-1, -1), -1, -1)
        punit.assert_that("_g_rect.y_min negative rect", _g_rect.y_min(negative_rect) == -2, _g_rect.y_min(negative_rect))

        local mixed_rect = _g_rect.new(_g_vector.new(1, 1), -1, -1)
        punit.assert_that("_g_rect.y_min mixed rect", _g_rect.y_min(mixed_rect) == 0, _g_rect.y_min(mixed_rect))

        local inverted_mixed_rect = _g_rect.new(_g_vector.new(-1, -1), 1, 1)
        punit.assert_that("_g_rect.y_min inverted mixed rect", _g_rect.y_min(inverted_mixed_rect) == -1, _g_rect.y_min(inverted_mixed_rect))
      end,

    --contants & enums
      --_g_rect.zero
      function()
        punit.assert_that("_g_rect.zero defined by all final values as 0", _g_rect.zero.position.x == 0 and _g_rect.zero.position.y == 0 and _g_rect.zero.height == 0 and _g_rect.zero.width == 0)
      end
  },

  run =
  function()
    punit.logs = {}

    for test in all(punit.tests) do
      test()
    end

    local total = #punit.logs
    local passed = 0
    local failed = 0
    local failed_logs = {}
    printh(' \n \n \n-------------------------------running tests----------------------------------- \n \n \n')
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

    printh(' \n \n \n----------------------------failed tests--------------------------------------- \n \n \n')
    printh('-------------------------------------------------------------------------------')
    for failed_log in all(failed_logs) do
      punit.print_log(failed_log)
      printh('-------------------------------------------------------------------------------')
    end
    printh(" \n \ntotal : " .. total .. " passed : " .. passed .. " failed : " .. failed .. " status of : " .. (failed == 0 and "v" or "x") .. " \n \n")
    printh(' \n \n \n----------------------------------fin------------------------------------------ \n \n \n')
  end,


  assert_that =
  function(_test_name, _assumption, _optional_got)
    add(punit.logs, punit.new_log(_test_name, _assumption, _optional_got))
  end,

  new_log =
  function(_test_name, _status, _optional_got)
    return { 
      test_name = _test_name, 
      status = _status, 
      optional_got = _optional_got != nil and tostr(_optional_got) or ""}
  end,

  print_log =
  function(_log)
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
