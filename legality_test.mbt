///|
test "the start position has twenty legal moves" {
  let position = @moonchess.Position::startpos()
  assert_eq(position.legal_moves().length(), 20)
  assert_eq(position.pseudo_legal_moves().length(), 20)
  assert_true(
    @moonchess.Position::is_legal(position, move_by_uci(position, "e2e4")),
  )
  assert_eq(
    @moonchess.Position::is_legal(
      position,
      @moonchess.Move::new(sq("e2"), sq("e5")),
    ),
    false,
  )
}

///|
test "a pinned rook may only move along the pin" {
  let position = parse_fen("4k3/4r3/8/8/8/8/4R3/4K3 w - - 0 1")
  let pseudo = position.pseudo_legal_moves()
  let legal = position.legal_moves()
  assert_eq(pseudo.length(), 16)
  assert_eq(legal.length(), 9)
  assert_true(has_uci(pseudo, "e2a2"))
  assert_eq(has_uci(legal, "e2a2"), false)
  assert_true(has_uci(legal, "e2e3"))
  assert_true(has_uci(legal, "e2e7"))
  assert_true(has_uci(legal, "e1d1"))
  assert_eq(has_uci(legal, "e2e1"), false)
}

///|
test "the king may not step into check" {
  let position = parse_fen("3rk3/8/8/8/8/8/8/4K3 w - - 0 1")
  let legal = position.legal_moves()
  assert_eq(position.pseudo_legal_moves().length(), 5)
  assert_eq(legal.length(), 3)
  assert_eq(has_uci(legal, "e1d1"), false)
  assert_eq(has_uci(legal, "e1d2"), false)
  assert_true(has_uci(legal, "e1e2"))
  assert_true(has_uci(legal, "e1f1"))
  assert_true(has_uci(legal, "e1f2"))
}

///|
test "a pinned knight has no legal move" {
  let position = parse_fen("k3r3/8/8/8/8/8/4N3/4K3 w - - 0 1")
  let legal = position.legal_moves()
  assert_eq(position.pseudo_legal_moves().length(), 10)
  assert_eq(legal.length(), 4)
  assert_eq(has_uci(legal, "e2c3"), false)
  assert_eq(has_uci(legal, "e2c1"), false)
  assert_true(has_uci(legal, "e1d1"))
}

///|
test "castling may not cross an attacked square" {
  let position = parse_fen("4kr2/8/8/8/8/8/8/R3K2R w KQ - 0 1")
  let legal = position.legal_moves()
  assert_eq(has_uci(legal, "e1g1"), false)
  assert_true(has_uci(legal, "e1c1"))
  assert_eq(has_uci(legal, "e1f1"), false)
  assert_eq(has_uci(legal, "e1f2"), false)
  assert_true(has_uci(position.pseudo_legal_moves(), "e1g1"))
}

///|
test "castling is illegal while in check" {
  let position = parse_fen("4r1k1/8/8/8/8/8/8/R3K2R w KQ - 0 1")
  let pseudo = position.pseudo_legal_moves()
  let legal = position.legal_moves()
  assert_true(@moonchess.Position::in_check(position, @moonchess.White))
  assert_true(has_uci(pseudo, "e1g1"))
  assert_true(has_uci(pseudo, "e1c1"))
  assert_eq(has_uci(legal, "e1g1"), false)
  assert_eq(has_uci(legal, "e1c1"), false)
}

///|
test "castling may not land in check" {
  let position = parse_fen("6rk/8/8/8/8/8/8/R3K2R w KQ - 0 1")
  let legal = position.legal_moves()
  assert_eq(has_uci(legal, "e1g1"), false)
  assert_true(has_uci(legal, "e1c1"))
}

///|
test "en passant that exposes the king is illegal" {
  let position = parse_fen("k7/8/8/1K1pP2r/8/8/8/8 w - d6 0 1")
  let pseudo = position.pseudo_legal_moves()
  let legal = position.legal_moves()
  assert_true(has_uci(pseudo, "e5d6"))
  assert_eq(has_uci(legal, "e5d6"), false)
  assert_true(has_uci(legal, "e5e6"))
}

///|
test "is legal requires the move shape the generator produces" {
  let position = parse_fen("4k3/8/8/8/8/8/8/R3K2R w KQ - 0 1")
  let generated = move_by_uci(position, "e1g1")
  assert_true(@moonchess.Position::is_legal(position, generated))
  let hand_built = @moonchess.Move::new(sq("e1"), sq("g1"))
  assert_eq(@moonchess.Position::is_legal(position, hand_built), false)
}

///|
test "a checkmated side has no legal move" {
  let position = parse_fen(
    "rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3",
  )
  assert_true(@moonchess.Position::in_check(position, @moonchess.White))
  assert_eq(position.legal_moves().length(), 0)
  assert_true(position.pseudo_legal_moves().length() > 0)
}

///|
test "black has twenty legal replies after e2e4" {
  let position = @moonchess.Position::startpos().make_move(
    @moonchess.Move::double_push(sq("e2"), sq("e4")),
  )
  assert_eq(position.turn(), @moonchess.Black)
  assert_eq(position.legal_moves().length(), 20)
}
