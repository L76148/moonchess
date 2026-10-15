///|
test "zobrist tables are reproducible" {
  let a = @moonchess.Zobrist::new()
  let b = @moonchess.Zobrist::new()
  let piece = @moonchess.Piece::new(@moonchess.White, @moonchess.Knight)
  assert_eq(a.piece_key(piece, sq("g1")), b.piece_key(piece, sq("g1")))
  assert_not_eq(a.piece_key(piece, sq("g1")), a.piece_key(piece, sq("b1")))
  assert_eq(a.side_key(), b.side_key())
  assert_eq(
    a.castling_key(@moonchess.CastlingRights::all()),
    b.castling_key(@moonchess.CastlingRights::all()),
  )
  assert_not_eq(
    a.castling_key(@moonchess.CastlingRights::all()),
    a.castling_key(@moonchess.CastlingRights::none()),
  )
  assert_eq(a.en_passant_key(3), b.en_passant_key(3))
}

///|
test "the position key is stable" {
  assert_eq(
    @moonchess.Position::startpos().zobrist_hash(),
    @moonchess.Position::startpos().zobrist_hash(),
  )
  let table = @moonchess.Zobrist::new()
  let position = @moonchess.Position::startpos()
  assert_eq(table.hash(position), position.zobrist_hash())
}

///|
test "the position key separates side, castling and en passant" {
  let start = @moonchess.Position::startpos()
  let black_to_move = parse_fen(
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1",
  )
  assert_not_eq(start.zobrist_hash(), black_to_move.zobrist_hash())
  let no_castling = parse_fen(
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1",
  )
  assert_not_eq(start.zobrist_hash(), no_castling.zobrist_hash())
  let with_en_passant = parse_fen(
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e6 0 1",
  )
  assert_not_eq(start.zobrist_hash(), with_en_passant.zobrist_hash())
  let moved = parse_fen(
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w KQkq - 0 1",
  )
  assert_not_eq(start.zobrist_hash(), moved.zobrist_hash())
}

///|
test "the position key ignores the clocks" {
  let earlier = parse_fen("8/8/8/8/8/8/8/K6k w - - 0 1")
  let later = parse_fen("8/8/8/8/8/8/8/K6k w - - 7 42")
  assert_eq(earlier.zobrist_hash(), later.zobrist_hash())
}
