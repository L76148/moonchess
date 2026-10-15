///|
/// The Unicode chess symbols, white pieces first.
fn unicode_piece(piece : Piece) -> String {
  match piece.color() {
    White =>
      match piece.kind() {
        King => "♔"
        Queen => "♕"
        Rook => "♖"
        Bishop => "♗"
        Knight => "♘"
        Pawn => "♙"
      }
    Black =>
      match piece.kind() {
        King => "♚"
        Queen => "♛"
        Rook => "♜"
        Bishop => "♝"
        Knight => "♞"
        Pawn => "♟"
      }
  }
}

///|
/// Renders the board as an eight by eight diagram using FEN letters,
/// upper-case for white.
pub fn Position::to_ascii(self : Position) -> String {
  let buf = StringBuilder()
  for row = 0; row < 8; row = row + 1 {
    let rank = 7 - row
    buf.write_char(Square::rank_char(rank))
    buf.write_char(' ')
    for file = 0; file < 8; file = file + 1 {
      match self.piece_at(Square::make(file, rank)) {
        Some(piece) => buf.write_char(piece.fen_char())
        None => buf.write_char('.')
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

///|
/// Renders the board as an eight by eight diagram using the Unicode chess
/// symbols.
pub fn Position::to_unicode(self : Position) -> String {
  let buf = StringBuilder()
  for row = 0; row < 8; row = row + 1 {
    let rank = 7 - row
    buf.write_char(Square::rank_char(rank))
    buf.write_char(' ')
    for file = 0; file < 8; file = file + 1 {
      match self.piece_at(Square::make(file, rank)) {
        Some(piece) => buf.write_string(unicode_piece(piece))
        None => buf.write_string("·")
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
