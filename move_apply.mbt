///|
/// The castling right that a corner square belongs to.
fn castling_right_at(square : Square) -> (Color, Bool)? {
  match square.index() {
    0 => Some((White, false))
    7 => Some((White, true))
    56 => Some((Black, false))
    63 => Some((Black, true))
    _ => None
  }
}

///|
fn set_piece(
  pieces : FixedArray[UInt64],
  color : Color,
  kind : PieceKind,
  square : Square,
) -> Unit {
  let index = piece_index(color, kind)
  pieces[index] = pieces[index] | (1UL << square.index())
}

///|
fn clear_piece(
  pieces : FixedArray[UInt64],
  color : Color,
  kind : PieceKind,
  square : Square,
) -> Unit {
  let index = piece_index(color, kind)
  pieces[index] = pieces[index] & (1UL << square.index()).lnot()
}

///|
fn revoke_right(
  rights : CastlingRights,
  color : Color,
  kingside : Bool,
) -> CastlingRights {
  if kingside {
    rights.with_kingside(color, false)
  } else {
    rights.with_queenside(color, false)
  }
}

///|
fn relocate_rook(
  pieces : FixedArray[UInt64],
  color : Color,
  rank : Int32,
  from_file : Int32,
  to_file : Int32,
) -> Unit {
  let index = piece_index(color, Rook)
  let origin = Square::make(from_file, rank)
  let destination = Square::make(to_file, rank)
  pieces[index] = pieces[index] & (1UL << origin.index()).lnot()
  pieces[index] = pieces[index] | (1UL << destination.index())
}

///|
/// Applies a move and returns the resulting position.
///
/// The move is applied as written, so this does not check king safety: a
/// move that leaves the mover in check still produces the position it
/// describes. The origin square must hold a piece, which is always true for
/// a move that came out of `pseudo_legal_moves`.
///
/// The step updates everything FEN records: the piece bitboards, a capture
/// on the target square, the pawn removed by an en passant capture, the
/// promoted piece, the rook of a castling, the castling rights lost by a
/// king or rook move or by the capture of a rook on its home square, the en
/// passant target after a double pawn push, the halfmove clock and the move
/// number.
pub fn Position::make_move(self : Position, played : Move) -> Position {
  let mover = match self.piece_at(played.from) {
    Some(piece) => piece
    None => {
      let message = StringBuilder()
      message.write_string("no piece on ")
      message.write_string(played.from.to_string())
      message.write_string(" to move to ")
      message.write_string(played.to.to_string())
      abort(message.to_string())
    }
  }
  let pieces = FixedArray::make(12, 0UL)
  for index = 0; index < 12; index = index + 1 {
    pieces[index] = self.pieces[index]
  }
  let captured = self.piece_at(played.to)
  match captured {
    Some(piece) => clear_piece(pieces, piece.color(), piece.kind(), played.to)
    None => ()
  }
  if played.kind == EnPassant {
    let behind = if mover.color() == White { -1 } else { 1 }
    match played.to.offset(0, behind) {
      Some(square) =>
        clear_piece(pieces, mover.color().opposite(), Pawn, square)
      None => ()
    }
  }
  clear_piece(pieces, mover.color(), mover.kind(), played.from)
  let placed = match played.promotion {
    Some(kind) => kind
    None => mover.kind()
  }
  set_piece(pieces, mover.color(), placed, played.to)
  match played.kind {
    CastleKingside =>
      relocate_rook(pieces, mover.color(), played.from.rank(), 7, 5)
    CastleQueenside =>
      relocate_rook(pieces, mover.color(), played.from.rank(), 0, 3)
    _ => ()
  }
  let mut castling = self.castling
  match mover.kind() {
    King =>
      castling = castling
        .with_kingside(mover.color(), false)
        .with_queenside(mover.color(), false)
    Rook =>
      match castling_right_at(played.from) {
        Some((color, kingside)) =>
          castling = revoke_right(castling, color, kingside)
        None => ()
      }
    _ => ()
  }
  match castling_right_at(played.to) {
    Some((color, kingside)) =>
      castling = revoke_right(castling, color, kingside)
    None => ()
  }
  let en_passant = match played.kind {
    DoublePawnPush =>
      Some(
        Square::make(
          played.from.file(),
          (played.from.rank() + played.to.rank()) / 2,
        ),
      )
    _ => None
  }
  let halfmove_clock = if mover.kind() == Pawn ||
    captured != None ||
    played.kind == EnPassant {
    0
  } else {
    self.halfmove_clock + 1
  }
  let fullmove_number = if self.turn == Black {
    self.fullmove_number + 1
  } else {
    self.fullmove_number
  }
  Position::new(
    pieces,
    self.turn.opposite(),
    castling,
    en_passant,
    halfmove_clock,
    fullmove_number,
  )
}
