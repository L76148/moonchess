///|
/// A board square, encoded as `rank * 8 + file`.
///
/// Index `0` is `a1` and index `63` is `h8`. The layout matches the
/// little-endian rank-file order used by `Bitboard`, so bit `i` always refers
/// to `Square(i)`.
pub(all) struct Square(Int32) derive(Eq, @debug.Debug)

///|
pub extend Square with Eq::{equal, not_equal}

///|
pub extend Square with @debug.Debug::{to_repr}

///|
pub extend Square with Show::{to_string, output}

///|
pub impl Show for Square with fn output(self, logger) {
  logger.write_char(Square::file_char(self.file()))
  logger.write_char(Square::rank_char(self.rank()))
}

///|
/// The raw index of the square in `0..=63`.
pub fn Square::index(self : Square) -> Int32 {
  self.0
}

///|
/// The file of the square, `0` for `a` and `7` for `h`.
pub fn Square::file(self : Square) -> Int32 {
  self.0 % 8
}

///|
/// The rank of the square, `0` for rank `1` and `7` for rank `8`.
pub fn Square::rank(self : Square) -> Int32 {
  self.0 / 8
}

///|
/// Builds a square from a file (`0` is `a`) and a rank (`0` is rank `1`).
pub fn Square::make(file : Int32, rank : Int32) -> Square {
  Square(rank * 8 + file)
}

///|
/// Wraps an index in `0..=63`, or returns `None` when it is out of range.
pub fn Square::from_index(index : Int32) -> Square? {
  if index >= 0 && index < 64 {
    Some(Square(index))
  } else {
    None
  }
}

///|
/// The file letter for a file index in `0..=7`.
pub fn Square::file_char(file : Int32) -> Char {
  ('a'.to_int() + file).to_char().unwrap()
}

///|
/// The rank digit for a rank index in `0..=7`.
pub fn Square::rank_char(rank : Int32) -> Char {
  ('1'.to_int() + rank).to_char().unwrap()
}

///|
/// Builds a square from algebraic coordinates such as `e4`.
pub fn Square::from_file_rank(file : Char, rank : Char) -> Square? {
  if file >= 'a' && file <= 'h' && rank >= '1' && rank <= '8' {
    Some(
      Square::make(file.to_int() - 'a'.to_int(), rank.to_int() - '1'.to_int()),
    )
  } else {
    None
  }
}

///|
/// Parses an algebraic square name such as `e4` or `h8`.
pub fn Square::parse(text : String) -> Square? {
  if text.length() != 2 {
    return None
  }
  match (text.get_char(0), text.get_char(1)) {
    (Some(file), Some(rank)) => Square::from_file_rank(file, rank)
    _ => None
  }
}

///|
/// Moves the square by a file and rank delta, or returns `None` when the
/// result would leave the board.
pub fn Square::offset(
  self : Square,
  file_delta : Int32,
  rank_delta : Int32,
) -> Square? {
  let file = self.file() + file_delta
  let rank = self.rank() + rank_delta
  if file >= 0 && file < 8 && rank >= 0 && rank < 8 {
    Some(Square::make(file, rank))
  } else {
    None
  }
}

///|
/// Whether the square belongs to the light squares of the board.
pub fn Square::is_light(self : Square) -> Bool {
  (self.file() + self.rank()) % 2 == 1
}

///|
/// All 64 squares in index order.
pub fn Square::all() -> Array[Square] {
  let out : Array[Square] = []
  for index = 0; index < 64; index = index + 1 {
    out.push(Square(index))
  }
  out
}
