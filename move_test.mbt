///|
test "move notation" {
  assert_eq(@moonchess.Move::new(sq("e2"), sq("e4")).to_uci(), "e2e4")
  assert_eq(
    @moonchess.Move::double_push(sq("e2"), sq("e4")).kind,
    @moonchess.DoublePawnPush,
  )
  assert_eq(
    @moonchess.Move::en_passant(sq("e5"), sq("d6")).kind,
    @moonchess.EnPassant,
  )
  assert_eq(@moonchess.Move::castle(@moonchess.White, true).to_uci(), "e1g1")
  assert_eq(@moonchess.Move::castle(@moonchess.Black, false).to_uci(), "e8c8")
  assert_eq(
    @moonchess.Move::castle(@moonchess.White, false).kind,
    @moonchess.CastleQueenside,
  )
  assert_true(@moonchess.Move::castle(@moonchess.White, true).is_castling())
  assert_eq(@moonchess.Move::new(sq("a1"), sq("a2")).is_castling(), false)
}

///|
test "promotion moves carry the piece" {
  let promo = @moonchess.Move::promotion(sq("a7"), sq("a8"), @moonchess.Queen)
  assert_true(promo.is_promotion())
  assert_eq(promo.promotion_piece(), Some(@moonchess.Queen))
  assert_eq(promo.to_uci(), "a7a8q")
  let quiet = @moonchess.Move::new(sq("a2"), sq("a3"))
  assert_eq(quiet.is_promotion(), false)
  assert_eq(quiet.promotion_piece(), None)
}

///|
test "capture detection consults the position" {
  let position = parse_fen("4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1")
  assert_true(@moonchess.Move::new(sq("e4"), sq("d5")).is_capture(position))
  assert_eq(
    @moonchess.Move::new(sq("e4"), sq("e5")).is_capture(position),
    false,
  )
  assert_true(
    @moonchess.Move::en_passant(sq("e5"), sq("d6")).is_capture(position),
  )
}

///|
test "move kinds are named" {
  assert_eq(@moonchess.Normal.name(), "normal")
  assert_eq(@moonchess.DoublePawnPush.name(), "double pawn push")
  assert_eq(@moonchess.EnPassant.name(), "en passant")
  assert_eq(@moonchess.CastleKingside.name(), "castle kingside")
  assert_eq(@moonchess.CastleQueenside.name(), "castle queenside")
  assert_eq(@moonchess.Promotion.name(), "promotion")
  assert_eq(@moonchess.Normal.to_string(), "normal")
}
