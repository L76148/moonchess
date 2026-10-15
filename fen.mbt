///|
/// Everything that can be reported while reading a FEN document.
pub(all) suberror FenError {
  Empty
  FieldCount(Int32)
  BoardRankCount(Int32)
  BoardRankWidth(Int32, Int32)
  InvalidPiece(Char)
  InvalidSideToMove(String)
  InvalidCastling(String)
  InvalidEnPassant(String)
  InvalidHalfmoveClock(String)
  InvalidFullmoveNumber(String)
  MissingKing(Color)
  TooManyKings(Color)
} derive(@debug.Debug)

///|
pub extend FenError with @debug.Debug::{to_repr}

///|
/// A human readable explanation of the error.
pub fn FenError::message(self : FenError) -> String {
  match self {
    Empty => "the FEN document is empty"
    FieldCount(count) =>
      "expected between 4 and 6 FEN fields, found " + count.to_string()
    BoardRankCount(count) =>
      "expected 8 board ranks, found " + count.to_string()
    BoardRankWidth(rank, width) =>
      "board rank " +
      (rank + 1).to_string() +
      " describes " +
      width.to_string() +
      " files instead of 8"
    InvalidPiece(c) => "unknown piece letter '" + c.to_string() + "'"
    InvalidSideToMove(text) => "invalid side to move '" + text + "'"
    InvalidCastling(text) => "invalid castling rights '" + text + "'"
    InvalidEnPassant(text) => "invalid en passant square '" + text + "'"
    InvalidHalfmoveClock(text) => "invalid halfmove clock '" + text + "'"
    InvalidFullmoveNumber(text) => "invalid move number '" + text + "'"
    MissingKing(color) => "the " + color.name() + " king is missing"
    TooManyKings(color) =>
      "the position holds more than one " + color.name() + " king"
  }
}

///|
/// Splits a FEN document on spaces, dropping empty fields.
fn fen_fields(fen : String) -> Array[String] {
  let out : Array[String] = []
  for part in fen.split(" ") {
    if part.length() > 0 {
      out.push(part.to_owned())
    }
  }
  out
}

///|
fn split_on(text : String, separator : String) -> Array[String] {
  let out : Array[String] = []
  for part in text.split(separator) {
    out.push(part.to_owned())
  }
  out
}

///|
fn parse_board(bits : FixedArray[UInt64], text : String) -> Unit raise FenError {
  let ranks = split_on(text, "/")
  if ranks.length() != 8 {
    raise BoardRankCount(ranks.length())
  }
  for row = 0; row < 8; row = row + 1 {
    let rank = 7 - row
    let mut file = 0
    for c in ranks[row].to_array() {
      if c >= '1' && c <= '9' {
        file = file + (c.to_int() - '1'.to_int() + 1)
      } else {
        match Piece::from_fen_char(c) {
          Some(piece) => {
            if file >= 8 {
              raise BoardRankWidth(rank, file + 1)
            }
            let index = piece_index(piece.color(), piece.kind())
            bits[index] = bits[index] | (1UL << (rank * 8 + file))
            file = file + 1
          }
          None => raise InvalidPiece(c)
        }
      }
    }
    if file != 8 {
      raise BoardRankWidth(rank, file)
    }
  }
}

///|
fn check_kings(bits : FixedArray[UInt64]) -> Unit raise FenError {
  for color in [White, Black] {
    let kings = bits[piece_index(color, King)].popcnt()
    if kings == 0 {
      raise MissingKing(color)
    }
    if kings > 1 {
      raise TooManyKings(color)
    }
  }
}

///|
fn parse_turn(text : String) -> Color raise FenError {
  match text.get_char(0) {
    Some(c) if text.length() == 1 =>
      match Color::from_fen_char(c) {
        Some(color) => color
        None => raise InvalidSideToMove(text)
      }
    _ => raise InvalidSideToMove(text)
  }
}

///|
fn parse_castling(text : String) -> CastlingRights raise FenError {
  if text == "-" {
    return CastlingRights::none()
  }
  let mut rights = CastlingRights::none()
  for c in text.to_array() {
    match c {
      'K' => rights = rights.with_kingside(White, true)
      'Q' => rights = rights.with_queenside(White, true)
      'k' => rights = rights.with_kingside(Black, true)
      'q' => rights = rights.with_queenside(Black, true)
      _ => raise InvalidCastling(text)
    }
  }
  rights
}

///|
fn parse_en_passant(text : String) -> Square? raise FenError {
  if text == "-" {
    return None
  }
  match Square::parse(text) {
    Some(square) =>
      if square.rank() == 2 || square.rank() == 5 {
        Some(square)
      } else {
        raise InvalidEnPassant(text)
      }
    None => raise InvalidEnPassant(text)
  }
}

///|
fn decimal(text : String) -> Int32? {
  if text.length() == 0 {
    return None
  }
  let mut value = 0
  for c in text.to_array() {
    if c >= '0' && c <= '9' {
      value = value * 10 + (c.to_int() - '0'.to_int())
    } else {
      return None
    }
  }
  Some(value)
}

///|
fn parse_halfmove(text : String) -> Int32 raise FenError {
  match decimal(text) {
    Some(value) => value
    None => raise InvalidHalfmoveClock(text)
  }
}

///|
fn parse_fullmove(text : String) -> Int32 raise FenError {
  match decimal(text) {
    Some(value) if value >= 1 => value
    _ => raise InvalidFullmoveNumber(text)
  }
}

///|
/// Parses a FEN document.
///
/// Four to six fields are accepted. When the clock fields are omitted the
/// halfmove clock defaults to `0` and the move number to `1`. The board must
/// hold exactly one king per colour.
pub fn Position::from_fen(fen : String) -> Position raise FenError {
  let fields = fen_fields(fen)
  if fields.length() == 0 {
    raise Empty
  }
  if fields.length() < 4 || fields.length() > 6 {
    raise FieldCount(fields.length())
  }
  let bits = FixedArray::make(12, 0UL)
  parse_board(bits, fields[0])
  check_kings(bits)
  let turn = parse_turn(fields[1])
  let castling = parse_castling(fields[2])
  let ep_square = parse_en_passant(fields[3])
  let halfmove_clock = if fields.length() >= 5 {
    parse_halfmove(fields[4])
  } else {
    0
  }
  let fullmove_number = if fields.length() >= 6 {
    parse_fullmove(fields[5])
  } else {
    1
  }
  Position::new(
    bits, turn, castling, ep_square, halfmove_clock, fullmove_number,
  )
}

///|
/// Parses a FEN document and returns the error instead of raising it.
pub fn Position::try_from_fen(fen : String) -> Result[Position, FenError] {
  Ok(Position::from_fen(fen)) catch {
    error => Err(error)
  }
}

///|
/// Renders the position as a FEN document with all six fields.
pub fn Position::to_fen(self : Position) -> String {
  let buf = StringBuilder()
  for row = 0; row < 8; row = row + 1 {
    let rank = 7 - row
    let mut empty = 0
    for file = 0; file < 8; file = file + 1 {
      match self.piece_at(Square::make(file, rank)) {
        Some(piece) => {
          if empty > 0 {
            buf.write_char(digit_char(empty))
            empty = 0
          }
          buf.write_char(piece.fen_char())
        }
        None => empty = empty + 1
      }
    }
    if empty > 0 {
      buf.write_char(digit_char(empty))
    }
    if row < 7 {
      buf.write_char('/')
    }
  }
  buf.write_char(' ')
  buf.write_char(self.turn.fen_char())
  buf.write_char(' ')
  buf.write_string(self.castling.to_fen())
  buf.write_char(' ')
  match self.ep_square {
    Some(square) => buf.write_string(square.to_string())
    None => buf.write_char('-')
  }
  buf.write_char(' ')
  buf.write_string(self.halfmove_clock.to_string())
  buf.write_char(' ')
  buf.write_string(self.fullmove_number.to_string())
  buf.to_string()
}

///|
/// The `0`..`8` digit for a small count.
fn digit_char(value : Int32) -> Char {
  ('0'.to_int() + value).to_char().unwrap()
}
