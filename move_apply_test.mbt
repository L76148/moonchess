///|
test "a pawn push records the en passant target and the clock" {
  let before = @moonchess.Position::startpos()
  let after = before.make_move(move_by_uci(before, "e2e4"))
  assert_eq(
    after.to_fen(),
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
  )
  assert_eq(after.turn(), @moonchess.Black)
  assert_eq(after.en_passant(), Some(sq("e3")))
  assert_eq(after.halfmove_clock(), 0)
  assert_eq(after.fullmove_number(), 1)
  assert_eq(after.piece_count(), 32)
  assert_eq(before.to_fen(), @moonchess.start_fen())
}

///|
test "a quiet move advances the halfmove clock" {
  let before = @moonchess.Position::startpos()
  let after = before.make_move(move_by_uci(before, "g1f3"))
  assert_eq(
    after.to_fen(),
    "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1",
  )
  assert_eq(after.en_passant(), None)
  assert_eq(after.halfmove_clock(), 1)
}

///|
test "black resets the clock and increments the move number" {
  let first = @moonchess.Position::startpos().make_move(
    @moonchess.Move::new(sq("g1"), sq("f3")),
  )
  let second = first.make_move(@moonchess.Move::double_push(sq("e7"), sq("e5")))
  assert_eq(
    second.to_fen(),
    "rnbqkbnr/pppp1ppp/8/4p3/8/5N2/PPPPPPPP/RNBQKB1R w KQkq e6 0 2",
  )
  assert_eq(second.turn(), @moonchess.White)
  assert_eq(second.halfmove_clock(), 0)
  assert_eq(second.fullmove_number(), 2)
}

///|
test "a capture removes the captured piece" {
  let before = parse_fen("4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1")
  assert_eq(before.piece_count(), 4)
  let after = before.make_move(move_by_uci(before, "e4d5"))
  assert_eq(after.to_fen(), "4k3/8/8/3P4/8/8/8/4K3 b - - 0 1")
  assert_eq(after.piece_count(), 3)
  assert_eq(
    after.piece_at(sq("d5")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Pawn)),
  )
  assert_eq(after.piece_at(sq("d4")), None)
}

///|
test "a promotion replaces the pawn" {
  let before = parse_fen("4k3/P7/8/8/8/8/8/4K3 w - - 0 1")
  let after = before.make_move(move_by_uci(before, "a7a8q"))
  assert_eq(after.to_fen(), "Q3k3/8/8/8/8/8/8/4K3 b - - 0 1")
  assert_eq(
    after.piece_at(sq("a8")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Queen)),
  )
  assert_eq(after.pieces_of(@moonchess.White, @moonchess.Pawn).count(), 0)
  assert_eq(after.piece_count(), 3)
}

///|
test "castling moves the rook and drops both rights" {
  let before = parse_fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
  let kingside = before.make_move(move_by_uci(before, "e1g1"))
  assert_eq(kingside.to_fen(), "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 1 1")
  assert_eq(
    kingside.piece_at(sq("g1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.King)),
  )
  assert_eq(
    kingside.piece_at(sq("f1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Rook)),
  )
  assert_eq(kingside.piece_at(sq("h1")), None)
  assert_eq(kingside.piece_count(), 6)
  let queenside = before.make_move(move_by_uci(before, "e1c1"))
  assert_eq(queenside.to_fen(), "r3k2r/8/8/8/8/8/8/2KR3R b kq - 1 1")
  assert_eq(
    queenside.piece_at(sq("d1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Rook)),
  )
  assert_eq(queenside.piece_at(sq("a1")), None)
}

///|
test "an en passant capture removes the pawn beside the target" {
  let before = parse_fen("4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
  assert_eq(before.piece_count(), 4)
  let after = before.make_move(move_by_uci(before, "e5d6"))
  assert_eq(after.to_fen(), "4k3/8/3P4/8/8/8/8/4K3 b - - 0 1")
  assert_eq(after.piece_count(), 3)
  assert_eq(after.piece_at(sq("d5")), None)
  assert_eq(
    after.piece_at(sq("d6")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Pawn)),
  )
  assert_eq(after.en_passant(), None)
}

///|
test "moving a rook gives up its castling right" {
  let before = parse_fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
  let after = before.make_move(move_by_uci(before, "a1a2"))
  assert_eq(after.to_fen(), "r3k2r/8/8/8/8/8/R7/4K2R b Kkq - 1 1")
  assert_eq(after.castling().to_fen(), "Kkq")
  assert_eq(after.castling().has_queenside(@moonchess.White), false)
  assert_true(after.castling().has_kingside(@moonchess.White))
}

///|
test "capturing a rook on its home square gives up that right" {
  let before = parse_fen("r3k2r/R7/8/8/8/8/8/4K3 w kq - 0 1")
  let after = before.make_move(move_by_uci(before, "a7a8"))
  assert_eq(after.to_fen(), "R3k2r/8/8/8/8/8/8/4K3 b k - 0 1")
  assert_eq(after.castling().to_fen(), "k")
  assert_eq(after.castling().has_queenside(@moonchess.Black), false)
  assert_true(after.castling().has_kingside(@moonchess.Black))
}

///|
test "a king move gives up both rights" {
  let before = parse_fen("4k3/8/8/8/8/8/8/R3K2R w KQ - 0 1")
  let after = before.make_move(move_by_uci(before, "e1e2"))
  assert_eq(after.to_fen(), "4k3/8/8/8/8/8/4K3/R6R b - - 1 1")
  assert_true(after.castling().is_empty())
}

///|
test "the original position is left untouched" {
  let before = parse_fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
  let _ = before.make_move(move_by_uci(before, "e1g1"))
  assert_eq(before.to_fen(), "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
  assert_eq(
    before.piece_at(sq("e1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.King)),
  )
}
