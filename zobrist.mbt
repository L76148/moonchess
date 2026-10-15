///|
/// Deterministic Zobrist keys for chess positions.
///
/// The tables are derived from fixed seeds with the SplitMix64 finalizer, so
/// the same key is produced on every run and on every backend.
pub(all) struct Zobrist {
  priv pieces : FixedArray[UInt64]
  priv castling : FixedArray[UInt64]
  priv ep_file : FixedArray[UInt64]
  priv side : UInt64
} derive(@debug.Debug)

///|
pub extend Zobrist with @debug.Debug::{to_repr}

///|
/// The SplitMix64 finalizer.
fn splitmix64(value : UInt64) -> UInt64 {
  let mut z = value + 0x9E3779B97F4A7C15UL
  z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9UL
  z = (z ^ (z >> 27)) * 0x94D049BB133111EBUL
  z ^ (z >> 31)
}

///|
fn fill_keys(table : FixedArray[UInt64], base : UInt64) -> Unit {
  for index = 0; index < table.length(); index = index + 1 {
    table[index] = splitmix64(base + index.to_uint64())
  }
}

///|
/// Builds the key tables.
pub fn Zobrist::new() -> Zobrist {
  let pieces = FixedArray::make(12 * 64, 0UL)
  fill_keys(pieces, 0x9E3779B97F4A7C15UL)
  let castling = FixedArray::make(16, 0UL)
  fill_keys(castling, 0xD1B54A32D192ED03UL)
  let ep_file = FixedArray::make(8, 0UL)
  fill_keys(ep_file, 0x94D049BB133111EBUL)
  let side = splitmix64(0x2545F4914F6CDD1DUL)
  { pieces, castling, ep_file, side, }
}

///|
/// The key of one piece on one square.
pub fn Zobrist::piece_key(
  self : Zobrist,
  piece : Piece,
  square : Square,
) -> UInt64 {
  let index = piece_index(piece.color(), piece.kind()) * 64 + square.index()
  self.pieces[index]
}

///|
/// The key of one castling right combination.
pub fn Zobrist::castling_key(self : Zobrist, rights : CastlingRights) -> UInt64 {
  self.castling[rights.index()]
}

///|
/// The key of an en passant file.
pub fn Zobrist::en_passant_key(self : Zobrist, file : Int32) -> UInt64 {
  self.ep_file[file]
}

///|
/// The key that marks black to move.
pub fn Zobrist::side_key(self : Zobrist) -> UInt64 {
  self.side
}

///|
/// Computes the key of a position.
///
/// Two positions that differ only in the move number usually share a key,
/// which is what repetition detection needs.
pub fn Zobrist::hash(self : Zobrist, position : Position) -> UInt64 {
  let mut key = 0UL
  for index = 0; index < 12; index = index + 1 {
    let mut bits = position.pieces[index]
    while bits != 0UL {
      let square = bits.ctz()
      key = key ^ self.pieces[index * 64 + square]
      bits = bits ^ (1UL << square)
    }
  }
  key = key ^ self.castling[position.castling.index()]
  match position.ep_square {
    Some(square) => key = key ^ self.ep_file[square.file()]
    None => ()
  }
  match position.turn {
    White => ()
    Black => key = key ^ self.side
  }
  key
}

///|
/// The shared key tables used by `Position::zobrist_hash`.
let default_zobrist : Zobrist = Zobrist::new()

///|
/// Computes the position key with the shared key tables.
pub fn Position::zobrist_hash(self : Position) -> UInt64 {
  default_zobrist.hash(self)
}
