///|
/// The squares a knight attacks from every square.
let knight_attack_table : FixedArray[UInt64] = build_step_attacks([
  (1, 2),
  (2, 1),
  (2, -1),
  (1, -2),
  (-1, -2),
  (-2, -1),
  (-2, 1),
  (-1, 2),
])

///|
/// The squares a king attacks from every square.
let king_attack_table : FixedArray[UInt64] = build_step_attacks([
  (0, 1),
  (1, 1),
  (1, 0),
  (1, -1),
  (0, -1),
  (-1, -1),
  (-1, 0),
  (-1, 1),
])

///|
fn build_step_attacks(offsets : Array[(Int32, Int32)]) -> FixedArray[UInt64] {
  let table = FixedArray::make(64, 0UL)
  for square in Square::all() {
    let mut bits = 0UL
    for offset in offsets {
      match square.offset(offset.0, offset.1) {
        Some(target) => bits = bits | (1UL << target.index())
        None => ()
      }
    }
    table[square.index()] = bits
  }
  table
}

///|
/// The squares a knight on `square` attacks.
pub fn Bitboard::knight_attacks(square : Square) -> Bitboard {
  Bitboard::from_u64(knight_attack_table[square.index()])
}

///|
/// The squares a king on `square` attacks.
pub fn Bitboard::king_attacks(square : Square) -> Bitboard {
  Bitboard::from_u64(king_attack_table[square.index()])
}

///|
/// The squares a pawn of `color` attacks from `square`.
pub fn Bitboard::pawn_attacks(color : Color, square : Square) -> Bitboard {
  let rank_delta = if color == White { 1 } else { -1 }
  let mut bits = 0UL
  match square.offset(-1, rank_delta) {
    Some(target) => bits = bits | (1UL << target.index())
    None => ()
  }
  match square.offset(1, rank_delta) {
    Some(target) => bits = bits | (1UL << target.index())
    None => ()
  }
  Bitboard::from_u64(bits)
}

///|
/// Walks from `from` in one direction until the board ends or a piece is
/// reached. The blocking square is included.
fn ray_attacks(
  from : Square,
  occupancy : UInt64,
  file_delta : Int32,
  rank_delta : Int32,
) -> UInt64 {
  let mut bits = 0UL
  let mut file = from.file() + file_delta
  let mut rank = from.rank() + rank_delta
  while file >= 0 && file < 8 && rank >= 0 && rank < 8 {
    let index = rank * 8 + file
    bits = bits | (1UL << index)
    if ((occupancy >> index) & 1UL) == 1UL {
      break
    }
    file = file + file_delta
    rank = rank + rank_delta
  }
  bits
}

///|
/// The squares a rook on `square` attacks.
///
/// Each ray stops at the first occupied square and includes it, so a blocking
/// piece is part of the set. Move generation removes own pieces from the result.
pub fn Bitboard::rook_attacks(
  square : Square,
  occupancy : Bitboard,
) -> Bitboard {
  let occ = occupancy.to_u64()
  Bitboard::from_u64(
    ray_attacks(square, occ, 0, 1) |
    ray_attacks(square, occ, 0, -1) |
    ray_attacks(square, occ, 1, 0) |
    ray_attacks(square, occ, -1, 0),
  )
}

///|
/// The squares a bishop on `square` attacks.
///
/// As with rooks, each ray includes the square that stops it.
pub fn Bitboard::bishop_attacks(
  square : Square,
  occupancy : Bitboard,
) -> Bitboard {
  let occ = occupancy.to_u64()
  Bitboard::from_u64(
    ray_attacks(square, occ, 1, 1) |
    ray_attacks(square, occ, 1, -1) |
    ray_attacks(square, occ, -1, 1) |
    ray_attacks(square, occ, -1, -1),
  )
}

///|
/// The squares a queen on `square` attacks.
///
/// As with rooks and bishops, each ray includes the square that stops it.
pub fn Bitboard::queen_attacks(
  square : Square,
  occupancy : Bitboard,
) -> Bitboard {
  Bitboard::rook_attacks(square, occupancy).union(
    Bitboard::bishop_attacks(square, occupancy),
  )
}

///|
/// The squares a piece of one kind and colour attacks from `square`.
///
/// Pawn attacks ignore the en passant target; use the position level helpers
/// for a complete move list.
pub fn Bitboard::attacks_of(
  kind : PieceKind,
  color : Color,
  square : Square,
  occupancy : Bitboard,
) -> Bitboard {
  match kind {
    Pawn => Bitboard::pawn_attacks(color, square)
    Knight => Bitboard::knight_attacks(square)
    Bishop => Bitboard::bishop_attacks(square, occupancy)
    Rook => Bitboard::rook_attacks(square, occupancy)
    Queen => Bitboard::queen_attacks(square, occupancy)
    King => Bitboard::king_attacks(square)
  }
}
