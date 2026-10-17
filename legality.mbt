///|
/// Whether a castling move is legal: the right must be held, both pieces must
/// be home, the path must be empty, and the king must not be in check, cross
/// an attacked square or land on one.
fn Position::castling_is_legal(
  self : Position,
  color : Color,
  kingside : Bool,
) -> Bool {
  if !self.castling_is_pseudo_legal(color, kingside) {
    return false
  }
  let rank = if color == White { 0 } else { 7 }
  let them = color.opposite()
  if self.is_attacked(Square::make(4, rank), them) {
    return false
  }
  let crossed : Array[Int32] = if kingside { [5] } else { [3] }
  for file in crossed {
    if self.is_attacked(Square::make(file, rank), them) {
      return false
    }
  }
  let destination = Square::make(if kingside { 6 } else { 2 }, rank)
  !self.is_attacked(destination, them)
}

///|
/// Whether a pseudo-legal move leaves the mover's king safe.
fn Position::keeps_king_safe(self : Position, played : Move) -> Bool {
  let mover = match self.piece_at(played.from) {
    Some(piece) => piece
    None => return false
  }
  match played.kind {
    CastleKingside => self.castling_is_legal(mover.color(), true)
    CastleQueenside => self.castling_is_legal(mover.color(), false)
    _ => {
      let after = self.make_move(played)
      match after.king_square(mover.color()) {
        Some(king) => !after.is_attacked(king, mover.color().opposite())
        None => false
      }
    }
  }
}

///|
/// The legal moves of the side to move.
///
/// A move is legal when it is pseudo-legal and, once played, the mover's own
/// king is not attacked. Castling additionally requires that the king is not
/// in check, does not cross an attacked square and does not land on one. An
/// en passant capture is checked after the captured pawn has been removed,
/// so a capture that opens a rank to the king is rejected.
pub fn Position::legal_moves(self : Position) -> Array[Move] {
  let out : Array[Move] = []
  for candidate in self.pseudo_legal_moves() {
    if self.keeps_king_safe(candidate) {
      out.push(candidate)
    }
  }
  out
}

///|
/// Whether a move is legal.
///
/// The move must be one that `pseudo_legal_moves` generates, with the same
/// origin, target, kind and promotion piece. A move built by hand with the
/// right origin and target but the wrong kind, such as a castle written as a
/// plain king move, is not recognised. Use `legal_moves` to obtain moves
/// that satisfy this contract.
pub fn Position::is_legal(self : Position, played : Move) -> Bool {
  for candidate in self.pseudo_legal_moves() {
    if candidate == played {
      return self.keeps_king_safe(candidate)
    }
  }
  false
}
