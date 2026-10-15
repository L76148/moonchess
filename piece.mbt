///|
/// The side a piece belongs to.
pub(all) enum Color {
  White
  Black
} derive(Eq, @debug.Debug)

///|
pub extend Color with Eq::{equal, not_equal}

///|
pub extend Color with @debug.Debug::{to_repr}

///|
pub extend Color with Show::{to_string, output}

///|
pub impl Show for Color with fn output(self, logger) {
  logger.write_string(Color::name(self))
}

///|
/// The lower-case name of the colour.
pub fn Color::name(self : Color) -> String {
  match self {
    White => "white"
    Black => "black"
  }
}

///|
/// The storage index of the colour, `0` for white and `1` for black.
pub fn Color::index(self : Color) -> Int32 {
  match self {
    White => 0
    Black => 1
  }
}

///|
/// The opposite colour.
pub fn Color::opposite(self : Color) -> Color {
  match self {
    White => Black
    Black => White
  }
}

///|
/// The `w`/`b` character used by FEN and PGN.
pub fn Color::fen_char(self : Color) -> Char {
  match self {
    White => 'w'
    Black => 'b'
  }
}

///|
/// Reads the `w`/`b` character used by FEN and PGN.
pub fn Color::from_fen_char(c : Char) -> Color? {
  match c {
    'w' => Some(White)
    'b' => Some(Black)
    _ => None
  }
}

///|
/// The kind of a chess piece, independent of its colour.
pub(all) enum PieceKind {
  Pawn
  Knight
  Bishop
  Rook
  Queen
  King
} derive(Eq, @debug.Debug)

///|
pub extend PieceKind with Eq::{equal, not_equal}

///|
pub extend PieceKind with @debug.Debug::{to_repr}

///|
pub extend PieceKind with Show::{to_string, output}

///|
pub impl Show for PieceKind with fn output(self, logger) {
  logger.write_string(PieceKind::name(self))
}

///|
/// The lower-case English name of the piece kind.
pub fn PieceKind::name(self : PieceKind) -> String {
  match self {
    Pawn => "pawn"
    Knight => "knight"
    Bishop => "bishop"
    Rook => "rook"
    Queen => "queen"
    King => "king"
  }
}

///|
/// The storage index of the piece kind, `0` for a pawn and `5` for a king.
pub fn PieceKind::index(self : PieceKind) -> Int32 {
  match self {
    Pawn => 0
    Knight => 1
    Bishop => 2
    Rook => 3
    Queen => 4
    King => 5
  }
}

///|
/// Maps a storage index in `0..=5` back to a piece kind.
pub fn PieceKind::from_index(index : Int32) -> PieceKind? {
  match index {
    0 => Some(Pawn)
    1 => Some(Knight)
    2 => Some(Bishop)
    3 => Some(Rook)
    4 => Some(Queen)
    5 => Some(King)
    _ => None
  }
}

///|
/// The lower-case piece letter used by FEN and SAN.
pub fn PieceKind::fen_char(self : PieceKind) -> Char {
  match self {
    Pawn => 'p'
    Knight => 'n'
    Bishop => 'b'
    Rook => 'r'
    Queen => 'q'
    King => 'k'
  }
}

///|
/// Reads a FEN piece letter, accepting either case.
pub fn PieceKind::from_fen_char(c : Char) -> PieceKind? {
  match c {
    'p' | 'P' => Some(Pawn)
    'n' | 'N' => Some(Knight)
    'b' | 'B' => Some(Bishop)
    'r' | 'R' => Some(Rook)
    'q' | 'Q' => Some(Queen)
    'k' | 'K' => Some(King)
    _ => None
  }
}

///|
/// A coloured piece.
pub(all) struct Piece {
  color : Color
  kind : PieceKind
} derive(Eq, @debug.Debug)

///|
pub extend Piece with Eq::{equal, not_equal}

///|
pub extend Piece with @debug.Debug::{to_repr}

///|
pub extend Piece with Show::{to_string, output}

///|
pub impl Show for Piece with fn output(self, logger) {
  logger.write_string(self.color.name() + " " + self.kind.name())
}

///|
pub fn Piece::new(color : Color, kind : PieceKind) -> Piece {
  { color, kind, }
}

///|
pub fn Piece::color(self : Piece) -> Color {
  self.color
}

///|
pub fn Piece::kind(self : Piece) -> PieceKind {
  self.kind
}

///|
/// The FEN letter of the piece, upper-case for white and lower-case for black.
pub fn Piece::fen_char(self : Piece) -> Char {
  let c = self.kind.fen_char()
  match self.color {
    White => (c.to_int() - 32).to_char().unwrap()
    Black => c
  }
}

///|
/// Reads a FEN piece letter, deriving the colour from the letter's case.
pub fn Piece::from_fen_char(c : Char) -> Piece? {
  match PieceKind::from_fen_char(c) {
    Some(kind) => {
      let color = if c >= 'A' && c <= 'Z' { White } else { Black }
      Some(Piece::new(color, kind))
    }
    None => None
  }
}
