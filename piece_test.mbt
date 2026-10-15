///|
/// The six piece kinds in storage order.
fn all_kinds() -> Array[@moonchess.PieceKind] {
  [
    @moonchess.Pawn,
    @moonchess.Knight,
    @moonchess.Bishop,
    @moonchess.Rook,
    @moonchess.Queen,
    @moonchess.King,
  ]
}

///|
test "piece letters round trip" {
  for color in [@moonchess.White, @moonchess.Black] {
    for kind in all_kinds() {
      let piece = @moonchess.Piece::new(color, kind)
      assert_eq(@moonchess.Piece::from_fen_char(piece.fen_char()), Some(piece))
    }
  }
}

///|
test "letter case selects the colour" {
  assert_eq(
    @moonchess.Piece::from_fen_char('Q'),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Queen)),
  )
  assert_eq(
    @moonchess.Piece::from_fen_char('q'),
    Some(@moonchess.Piece::new(@moonchess.Black, @moonchess.Queen)),
  )
  assert_eq(
    @moonchess.Piece::from_fen_char('N'),
    Some(@moonchess.Piece::new(@moonchess.White, @moonchess.Knight)),
  )
  assert_eq(@moonchess.Piece::from_fen_char('x'), None)
}

///|
test "piece kind indices round trip" {
  for kind in all_kinds() {
    assert_eq(@moonchess.PieceKind::from_index(kind.index()), Some(kind))
  }
  assert_eq(@moonchess.PieceKind::from_index(6), None)
  assert_eq(@moonchess.PieceKind::from_index(-1), None)
}

///|
test "colour helpers" {
  assert_eq(@moonchess.White.opposite(), @moonchess.Black)
  assert_eq(@moonchess.Black.opposite(), @moonchess.White)
  assert_eq(@moonchess.White.index(), 0)
  assert_eq(@moonchess.Black.index(), 1)
  assert_eq(@moonchess.Color::from_fen_char('w'), Some(@moonchess.White))
  assert_eq(@moonchess.Color::from_fen_char('b'), Some(@moonchess.Black))
  assert_eq(@moonchess.Color::from_fen_char('x'), None)
  assert_eq(@moonchess.White.name(), "white")
  assert_eq(@moonchess.Black.to_string(), "black")
}

///|
test "piece accessors and names" {
  let piece = @moonchess.Piece::new(@moonchess.Black, @moonchess.Rook)
  assert_eq(piece.color(), @moonchess.Black)
  assert_eq(piece.kind(), @moonchess.Rook)
  assert_eq(piece.kind().name(), "rook")
  assert_eq(piece.to_string(), "black rook")
}
