///|
test "square index, file and rank" {
  let a1 = @moonchess.Square::make(0, 0)
  assert_eq(a1.index(), 0)
  assert_eq(a1.file(), 0)
  assert_eq(a1.rank(), 0)
  assert_eq(a1.to_string(), "a1")
  let h8 = @moonchess.Square::make(7, 7)
  assert_eq(h8.index(), 63)
  assert_eq(h8.file(), 7)
  assert_eq(h8.rank(), 7)
  assert_eq(h8.to_string(), "h8")
  assert_eq(@moonchess.Square::make(4, 3).to_string(), "e4")
}

///|
test "every square name round trips" {
  let squares = @moonchess.Square::all()
  assert_eq(squares.length(), 64)
  for square in squares {
    assert_eq(@moonchess.Square::parse(square.to_string()), Some(square))
  }
}

///|
test "square parsing rejects malformed names" {
  assert_eq(@moonchess.Square::parse("e9"), None)
  assert_eq(@moonchess.Square::parse("i4"), None)
  assert_eq(@moonchess.Square::parse("e"), None)
  assert_eq(@moonchess.Square::parse("e44"), None)
  assert_eq(@moonchess.Square::parse("E4"), None)
  assert_eq(@moonchess.Square::parse(""), None)
}

///|
test "square offsets stay on the board" {
  let a1 = sq("a1")
  assert_eq(a1.offset(1, 1), Some(sq("b2")))
  assert_eq(a1.offset(7, 7), Some(sq("h8")))
  assert_eq(a1.offset(-1, 0), None)
  assert_eq(a1.offset(0, -1), None)
  assert_eq(a1.offset(8, 0), None)
  assert_eq(a1.offset(0, 1), Some(sq("a2")))
}

///|
test "square colour" {
  assert_eq(sq("a1").is_light(), false)
  assert_eq(sq("h1").is_light(), true)
  assert_eq(sq("a8").is_light(), true)
  assert_eq(sq("h8").is_light(), false)
}

///|
test "square index bounds" {
  assert_eq(@moonchess.Square::from_index(0), Some(sq("a1")))
  assert_eq(@moonchess.Square::from_index(63), Some(sq("h8")))
  assert_eq(@moonchess.Square::from_index(64), None)
  assert_eq(@moonchess.Square::from_index(-1), None)
}
