///|
/// A set of squares stored in a 64-bit word.
///
/// Bit `i` corresponds to `Square(i)`, so bit `0` is `a1` and bit `63` is
/// `h8`.
pub(all) struct Bitboard(UInt64) derive(Eq, @debug.Debug)

///|
pub extend Bitboard with Eq::{equal, not_equal}

///|
pub extend Bitboard with @debug.Debug::{to_repr}

///|
pub extend Bitboard with Show::{to_string, output}

///|
pub impl Show for Bitboard with fn output(self, logger) {
  logger.write_string(Bitboard::to_ascii(self))
}

///|
/// The empty square set.
pub fn Bitboard::empty() -> Bitboard {
  Bitboard(0UL)
}

///|
/// The square set containing every square.
pub fn Bitboard::full() -> Bitboard {
  Bitboard(0xFFFFFFFFFFFFFFFFUL)
}

///|
/// Wraps a raw word.
pub fn Bitboard::from_u64(value : UInt64) -> Bitboard {
  Bitboard(value)
}

///|
/// The raw word behind the square set.
pub fn Bitboard::to_u64(self : Bitboard) -> UInt64 {
  self.0
}

///|
/// A set containing exactly one square.
pub fn Bitboard::single(square : Square) -> Bitboard {
  Bitboard(1UL << square.index())
}

///|
/// Every square of one file, `0` for `a`.
pub fn Bitboard::file_mask(file : Int32) -> Bitboard {
  Bitboard(0x0101010101010101UL << file)
}

///|
/// Every square of one rank, `0` for rank `1`.
pub fn Bitboard::rank_mask(rank : Int32) -> Bitboard {
  Bitboard(0xFFUL << (rank * 8))
}

///|
/// Whether the square is a member of the set.
pub fn Bitboard::contains(self : Bitboard, square : Square) -> Bool {
  ((self.0 >> square.index()) & 1UL) == 1UL
}

///|
/// Returns a set with the square added.
pub fn Bitboard::set(self : Bitboard, square : Square) -> Bitboard {
  Bitboard(self.0 | (1UL << square.index()))
}

///|
/// Returns a set with the square removed.
pub fn Bitboard::remove(self : Bitboard, square : Square) -> Bitboard {
  Bitboard(self.0 & (1UL << square.index()).lnot())
}

///|
/// The union of two sets.
pub fn Bitboard::union(self : Bitboard, other : Bitboard) -> Bitboard {
  Bitboard(self.0 | other.0)
}

///|
/// The intersection of two sets.
pub fn Bitboard::intersect(self : Bitboard, other : Bitboard) -> Bitboard {
  Bitboard(self.0 & other.0)
}

///|
/// The squares of `self` that are not in `other`.
pub fn Bitboard::difference(self : Bitboard, other : Bitboard) -> Bitboard {
  Bitboard(self.0 & other.0.lnot())
}

///|
/// Whether the set holds no square at all.
pub fn Bitboard::is_empty(self : Bitboard) -> Bool {
  self.0 == 0UL
}

///|
/// The number of squares in the set.
pub fn Bitboard::count(self : Bitboard) -> Int32 {
  self.0.popcnt()
}

///|
/// The lowest square of the set in index order, or `None` when empty.
pub fn Bitboard::first(self : Bitboard) -> Square? {
  if self.0 == 0UL {
    None
  } else {
    Some(Square(self.0.ctz()))
  }
}

///|
/// The squares of the set in ascending index order.
pub fn Bitboard::squares(self : Bitboard) -> Array[Square] {
  let out : Array[Square] = []
  let mut bits = self.0
  while bits != 0UL {
    let index = bits.ctz()
    out.push(Square(index))
    bits = bits ^ (1UL << index)
  }
  out
}

///|
/// Renders the set as an eight by eight diagram, rank `8` first.
pub fn Bitboard::to_ascii(self : Bitboard) -> String {
  let buf = StringBuilder()
  for row = 0; row < 8; row = row + 1 {
    let rank = 7 - row
    buf.write_char(Square::rank_char(rank))
    buf.write_char(' ')
    for file = 0; file < 8; file = file + 1 {
      let square = Square::make(file, rank)
      if self.contains(square) {
        buf.write_char('X')
      } else {
        buf.write_char('.')
      }
      if file < 7 {
        buf.write_char(' ')
      }
    }
    buf.write_char('\n')
  }
  buf.write_string("  a b c d e f g h")
  buf.to_string()
}
