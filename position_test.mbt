///|
test "the start position holds the usual pieces" {
  let position = @moonchess.Position::startpos()
  assert_eq(
    position.piece_at(sq("e1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.King)),
  )
  assert_eq(
    position.piece_at(sq("d1")),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Queen)),
  )
  assert_eq(
    position.piece_at(sq("e8")),
    Some(@moonchess.Piece::new(@moonchess.Black, @moonchess.King)),
  )
  assert_eq(
    position.piece_at(sq("g8")),
    Some(@moonchess.Piece::new(@moonchess.Black, @moonchess.Knight)),
  )
  assert_eq(position.piece_at(sq("e4")), None)
  assert_true(position.is_empty_square(sq("e4")))
}

///|
test "occupancy and piece counts" {
  let position = @moonchess.Position::startpos()
  assert_eq(position.color_occupancy(@moonchess.White).count(), 16)
  assert_eq(position.color_occupancy(@moonchess.Black).count(), 16)
  assert_eq(position.occupancy().count(), 32)
  assert_eq(position.piece_count(), 32)
  assert_eq(position.pieces_of(@moonchess.White, @moonchess.Pawn).count(), 8)
  assert_eq(position.pieces_of(@moonchess.Black, @moonchess.Pawn).count(), 8)
  assert_eq(position.pieces_of(@moonchess.White, @moonchess.Queen).count(), 1)
}

///|
test "king squares" {
  let position = @moonchess.Position::startpos()
  assert_eq(position.king_square(@moonchess.White), Some(sq("e1")))
  assert_eq(position.king_square(@moonchess.Black), Some(sq("e8")))
  assert_eq(@moonchess.Position::empty().king_square(@moonchess.White), None)
  assert_eq(@moonchess.Position::empty().piece_count(), 0)
  assert_eq(@moonchess.Position::empty().turn(), @moonchess.White)
  assert_eq(
    @moonchess.Position::empty().castling(),
    @moonchess.CastlingRights::none(),
  )
}

///|
test "the board renders as expected" {
  let expected = "8 r n b q k b n r\n7 p p p p p p p p\n6 . . . . . . . .\n5 . . . . . . . .\n4 . . . . . . . .\n3 . . . . . . . .\n2 P P P P P P P P\n1 R N B Q K B N R\n  a b c d e f g h"
  assert_eq(@moonchess.Position::startpos().to_ascii(), expected)
}

///|
test "castling rights are independent per colour and wing" {
  let rights = @moonchess.CastlingRights::all()
  assert_true(rights.has_kingside(@moonchess.White))
  assert_true(rights.has_queenside(@moonchess.White))
  assert_true(rights.has_kingside(@moonchess.Black))
  assert_true(rights.has_queenside(@moonchess.Black))
  let trimmed = rights
    .with_kingside(@moonchess.White, false)
    .with_queenside(@moonchess.Black, false)
  assert_eq(trimmed.to_fen(), "Qk")
  assert_eq(trimmed.has_kingside(@moonchess.White), false)
  assert_eq(trimmed.has_queenside(@moonchess.Black), false)
  assert_eq(trimmed.index(), 2 | 4)
  assert_eq(@moonchess.CastlingRights::none().to_fen(), "-")
  assert_true(@moonchess.CastlingRights::none().is_empty())
  assert_eq(@moonchess.CastlingRights::all().index(), 15)
}

///|
test "empty positions have no castling and an empty board" {
  let position = @moonchess.Position::empty()
  assert_true(position.occupancy().is_empty())
  assert_eq(position.halfmove_clock(), 0)
  assert_eq(position.fullmove_number(), 1)
  assert_eq(position.en_passant(), None)
}
