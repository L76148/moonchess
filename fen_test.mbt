///|
test "the start position parses and round trips" {
  let position = parse_fen(@moonchess.start_fen())
  assert_eq(position.to_fen(), @moonchess.start_fen())
  assert_eq(position.turn(), @moonchess.White)
  assert_eq(position.castling(), @moonchess.CastlingRights::all())
  assert_eq(position.en_passant(), None)
  assert_eq(position.halfmove_clock(), 0)
  assert_eq(position.fullmove_number(), 1)
  assert_eq(position.piece_count(), 32)
  assert_eq(position.to_fen(), @moonchess.Position::startpos().to_fen())
}

///|
test "fen accepts four fields and defaults the clocks" {
  let position = parse_fen("8/8/8/8/8/8/8/K6k w - -")
  assert_eq(position.halfmove_clock(), 0)
  assert_eq(position.fullmove_number(), 1)
  assert_eq(position.to_fen(), "8/8/8/8/8/8/8/K6k w - - 0 1")
}

///|
test "fen round trips castling rights, en passant and clocks" {
  let fen = "r3k2r/8/8/3pP3/8/8/8/R3K2R w Kq d6 0 12"
  let position = parse_fen(fen)
  assert_eq(position.en_passant(), Some(sq("d6")))
  assert_eq(position.fullmove_number(), 12)
  assert_eq(position.turn(), @moonchess.White)
  let rights = @moonchess.CastlingRights::none()
    .with_kingside(@moonchess.White, true)
    .with_queenside(@moonchess.Black, true)
  assert_eq(position.castling(), rights)
  assert_eq(position.to_fen(), fen)
}

///|
test "fen tolerates repeated spaces" {
  let position = parse_fen("8/8/8/8/8/8/8/K6k  w  -  -  0  3")
  assert_eq(position.fullmove_number(), 3)
  assert_eq(position.to_fen(), "8/8/8/8/8/8/8/K6k w - - 0 3")
}

///|
test "fen rejects a missing or oversized field list" {
  assert_eq(fen_error(""), "the FEN document is empty")
  assert_eq(
    fen_error("8/8/8/8/8/8/8/8"),
    "expected between 4 and 6 FEN fields, found 1",
  )
  assert_eq(
    fen_error("8/8/8/8/8/8/8/K6k w - - 0 1 2"),
    "expected between 4 and 6 FEN fields, found 7",
  )
}

///|
test "fen rejects a malformed board" {
  assert_eq(fen_error("8/8/8/8/8/8/8 w - -"), "expected 8 board ranks, found 7")
  assert_eq(
    fen_error("8/8/8/8/8/8/8/8/8 w - -"),
    "expected 8 board ranks, found 9",
  )
  assert_eq(
    fen_error("9/8/8/8/8/8/8/8 w - -"),
    "board rank 8 describes 9 files instead of 8",
  )
  assert_eq(
    fen_error("8/8/8/8/8/8/8/7 w - -"),
    "board rank 1 describes 7 files instead of 8",
  )
  assert_eq(fen_error("z7/8/8/8/8/8/8/8 w - -"), "unknown piece letter 'z'")
}

///|
test "fen rejects malformed state fields" {
  let board = "8/8/8/8/8/8/8/K6k"
  assert_eq(fen_error(board + " x - -"), "invalid side to move 'x'")
  assert_eq(fen_error(board + " ww - -"), "invalid side to move 'ww'")
  assert_eq(fen_error(board + " w Z -"), "invalid castling rights 'Z'")
  assert_eq(fen_error(board + " w - e9"), "invalid en passant square 'e9'")
  assert_eq(fen_error(board + " w - e4"), "invalid en passant square 'e4'")
  assert_eq(fen_error(board + " w - - x 1"), "invalid halfmove clock 'x'")
  assert_eq(fen_error(board + " w - - -1 1"), "invalid halfmove clock '-1'")
  assert_eq(fen_error(board + " w - - 0 0"), "invalid move number '0'")
  assert_eq(fen_error(board + " w - - 0 z"), "invalid move number 'z'")
}

///|
test "fen rejects a board without exactly one king per colour" {
  assert_eq(fen_error("8/8/8/8/8/8/8/8 w - -"), "the white king is missing")
  assert_eq(fen_error("8/8/8/8/8/8/8/K7 w - -"), "the black king is missing")
  assert_eq(
    fen_error("8/8/8/8/8/8/8/KK5k w - -"),
    "the position holds more than one white king",
  )
  assert_eq(
    fen_error("k6k/8/8/8/8/8/8/K7 w - -"),
    "the position holds more than one black king",
  )
}

///|
test "try_from_fen reports instead of raising" {
  match @moonchess.Position::try_from_fen(@moonchess.start_fen()) {
    Ok(position) => assert_eq(position.piece_count(), 32)
    Err(error) => fail(error.message())
  }
  match @moonchess.Position::try_from_fen("not a fen") {
    Ok(_) => fail("expected a parse error")
    Err(error) => assert_true(error.message().length() > 0)
  }
}
