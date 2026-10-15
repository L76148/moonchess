///|
test "the start position has twenty pseudo-legal moves" {
  let moves = @moonchess.Position::startpos().pseudo_legal_moves()
  assert_eq(moves.length(), 20)
  assert_true(has_uci(moves, "e2e4"))
  assert_true(has_uci(moves, "e2e3"))
  assert_true(has_uci(moves, "g1f3"))
  assert_true(has_uci(moves, "b1a3"))
  assert_eq(has_uci(moves, "e2e5"), false)
  assert_eq(has_uci(moves, "e1g1"), false)
  assert_eq(count_kind(moves, @moonchess.DoublePawnPush), 8)
}

///|
test "single piece move counts" {
  let rook = parse_fen("1k6/8/8/8/3R4/8/8/1K6 w - - 0 1")
  assert_eq(
    @moonchess.Position::pseudo_legal_moves_from(rook, sq("d4")).length(),
    14,
  )
  let bishop = parse_fen("1k6/8/8/8/3B4/8/8/1K6 w - - 0 1")
  assert_eq(
    @moonchess.Position::pseudo_legal_moves_from(bishop, sq("d4")).length(),
    13,
  )
  let corner = parse_fen("1k6/8/8/8/8/8/8/K7 w - - 0 1")
  assert_eq(
    @moonchess.Position::pseudo_legal_moves_from(corner, sq("a1")).length(),
    3,
  )
  assert_eq(@moonchess.Position::pseudo_legal_moves(corner).length(), 3)
}

///|
test "pawns push, capture and promote" {
  let pawn = parse_fen("4k3/8/8/8/8/8/4P3/4K3 w - - 0 1")
  let pushes = @moonchess.Position::pseudo_legal_moves_from(pawn, sq("e2"))
  assert_eq(pushes.length(), 2)
  assert_true(has_uci(pushes, "e2e3"))
  assert_true(has_uci(pushes, "e2e4"))
  let blocked = parse_fen("4k3/8/8/8/8/4n3/4P3/4K3 w - - 0 1")
  assert_eq(
    @moonchess.Position::pseudo_legal_moves_from(blocked, sq("e2")).length(),
    0,
  )
  let capture = parse_fen("4k3/8/8/8/8/3p4/4P3/4K3 w - - 0 1")
  let captures = @moonchess.Position::pseudo_legal_moves_from(capture, sq("e2"))
  assert_true(has_uci(captures, "e2d3"))
  assert_eq(has_uci(captures, "e2f3"), false)
  assert_eq(captures.length(), 3)
}

///|
test "promotion offers four pieces on a push and on a capture" {
  let position = parse_fen("1n2k3/P7/8/8/8/8/8/4K3 w - - 0 1")
  let moves = @moonchess.Position::pseudo_legal_moves_from(position, sq("a7"))
  assert_eq(moves.length(), 8)
  assert_true(has_uci(moves, "a7a8q"))
  assert_true(has_uci(moves, "a7a8r"))
  assert_true(has_uci(moves, "a7a8b"))
  assert_true(has_uci(moves, "a7a8n"))
  assert_true(has_uci(moves, "a7b8q"))
  assert_true(has_uci(moves, "a7b8n"))
  assert_eq(count_kind(moves, @moonchess.Promotion), 8)
}

///|
test "en passant needs a pawn to capture" {
  let position = parse_fen("4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
  let moves = @moonchess.Position::pseudo_legal_moves_from(position, sq("e5"))
  assert_true(has_uci(moves, "e5d6"))
  assert_true(has_uci(moves, "e5e6"))
  assert_eq(count_kind(moves, @moonchess.EnPassant), 1)
  let bogus = parse_fen("4k3/8/8/4P3/8/8/8/4K3 w - d6 0 1")
  assert_eq(
    has_uci(
      @moonchess.Position::pseudo_legal_moves_from(bogus, sq("e5")),
      "e5d6",
    ),
    false,
  )
}

///|
test "castling needs the right and a clear path" {
  let both = parse_fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
  let moves = @moonchess.Position::pseudo_legal_moves_from(both, sq("e1"))
  assert_true(has_uci(moves, "e1g1"))
  assert_true(has_uci(moves, "e1c1"))
  assert_eq(count_kind(moves, @moonchess.CastleKingside), 1)
  let blocked = parse_fen("r3k2r/8/8/8/8/8/8/R2QK2R w KQkq - 0 1")
  let blocked_moves = @moonchess.Position::pseudo_legal_moves_from(
    blocked,
    sq("e1"),
  )
  assert_eq(has_uci(blocked_moves, "e1c1"), false)
  assert_true(has_uci(blocked_moves, "e1g1"))
  let no_rights = parse_fen("r3k2r/8/8/8/8/8/8/R3K2R w - - 0 1")
  let plain = @moonchess.Position::pseudo_legal_moves_from(no_rights, sq("e1"))
  assert_eq(has_uci(plain, "e1g1"), false)
  assert_eq(has_uci(plain, "e1c1"), false)
  assert_eq(
    @moonchess.Position::castling_is_pseudo_legal(
      no_rights,
      @moonchess.White,
      true,
    ),
    false,
  )
  assert_true(
    @moonchess.Position::castling_is_pseudo_legal(both, @moonchess.White, false),
  )
}

///|
test "check detection" {
  assert_eq(@moonchess.Position::startpos().in_check(@moonchess.White), false)
  assert_eq(@moonchess.Position::startpos().in_check(@moonchess.Black), false)
  let rook_check = parse_fen("4k3/8/8/8/8/8/4r3/4K3 w - - 0 1")
  assert_true(@moonchess.Position::in_check(rook_check, @moonchess.White))
  assert_eq(@moonchess.Position::in_check(rook_check, @moonchess.Black), false)
  let knight_check = parse_fen("4k3/8/8/8/8/5n2/8/4K3 w - - 0 1")
  assert_true(@moonchess.Position::in_check(knight_check, @moonchess.White))
}

///|
test "attackers and attacked squares" {
  let start = @moonchess.Position::startpos()
  let d3 = @moonchess.Position::attackers_to(start, sq("d3"), @moonchess.White)
  assert_eq(d3.count(), 2)
  assert_true(d3.contains(sq("c2")))
  assert_true(d3.contains(sq("e2")))
  assert_eq(
    @moonchess.Position::attackers_to(start, sq("e4"), @moonchess.White).count(),
    0,
  )
  assert_true(
    @moonchess.Position::is_attacked(start, sq("e3"), @moonchess.White),
  )
  assert_eq(
    @moonchess.Position::is_attacked(start, sq("e3"), @moonchess.Black),
    false,
  )
  // The corner rook is boxed in by its own pieces, which the attack set
  // reports as blockers while move generation filters them out.
  let corner_rook = @moonchess.Position::attacks_from(start, sq("a1"))
  assert_eq(corner_rook.count(), 2)
  assert_true(corner_rook.contains(sq("a2")))
  assert_true(corner_rook.contains(sq("b1")))
  assert_eq(corner_rook.contains(sq("a3")), false)
  assert_eq(
    @moonchess.Position::pseudo_legal_moves_from(start, sq("a1")).length(),
    0,
  )
  assert_true(
    @moonchess.Position::attacks_from(start, sq("g1")).contains(sq("f3")),
  )
  assert_true(
    @moonchess.Position::attacks_from(start, sq("c2")).contains(sq("d3")),
  )
}

///|
test "attack sets include the first blocker" {
  let position = parse_fen("4k3/8/8/8/8/8/8/R3K3 w - - 0 1")
  let attacks = @moonchess.Position::attacks_from(position, sq("a1"))
  assert_true(attacks.contains(sq("a8")))
  assert_true(attacks.contains(sq("d1")))
  assert_true(attacks.contains(sq("e1")))
  assert_eq(attacks.contains(sq("f1")), false)
}
