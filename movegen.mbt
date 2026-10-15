///|
/// The squares a piece on `square` attacks in this position.
pub fn Position::attacks_from(self : Position, square : Square) -> Bitboard {
  match self.piece_at(square) {
    Some(piece) =>
      Bitboard::attacks_of(
        piece.kind(),
        piece.color(),
        square,
        self.occupancy(),
      )
    None => Bitboard::empty()
  }
}

///|
/// Every piece of `color` that attacks `square`, as a square set.
pub fn Position::attackers_to(
  self : Position,
  square : Square,
  color : Color,
) -> Bitboard {
  let occupancy = self.occupancy()
  let mut result = Bitboard::empty()
  result = result.union(
    self
    .pieces_of(color, Pawn)
    .intersect(Bitboard::pawn_attacks(color.opposite(), square)),
  )
  result = result.union(
    self.pieces_of(color, Knight).intersect(Bitboard::knight_attacks(square)),
  )
  result = result.union(
    self.pieces_of(color, King).intersect(Bitboard::king_attacks(square)),
  )
  result = result.union(
    self
    .pieces_of(color, Bishop)
    .intersect(Bitboard::bishop_attacks(square, occupancy)),
  )
  result = result.union(
    self
    .pieces_of(color, Rook)
    .intersect(Bitboard::rook_attacks(square, occupancy)),
  )
  result = result.union(
    self
    .pieces_of(color, Queen)
    .intersect(Bitboard::queen_attacks(square, occupancy)),
  )
  result
}

///|
/// Whether `color` attacks `square`.
pub fn Position::is_attacked(
  self : Position,
  square : Square,
  color : Color,
) -> Bool {
  !self.attackers_to(square, color).is_empty()
}

///|
/// Whether `color`'s king is attacked.
pub fn Position::in_check(self : Position, color : Color) -> Bool {
  match self.king_square(color) {
    Some(king) => self.is_attacked(king, color.opposite())
    None => false
  }
}

///|
/// Whether a wing is cleared for castling: the right is held, both pieces
/// stand on their home squares and the squares between them are empty.
///
/// King safety is not considered here, so a position with a king in check or
/// a piece attacking the king's path still answers `true`.
pub fn Position::castling_is_pseudo_legal(
  self : Position,
  color : Color,
  kingside : Bool,
) -> Bool {
  let allowed = if kingside {
    self.castling.has_kingside(color)
  } else {
    self.castling.has_queenside(color)
  }
  if !allowed {
    return false
  }
  let home_rank = if color == White { 0 } else { 7 }
  let king_home = Square::make(4, home_rank)
  if self.piece_at(king_home) != Some(Piece::new(color, King)) {
    return false
  }
  let rook_home = Square::make(if kingside { 7 } else { 0 }, home_rank)
  if self.piece_at(rook_home) != Some(Piece::new(color, Rook)) {
    return false
  }
  let files : Array[Int32] = if kingside { [5, 6] } else { [1, 2, 3] }
  for file in files {
    if !self.is_empty_square(Square::make(file, home_rank)) {
      return false
    }
  }
  true
}

///|
fn add_targets(
  moves : Array[Move],
  from : Square,
  targets : Bitboard,
  own : Bitboard,
) -> Unit {
  for target in targets.difference(own).squares() {
    moves.push(Move::new(from, target))
  }
}

///|
fn push_promotions(moves : Array[Move], from : Square, to : Square) -> Unit {
  for kind in [Queen, Rook, Bishop, Knight] {
    moves.push(Move::promotion(from, to, kind))
  }
}

///|
fn Position::add_pawn_moves(
  self : Position,
  moves : Array[Move],
  color : Color,
  enemy : Bitboard,
) -> Unit {
  let rank_delta = if color == White { 1 } else { -1 }
  let start_rank = if color == White { 1 } else { 6 }
  let last_rank = if color == White { 7 } else { 0 }
  for square in self.pieces_of(color, Pawn).squares() {
    match square.offset(0, rank_delta) {
      Some(one) =>
        if self.is_empty_square(one) {
          if one.rank() == last_rank {
            push_promotions(moves, square, one)
          } else {
            moves.push(Move::new(square, one))
            if square.rank() == start_rank {
              match square.offset(0, rank_delta * 2) {
                Some(two) =>
                  if self.is_empty_square(two) {
                    moves.push(Move::double_push(square, two))
                  }
                None => ()
              }
            }
          }
        }
      None => ()
    }
    for file_delta in [-1, 1] {
      match square.offset(file_delta, rank_delta) {
        Some(target) => {
          if enemy.contains(target) {
            if target.rank() == last_rank {
              push_promotions(moves, square, target)
            } else {
              moves.push(Move::new(square, target))
            }
          }
          match self.ep_square {
            Some(ep) =>
              if ep == target {
                match target.offset(0, -rank_delta) {
                  Some(captured) =>
                    if self.piece_at(captured) ==
                      Some(Piece::new(color.opposite(), Pawn)) {
                      moves.push(Move::en_passant(square, target))
                    }
                  None => ()
                }
              }
            None => ()
          }
        }
        None => ()
      }
    }
  }
}

///|
fn Position::add_piece_moves(
  self : Position,
  moves : Array[Move],
  color : Color,
  own : Bitboard,
  kind : PieceKind,
) -> Unit {
  let occupancy = self.occupancy()
  for square in self.pieces_of(color, kind).squares() {
    add_targets(
      moves,
      square,
      Bitboard::attacks_of(kind, color, square, occupancy),
      own,
    )
  }
}

///|
fn Position::add_king_moves(
  self : Position,
  moves : Array[Move],
  color : Color,
  own : Bitboard,
) -> Unit {
  for square in self.pieces_of(color, King).squares() {
    add_targets(moves, square, Bitboard::king_attacks(square), own)
    for kingside in [true, false] {
      if self.castling_is_pseudo_legal(color, kingside) {
        moves.push(Move::castle(color, kingside))
      }
    }
  }
}

///|
/// Every move of the side to move that ignores king safety.
///
/// A position with a pinned piece therefore reports moves that would leave
/// its own king in check, and castling is reported whenever the right and
/// the empty path allow it. Filtering through `is_legal` is the task of the
/// next increment; this list is what perft-style bookkeeping starts from.
pub fn Position::pseudo_legal_moves(self : Position) -> Array[Move] {
  let moves : Array[Move] = []
  let us = self.turn
  let own = self.color_occupancy(us)
  let enemy = self.color_occupancy(us.opposite())
  self.add_pawn_moves(moves, us, enemy)
  self.add_piece_moves(moves, us, own, Knight)
  self.add_piece_moves(moves, us, own, Bishop)
  self.add_piece_moves(moves, us, own, Rook)
  self.add_piece_moves(moves, us, own, Queen)
  self.add_king_moves(moves, us, own)
  moves
}

///|
/// The pseudo-legal moves that start on a square.
pub fn Position::pseudo_legal_moves_from(
  self : Position,
  square : Square,
) -> Array[Move] {
  let out : Array[Move] = []
  for candidate in self.pseudo_legal_moves() {
    if candidate.from == square {
      out.push(candidate)
    }
  }
  out
}
