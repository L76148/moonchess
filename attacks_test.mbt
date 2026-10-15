///|
test "knight attack counts" {
  assert_eq(@moonchess.Bitboard::knight_attacks(sq("d4")).count(), 8)
  assert_eq(@moonchess.Bitboard::knight_attacks(sq("a1")).count(), 2)
  assert_eq(@moonchess.Bitboard::knight_attacks(sq("h8")).count(), 2)
  assert_eq(@moonchess.Bitboard::knight_attacks(sq("b1")).count(), 3)
  assert_true(@moonchess.Bitboard::knight_attacks(sq("d4")).contains(sq("f5")))
  assert_eq(
    @moonchess.Bitboard::knight_attacks(sq("d4")).contains(sq("d5")),
    false,
  )
}

///|
test "king attack counts" {
  assert_eq(@moonchess.Bitboard::king_attacks(sq("e1")).count(), 5)
  assert_eq(@moonchess.Bitboard::king_attacks(sq("a1")).count(), 3)
  assert_eq(@moonchess.Bitboard::king_attacks(sq("d4")).count(), 8)
  assert_true(@moonchess.Bitboard::king_attacks(sq("e1")).contains(sq("d2")))
  assert_eq(
    @moonchess.Bitboard::king_attacks(sq("e1")).contains(sq("e3")),
    false,
  )
}

///|
test "pawn attacks follow the colour" {
  let white = @moonchess.Bitboard::pawn_attacks(@moonchess.White, sq("e2"))
  assert_eq(white.count(), 2)
  assert_true(white.contains(sq("d3")))
  assert_true(white.contains(sq("f3")))
  assert_eq(
    @moonchess.Bitboard::pawn_attacks(@moonchess.White, sq("a2")).count(),
    1,
  )
  assert_eq(
    @moonchess.Bitboard::pawn_attacks(@moonchess.White, sq("d8")).count(),
    0,
  )
  let black = @moonchess.Bitboard::pawn_attacks(@moonchess.Black, sq("e7"))
  assert_true(black.contains(sq("d6")))
  assert_true(black.contains(sq("f6")))
  assert_eq(black.contains(sq("e6")), false)
}

///|
test "slider attacks on an empty board" {
  let empty = @moonchess.Bitboard::empty()
  assert_eq(@moonchess.Bitboard::rook_attacks(sq("d4"), empty).count(), 14)
  assert_eq(@moonchess.Bitboard::rook_attacks(sq("a1"), empty).count(), 14)
  assert_eq(@moonchess.Bitboard::bishop_attacks(sq("d4"), empty).count(), 13)
  assert_eq(@moonchess.Bitboard::bishop_attacks(sq("a1"), empty).count(), 7)
  assert_eq(@moonchess.Bitboard::queen_attacks(sq("d4"), empty).count(), 27)
  assert_eq(
    @moonchess.Bitboard::queen_attacks(sq("d4"), empty),
    @moonchess.Bitboard::rook_attacks(sq("d4"), empty).union(
      @moonchess.Bitboard::bishop_attacks(sq("d4"), empty),
    ),
  )
}

///|
test "sliders stop at the first blocker" {
  let rook = @moonchess.Bitboard::rook_attacks(
    sq("d4"),
    @moonchess.Bitboard::single(sq("d6")),
  )
  assert_true(rook.contains(sq("d5")))
  assert_true(rook.contains(sq("d6")))
  assert_eq(rook.contains(sq("d7")), false)
  assert_eq(rook.count(), 12)
  let bishop = @moonchess.Bitboard::bishop_attacks(
    sq("d4"),
    @moonchess.Bitboard::single(sq("f6")),
  )
  assert_true(bishop.contains(sq("e5")))
  assert_true(bishop.contains(sq("f6")))
  assert_eq(bishop.contains(sq("g7")), false)
}

///|
test "attacks_of dispatches on the piece kind" {
  let occupancy = @moonchess.Bitboard::single(sq("d6"))
  assert_eq(
    @moonchess.Bitboard::attacks_of(
      @moonchess.Rook,
      @moonchess.White,
      sq("d4"),
      occupancy,
    ),
    @moonchess.Bitboard::rook_attacks(sq("d4"), occupancy),
  )
  assert_eq(
    @moonchess.Bitboard::attacks_of(
      @moonchess.Pawn,
      @moonchess.White,
      sq("d4"),
      occupancy,
    ),
    @moonchess.Bitboard::pawn_attacks(@moonchess.White, sq("d4")),
  )
  assert_eq(
    @moonchess.Bitboard::attacks_of(
      @moonchess.Knight,
      @moonchess.Black,
      sq("d4"),
      occupancy,
    ),
    @moonchess.Bitboard::knight_attacks(sq("d4")),
  )
}
