///|
/// The castling rights that are still available in a position.
pub(all) struct CastlingRights {
  white_kingside : Bool
  white_queenside : Bool
  black_kingside : Bool
  black_queenside : Bool
} derive(Eq, @debug.Debug)

///|
pub extend CastlingRights with Eq::{equal, not_equal}

///|
pub extend CastlingRights with @debug.Debug::{to_repr}

///|
pub extend CastlingRights with Show::{to_string, output}

///|
pub impl Show for CastlingRights with fn output(self, logger) {
  logger.write_string(self.to_fen())
}

///|
/// No side may castle.
pub fn CastlingRights::none() -> CastlingRights {
  {
    white_kingside: false,
    white_queenside: false,
    black_kingside: false,
    black_queenside: false,
  }
}

///|
/// Both sides may castle on both wings.
pub fn CastlingRights::all() -> CastlingRights {
  {
    white_kingside: true,
    white_queenside: true,
    black_kingside: true,
    black_queenside: true,
  }
}

///|
/// Whether the colour may castle on the king's side.
pub fn CastlingRights::has_kingside(
  self : CastlingRights,
  color : Color,
) -> Bool {
  match color {
    White => self.white_kingside
    Black => self.black_kingside
  }
}

///|
/// Whether the colour may castle on the queen's side.
pub fn CastlingRights::has_queenside(
  self : CastlingRights,
  color : Color,
) -> Bool {
  match color {
    White => self.white_queenside
    Black => self.black_queenside
  }
}

///|
/// Returns a copy with the king's side right of one colour set.
pub fn CastlingRights::with_kingside(
  self : CastlingRights,
  color : Color,
  value : Bool,
) -> CastlingRights {
  match color {
    White => { ..self, white_kingside: value, }
    Black => { ..self, black_kingside: value, }
  }
}

///|
/// Returns a copy with the queen's side right of one colour set.
pub fn CastlingRights::with_queenside(
  self : CastlingRights,
  color : Color,
  value : Bool,
) -> CastlingRights {
  match color {
    White => { ..self, white_queenside: value, }
    Black => { ..self, black_queenside: value, }
  }
}

///|
/// Whether no colour may castle at all.
pub fn CastlingRights::is_empty(self : CastlingRights) -> Bool {
  self == CastlingRights::none()
}

///|
/// A four-bit index over the four rights, used for Zobrist keys.
pub fn CastlingRights::index(self : CastlingRights) -> Int32 {
  let mut value = 0
  if self.white_kingside {
    value = value | 1
  }
  if self.white_queenside {
    value = value | 2
  }
  if self.black_kingside {
    value = value | 4
  }
  if self.black_queenside {
    value = value | 8
  }
  value
}

///|
/// The FEN castling field, either `-` or a subset of `KQkq` in that order.
pub fn CastlingRights::to_fen(self : CastlingRights) -> String {
  let buf = StringBuilder()
  if self.white_kingside {
    buf.write_char('K')
  }
  if self.white_queenside {
    buf.write_char('Q')
  }
  if self.black_kingside {
    buf.write_char('k')
  }
  if self.black_queenside {
    buf.write_char('q')
  }
  if buf.to_string().length() == 0 {
    "-"
  } else {
    buf.to_string()
  }
}
