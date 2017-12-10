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
    --string_to_number(_string)
    function()
      punit.assert_that("string_to_number of '0' returns the number 0", type(string_to_number('0')) == "number" and string_to_number('0') == 0)
      punit.assert_that("string_to_number of '1' returns the number 1", type(string_to_number('1')) == "number" and string_to_number('1') == 1)
      punit.assert_that("string_to_number of '-1' returns the number -1", type(string_to_number('-1')) == "number" and string_to_number('-1') == -1)          
    end,
    --string_to_boolean(_string)
    function()
      punit.assert_that("string_to_boolean() of 'true' returns the boolean true", type(string_to_boolean('true')) == "boolean" and string_to_boolean('true') == true)
      punit.assert_that("string_to_boolean() of 'false' returns the boolean false", type(string_to_boolean('false')) == "boolean" and string_to_boolean('false') == false)
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
  --2.6 functional
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

--3 data types
  --3.1 vector {x : number, y : number}
    --constructors
      --_g_vector.new(_x : number, _y : number) -> vector
      function()
        local typical_vector = _g_vector.new(1, -1)
        punit.assert_that("_g_vector.new of 1, -1 has an x component of 1 and a y component of -1", typical_vector.x == 1 and typical_vector.y == -1)
      end,
      --_g_vector.from_string(_string)
      function()
        local vector_from_string = _g_vector.from_string("1,-1")
        punit.assert_that("_g_vector.from_string of '1,-1' returns the vector x = 1, y = -1", vector_from_string.x == 1 and vector_from_string.y == -1, _g_vector.from_string("1,-1").y)
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
        punit.assert_that("_g_vector.dot() of some vector and the zero vector results in 0", _g_vector.dot(_g_vector.up, _g_vector.zero) == 0)
        punit.assert_that("_g_vector.dot() of a vector -1, 0 and a vector 1, 0 results in 0", _g_vector.dot(_g_vector.left, _g_vector.right) == -1, _g_vector.dot(_g_vector.left, _g_vector.right))
        punit.assert_that("_g_vector.dot() of a vector 1, 1 and itself results in a vector 2", _g_vector.dot(_g_vector.new(1, 1), _g_vector.new(1, 1)) == 2)
      end,
      --_g_vector.magnitude(_vector : vector) -> number
      function()
        punit.assert_that("_g_vector.magnitude() of the zero vector is 0", _g_vector.magnitude(_g_vector.zero) == 0)
        punit.assert_that("_g_vector.magnitude() of a unit vector is 1", _g_vector.magnitude(_g_vector.right) == 1)
      end,
      --_g_vector.unit_towards(_from : vector, _to : vector) -> vector
      function()
        punit.assert_that("_g_vector.unit_towards() a vector right from a vector 0 is a vector right", _g_vector.unit_towards(_g_vector.zero, _g_vector.right) == _g_vector.right)
        punit.assert_that("_g_vector.unit_towards() a vector zero from itself is zero", _g_vector.unit_towards(_g_vector.zero, _g_vector.zero) == _g_vector.zero, _g_vector.unit_towards(_g_vector.zero, _g_vector.zero))
        --punit.assert_that("_g_vector.unit_towards() a vector right to a vector up is a vector who approaches x=0, and y=1 within a unit length", _g_vector.unit_towards(_g_vector.right, _g_vector.up) == _g_vector.new(.5, .5), _g_vector.unit_towards(_g_vector.right, _g_vector.up))
      end,
      --_g_vector.distance(_vector_a : vector, _vector_b : vector) -> number
      function()
        punit.assert_that("_g_vector.distance() of the same two vectors is 0", _g_vector.distance(_g_vector.right, _g_vector.right) == 0)
        punit.assert_that("_g_vector.distance() of a unit vector from the zero vector is 1", _g_vector.distance(_g_vector.zero, _g_vector.right) == 1)
        punit.assert_that("_g_vector.distance() of two opposing unit vectors is 2", _g_vector.distance(_g_vector.left, _g_vector.right) == 2)
      end,
      --_g_vector.approx_equal(_vector_a : vector, _vector_b : vector, _thresh : number) -> boolean
      function()
        punit.assert_that("_g_vector.approx_equal() of a vector at x=.99 y=-.99 will be approx equal to a vector at x=1, y=-1 at a thresh of .01", _g_vector.approx_equal(_g_vector.new(.99, -.99), _g_vector.new(1, -1), .1))
        punit.assert_that("_g_vector.approx_equal() of a vector at x=.99 y=-.99 will be approx equal to a vector at x=1, y=-1 at a thresh of 1", _g_vector.approx_equal(_g_vector.new(.99, -.99), _g_vector.new(1, -1), 1))
        punit.assert_that("_g_vector.approx_equal() of a vector at x=.99 y=-.99 will not be approx equal to a vector at x=1, y=-1 at a thresh of .001", not _g_vector.approx_equal(_g_vector.new(.99, -.99), _g_vector.new(1, -1), .001))
      end,

--3.2 rect {position : vector, width : number, height : number}

  --rect.new
  function()
    local rect = _g_rect.new(_g_vector.new(0, 0), 0, 0)
    punit.assert_that("_g_rect.new is with 0s is well formed", rect.position.x == 0, rect.position.y == 0)
  end,
  --rect.from_string
  function()
    punit.assert_that("_g_rect.from_string of '1,-1,1,-1' returns the rect x = 1, y = -1, width = 1, height = -1", equal_tables(_g_rect.from_string("1,-1,1,-1"), _g_rect.new(_g_vector.new(1, -1), 1, -1)))
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
--_g_rect.get_corners(_rect)
  function()
    local zero_vector_corners = {
      _g_vector.zero,
      _g_vector.zero,
      _g_vector.zero,
      _g_vector.zero
    }
    punit.assert_that("_g_rect.get_corners() of the zero rect is all zero vectors", equal_tables(_g_rect.get_corners(_g_rect.zero), zero_vector_corners))

    local unit_vector_corners = {
      _g_vector.zero,
      _g_vector.down,
      _g_vector.right,
      _g_vector.new(1, 1)
    }
    punit.assert_that("_g_rect.get_corners() of the unit rect is (0,0), (0,1), (1,0), (1,1)", equal_tables(_g_rect.get_corners(_g_rect.unit), unit_vector_corners), unit_vector_corners)
  end,
--_g_rect.contains(_rect, _vector)
  function()
    punit.assert_that("_g_rect.contains of the zero rect and the zero vector is true", _g_rect.contains(_g_rect.zero, _g_vector.zero))
    punit.assert_that("_g_rect.contains of the unit rect and the right vector is true", _g_rect.contains(_g_rect.unit, _g_vector.right))
    punit.assert_that("_g_rect.contains of the unit rect and the down vector is true", _g_rect.contains(_g_rect.unit, _g_vector.down))
    punit.assert_that("_g_rect.contains of the unit rect and the left vector is false", not _g_rect.contains(_g_rect.unit, _g_vector.left))
    punit.assert_that("_g_rect.contains of the unit rect and the up vector is false", not _g_rect.contains(_g_rect.unit, _g_vector.up))
  end,
  --_g_rect.overlaps(_rect_a, _rect_b)
  function()
    punit.assert_that("_g_rect.overlaps of the zero rect and the zero rect is true", _g_rect.overlaps(_g_rect.zero, _g_rect.zero))
    punit.assert_that("_g_rect.overlaps of the zero rect and the unit rect is true", _g_rect.overlaps(_g_rect.unit, _g_rect.zero))
    local top_left = _g_rect.new(_g_vector.new(-1, -1), 1, 1)
    local top_right = _g_rect.new(_g_vector.new(0, -1), 1, 1)
    local bottom_left = _g_rect.new(_g_vector.new(0, 0), -1, 1)
    local bottom_right = _g_rect.new(_g_vector.new(0, 0), 1, 1)
    local center = _g_rect.new(_g_vector.new(-.5, -.5), .5, .5)

    punit.assert_that("_g_rect.overlaps of the top_left and top_left is true", _g_rect.overlaps(top_left, top_left))
    punit.assert_that("_g_rect.overlaps of the top_left and top_right is true", _g_rect.overlaps(top_left, top_right))
    punit.assert_that("_g_rect.overlaps of the top_left and bottom_left is true", _g_rect.overlaps(top_left, bottom_left))
    punit.assert_that("_g_rect.overlaps of the top_left and bottom_right is true", _g_rect.overlaps(top_left, bottom_right))
    punit.assert_that("_g_rect.overlaps of the top_left and center is true", _g_rect.overlaps(top_left, center))
    punit.assert_that("_g_rect.overlaps of the bottom_right and top_right is true", _g_rect.overlaps(bottom_right, top_right))
    punit.assert_that("_g_rect.overlaps of the bottom_right and bottom_left is true", _g_rect.overlaps(bottom_right, bottom_left))
    punit.assert_that("_g_rect.overlaps of the bottom_right and center is true", _g_rect.overlaps(bottom_right, center))

    local off_center = _g_rect.new(_g_vector.new(2, 2), 1, 1)
    local far_bottom_right = _g_rect.new(_g_vector.new(1, 1), 1 ,1)
    punit.assert_that("_g_rect.overlaps of the top_left and off_center is false", not _g_rect.overlaps(top_left, off_center))
    punit.assert_that("_g_rect.overlaps of the center and off_center is false", not _g_rect.overlaps(center, off_center))
    punit.assert_that("_g_rect.overlaps of the bottom_left and off_center is false", not _g_rect.overlaps(bottom_left, off_center))
    punit.assert_that("_g_rect.overlaps of the far_bottom_right and off_center is true", _g_rect.overlaps(far_bottom_right, off_center))
  end,

      --3.3 sprite
      --_g_sprite.new(_n, _rect, _flipx, _flipy)
      function()
        local test_sprite = _g_sprite.new(0, _g_rect.new(_g_vector.new(0, 0), 0, 0), false, true)
        punit.assert_that("_g_sprite.new() of 0, the zero rect, the stub entity, and a flip of false and false will return a well formed sprite", test_sprite.n == 0 and test_sprite.flipx == false and test_sprite.flipy == true)
      end,
      --_g_sprite.from_string(_string)
      function()
        local sprite_from_string = _g_sprite.from_string("0,1,-1,1,-1,true,false")
        punit.assert_that("_g_sprite.from_string of '0,1,-1,1,-1,true,false' returns the sprite n = 0, x = 1, y = -1, width = 1, height = -1, flipx = true, flipy = false", sprite_from_string.n == 0 and sprite_from_string.flipx == true and sprite_from_string.flipy == false,_g_sprite.from_string("0,1,-1,1,-1,true,false"))
      end,
      --_g_sprite.get_global_position(_sprite, _entity)
      function()
        punit.assert_that("_g_sprite.get_global_position of a zero sprite and zero entity returns the zero vector", equal_tables(_g_sprite.get_global_position(punit.quick_new.sprite(), punit.quick_new.entity()), _g_vector.zero))

        local offset_sprite = punit.quick_new.sprite()
        offset_sprite.rect.position.x = 1

        punit.assert_that("_g_sprite.get_global_position of a sprite offset on the x axis by 1 and zero entity returns the x=1 y=0 vector", equal_tables(_g_sprite.get_global_position(offset_sprite, punit.quick_new.entity()), _g_vector.new(1, 0)))

        local offset_entity = punit.quick_new.entity()
        offset_entity.position.x = -1
        punit.assert_that("_g_sprite.get_global_position of a zero sprite and an entity offset on the x axis by -1 returns the x=-1 y=0 vector", equal_tables(_g_sprite.get_global_position(punit.quick_new.sprite(), offset_entity), _g_vector.new(-1, 0)))

        punit.assert_that("_g_sprite.get_global_position of a sprite offset on the y axis by 1 and an entity offset on the y axis by -1 returns the zero vector", equal_tables(_g_sprite.get_global_position(offset_sprite, offset_entity), _g_vector.zero))
      end,

      --3.4 hitbox
      --_g_hitbox.new(_name, _tag, _rect, _enabled)
      function()
        local hitbox_stub = punit.quick_new.hitbox()
        punit.assert_that("_g_hitbox.new() of the default stub is well formed", hitbox_stub.name == "stub")
      end,

      --_g_hitbox.get_global_position(_hitbox, _entity)
      function()
        punit.assert_that("_g_hitbox.get_global_position of a zero hitbox and zero entity returns the zero vector", equal_tables(_g_hitbox.get_global_position(punit.quick_new.hitbox(), punit.quick_new.entity()), _g_vector.zero))

        local offset_hitbox = punit.quick_new.hitbox()
        offset_hitbox.rect.position.x = 1

        punit.assert_that("_g_hitbox.get_global_position of a hitbox offset on the x axis by 1 and zero entity returns the x=1 y=0 vector", equal_tables(_g_hitbox.get_global_position(offset_hitbox, punit.quick_new.entity()), _g_vector.new(1, 0)))

        local offset_entity = punit.quick_new.entity()
        offset_entity.position.x = -1
        punit.assert_that("_g_hitbox.get_global_position of a zero hitbox and an entity offset on the x axis by -1 returns the x=-1 y=0 vector", equal_tables(_g_hitbox.get_global_position(punit.quick_new.hitbox(), offset_entity), _g_vector.new(-1, 0)))

        punit.assert_that("_g_hitbox.get_global_position of a hitbox offset on the y axis by 1 and an entity offset on the y axis by -1 returns the zero vector", equal_tables(_g_hitbox.get_global_position(offset_hitbox, offset_entity), _g_vector.zero))
      end,

      --3.5 body
      --_g_body.new(_hitboxes, _collision_callback)
      function()
        local test_body = _g_body.new({}, empty)
        punit.assert_that("_g_body.new() creates well formed body", #test_body.hitboxes == 0 and type(test_body.collision_callback) == "function")
      end,

      --_g_body.get_collisions(_body)
      function()
        local test_body = punit.quick_new.body()
        local test_entity = punit.quick_new.entity() 

        punit.assert_that("_g_body.get_collisions of a body with zero collision returns zero collision", #_g_body.get_collisions(test_body) == 0)
        
        add(test_body.hitboxes[1].collisions, test_entity)
        
        punit.assert_that("_g_body.get_collisions of a body with one collision returns one collision", #_g_body.get_collisions(test_body) == 1)
      end,

      --_g_body.locate_hitboxes(_body, _name)
      function()
        punit.assert_that("_g_body.locate_hitboxes on a body with a hitbox of name '1' will return a hitbox of name '1'", _g_body.locate_hitboxes(punit.quick_new.body(), "1")[1].name == '1')
        punit.assert_that("_g_body.locate_hitboxes on a body without a hitbox of name not here will return an empty list", #_g_body.locate_hitboxes(punit.quick_new.body(), "not here") == 0)
      end,
      --3.6 graphics
      --3.8 entity
      --new
      function()
        local test_entity =  _g_entity.new("test", {"test"}, _g_vector.new(0, 0), empty, empty, punit.quick_new.body(), punit.quick_new.graphic(), 0) 
        punit.assert_that("_g_entity.new a test entity is well formed", #test_entity.graphic.sprites == 1)
      end,
      
      --4.1 entity_controller
      --empty
      function()
        entity_controller.empty()
        punit.assert_that("entity_controller.empty will contain no entities", equal_tables(entity_controller.get_entities(), {}))
      end,
      
      --insert_entity
      function()
        entity_controller.empty()
        local entity = punit.quick_new.entity()
        entity_controller.insert_entity(entity)
        punit.assert_that("entity_controller.insert_entity an entity will contain that entity", equal_tables(entity_controller.get_entities(), { entity }))
        entity_controller.empty()
      end,
      
      --remove
      function()
        entity_controller.empty()
        local entity = punit.quick_new.entity()
        entity_controller.insert_entity(entity)
        entity_controller.remove_entity(entity)
        punit.assert_that("entity_controller.remove_entity an entity will not contain that entity", equal_tables(entity_controller.get_entities(), { }))
        entity_controller.empty()
      end,
      
      --get_entities
      function()
        entity_controller.empty()
        local entity = punit.quick_new.entity()
        entity_controller.insert_entity(entity)
        punit.assert_that("entity_controller.get_entities will return a list of the inserted entities", equal_tables(entity_controller.get_entities(), { entity }))
        entity_controller.empty()
      end,
      
      --locate_all_by_name
      function()
        entity_controller.empty()
        local entity = punit.quick_new.entity("test", {"test"})
        entity_controller.insert_entity(entity)
        punit.assert_that("entity_controller.get_entities_name will return a list of the inserted entities", equal_tables(entity_controller.locate_entities_name("test"), { entity }))
        entity_controller.empty()
      end,
      
      --locate_entities_tag
      function()
        entity_controller.empty()
        local entity = punit.quick_new.entity("test", {"test"})
        entity_controller.insert_entity(entity)
        punit.assert_that("entity_controller.get_entities_test will return a list of the inserted entities", equal_tables(entity_controller.locate_entities_tag("test"), { entity }))
        entity_controller.empty()
      end,

      --4.2 entity_physics
      --entity_intersect
      function()
        local entity_a = punit.quick_new.entity()
        local entity_b = punit.quick_new.entity()
        entity_a.body.hitboxes = {}
        entity_b.body.hitboxes = {}

        entity_physics.entity_intersect(entity_a, entity_b)
        punit.assert_that("entity_physics.entity_intersect does not create collisions on two empty bodies", #_g_body.get_collisions(entity_a.body) == 0)


        add(entity_a.body.hitboxes, _g_hitbox.new("a", {"a"}, _g_rect.new(_g_vector.new(100, 100), 10, 10)))
        add(entity_b.body.hitboxes, _g_hitbox.new("b", {"b"}, _g_rect.new(_g_vector.new(20, 20), 10, 10)))
        punit.assert_that("entity_physics.entity_intersect does not create collisions on two non intersecting bodies", #_g_body.get_collisions(entity_a.body) == 0)


        add(entity_a.body.hitboxes, _g_hitbox.new("a", {"a"}, _g_rect.new(_g_vector.new(0, 0), 10, 10)))
        add(entity_b.body.hitboxes, _g_hitbox.new("b", {"b"}, _g_rect.new(_g_vector.new(0, 0), 10, 10)))
        entity_physics.entity_intersect(entity_a, entity_b)
        punit.assert_that("entity_physics.entity_intersect creates collisions on two seperate but equal hitboxes", #_g_body.get_collisions(entity_a.body) == 1)
      end,
      --rectcast
      function()
        local test_entity = punit.quick_new.entity()
        local test_hitbox_entity = _g_hitbox.new("test", {}, _g_rect.new(_g_vector.new(0, 0), 10, 10))
        local test_rect_rectcast = _g_rect.new(_g_vector.new(40, 40), 10, 10)

        test_entity.body.hitboxes = {test_hitbox_entity}
        
        entity_controller.empty()
        entity_controller.insert_entity(test_entity)

        test_entity.position:set(0, 0)
        
        punit.assert_that("entity_physics.rectcast() of a rect who misses an entity in the entity_controller returns no collisions", #entity_physics.rectcast(test_rect_rectcast) == 0)

        test_entity.position:set(40, 40)
        
        punit.assert_that("entity_physics.rectcast() of a rect over an entity in the entity_controller returns a collision", #entity_physics.rectcast(test_rect_rectcast) == 1)

        entity_controller.empty()
      end,
      
      --update
      function()
        local test_hitbox_a = _g_hitbox.new("a", {}, _g_rect.new(_g_vector.new(0, 0), 10, 10))
        local test_hitbox_b = _g_hitbox.new("b", {}, _g_rect.new(_g_vector.new(0, 0), 10, 10))
        local test_entity_a = _g_entity.new("a", {}, _g_vector.new(0, 0), empty, empty, _g_body.new({test_hitbox_a}), nil, 1, true)
        local test_entity_b = _g_entity.new("b", {}, _g_vector.new(11, 11), empty, empty, _g_body.new({test_hitbox_b}), nil, 1, true)
        
        entity_controller.empty()
        entity_controller.insert_entity(test_entity_a)        
        punit.assert_that("entity_physics.update with one entity causes no collision events", #_g_body.get_collisions(test_entity_a.body) == 0)

        entity_controller.insert_entity(test_entity_b)
        entity_physics.update()
        punit.assert_that("entity_physics.update with two disjoint entities causes no collision events", #_g_body.get_collisions(test_entity_a.body) == 0 and #_g_body.get_collisions(test_entity_b.body) == 0)
  
        test_entity_b.position:set(10, 10)
        entity_physics.update()
        punit.assert_that("entity_physics.update with two joint entities causes a collision event", #_g_body.get_collisions(test_entity_a.body) == 1 and #_g_body.get_collisions(test_entity_b.body) == 1)
      end,
      
      --4.3 mouse controller
      --no unit tests here
      
      --4.5 game_automata
      --no unit tests here
      
      --4.6 entity_game_engine
      
  },

  draw_tests = {
    --3.2 rect
    function ()
      local unit_rect = _g_rect.new(_g_vector.new(64, 0), 16, 16)
      unit_rect:draw(enum_colors.red, true)
    end,
    --3.3 sprite
    --_g_sprite:draw()
    function()
      local unit_sprite = punit.quick_new.sprite(0, _g_rect.new(_g_vector.new(0, 0), 8, 8))
      local double_sprite = punit.quick_new.sprite(1, _g_rect.new(_g_vector.new(8, 0), 16, 16))
      unit_sprite:draw(punit.quick_new.entity())
      double_sprite:draw(punit.quick_new.entity())
    end,
    --3.4 hitbox
    --_g_hitbox:draw(_entity)
    function()
      local unit_hitbox = _g_hitbox.new()
      unit_hitbox.rect.position.y = 8
      unit_hitbox.rect.width = 8
      unit_hitbox.rect.height = 8
      unit_hitbox:draw(punit.quick_new.entity())
    end,
    --3.5 body
    --_g_body.draw()
    function()
      local unit_body = punit.quick_new.body()
      unit_body:draw(punit.quick_new.entity())
    end,
    --3.6 graphic
    function()
      local test_graphic = punit.quick_new.graphic({
                                  punit.quick_new.sprite(0, _g_rect.new(_g_vector.new(28, 0), 8, 8)), 
                                  punit.quick_new.sprite(1, _g_rect.new(_g_vector.new(28, 8), 16, 16))}, 
                                  true)
      local test_entity = punit.quick_new.entity()
      test_entity.position.x = 16
      test_graphic:draw(test_entity)
    end
  },

  draw =
  function()
    for draw_test in all(punit.draw_tests) do
      draw_test()
    end
  end,

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
      optional_got = _optional_got != nil and type(_optional_got) == "table" and stringify_table(_optional_got) or tostr(_optional_got) or ""}
  end,

  print_log =
  function(_log)
    printh(_log.test_name .. " had a status of " .. (_log.status == true and 'v' or 'x') .. (_log.optional_got != "" and (' and got ' .. _log.optional_got) or ""))
  end,

  logs = {},

  quick_new = {
    sprite = function(_n, _rect, _flipx, _flipy)
      return _g_sprite.new(_n or 0, _rect or _g_rect.new(_g_vector.new(0, 0), 0, 0), _flipx or false, _flipy or false)
    end,

    hitbox = function(_name, _tags, _rect, _enabled)
      return _g_hitbox.new(_name or "stub", _tags or {"stub"}, _rect or _g_rect.new(_g_vector.new(0, 0), 0, 0), _enabled or true)
    end,

    body = function(_hitboxes, _collision_callback)
      return _g_body.new(_hitboxes or { punit.quick_new.hitbox("1", {"1"}, _g_rect.new(_g_vector.new(0, 32), 32, 32), true), punit.quick_new.hitbox("1", {"1"}, _g_rect.new(_g_vector.new(0, 64), 32, 32), true) }, function (_a, _b) return _b.name end)
    end,
    
    graphic = function(_sprites, _enabled)
      return _g_graphic.new(_sprites or {punit.quick_new.sprite()}, _enabled or true)
    end,
    
    entity = function(_name, _tags, _position, _update, _draw, _body, _graphic, _z)
      return _g_entity.new(_name or "stub", _tags or {"tag"}, _position or _g_vector.new(0,0), _update or empty, _draw or empty, _body or punit.quick_new.body(), _graphic or punit.quick_new.graphic(), _z or 1)
    end
  }
}