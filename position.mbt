///|
/// A complete chess position.
///
/// The board is stored as twelve bitboards, one per colour and piece kind.
/// Inside each bitboard, bit `i` set means `Square(i)` holds that piece. The
/// remaining fields carry the state that FEN records: the side to move, the
/// castling rights, the en passant target, the halfmove clock and the move
/// number.
pub(all) struct Position {
  priv pieces : FixedArray[UInt64]
  priv turn : Color
  priv castling : CastlingRights
  priv ep_square : Square?
  priv halfmove_clock : Int32
  priv fullmove_number : Int32
} derive(Eq, @debug.Debug)

///|
pub extend Position with Eq::{equal, not_equal}

///|
pub extend Position with @debug.Debug::{to_repr}

///|
/// The index of the bitboard that stores one colour and piece kind.
fn piece_index(color : Color, kind : PieceKind) -> Int32 {
  color.index() * 6 + kind.index()
}

///|
/// The FEN document of the standard starting position.
pub fn start_fen() -> String {
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
}

///|
/// Builds a position from raw fields.
///
/// `pieces` must hold twelve bitboards in colour-major order: the six white
/// kinds first, then the six black kinds, each ordered pawn, knight, bishop,
/// rook, queen, king.
pub fn Position::new(
  pieces : FixedArray[UInt64],
  turn : Color,
  castling : CastlingRights,
  ep_square : Square?,
  halfmove_clock : Int32,
  fullmove_number : Int32,
) -> Position {
  { pieces, turn, castling, ep_square, halfmove_clock, fullmove_number, }
}

///|
/// A position with an empty board, white to move and no castling rights.
pub fn Position::empty() -> Position {
  Position::new(
    FixedArray::make(12, 0UL),
    White,
    CastlingRights::none(),
    None,
    0,
    1,
  )
}

///|
/// The standard starting position.
pub fn Position::startpos() -> Position {
  let pieces = FixedArray::make(12, 0UL)
  let white_back = 0x0000000000000081UL
  let black_back = 0x8100000000000000UL
  pieces[piece_index(White, Rook)] = white_back
  pieces[piece_index(White, Knight)] = 0x0000000000000042UL
  pieces[piece_index(White, Bishop)] = 0x0000000000000024UL
  pieces[piece_index(White, Queen)] = 0x0000000000000008UL
  pieces[piece_index(White, King)] = 0x0000000000000010UL
  pieces[piece_index(White, Pawn)] = 0x000000000000FF00UL
  pieces[piece_index(Black, Rook)] = black_back
  pieces[piece_index(Black, Knight)] = 0x4200000000000000UL
  pieces[piece_index(Black, Bishop)] = 0x2400000000000000UL
  pieces[piece_index(Black, Queen)] = 0x0800000000000000UL
  pieces[piece_index(Black, King)] = 0x1000000000000000UL
  pieces[piece_index(Black, Pawn)] = 0x00FF000000000000UL
  Position::new(pieces, White, CastlingRights::all(), None, 0, 1)
}

///|
/// The side that is to move.
pub fn Position::turn(self : Position) -> Color {
  self.turn
}

///|
/// The castling rights that are still available.
pub fn Position::castling(self : Position) -> CastlingRights {
  self.castling
}

///|
/// The en passant target square, when the previous move was a double pawn
/// push.
pub fn Position::en_passant(self : Position) -> Square? {
  self.ep_square
}

///|
/// The number of halfmoves since the last pawn move or capture.
pub fn Position::halfmove_clock(self : Position) -> Int32 {
  self.halfmove_clock
}

///|
/// The number of the move that is about to be played, starting at `1`.
pub fn Position::fullmove_number(self : Position) -> Int32 {
  self.fullmove_number
}

///|
/// The squares occupied by one colour and piece kind.
pub fn Position::pieces_of(
  self : Position,
  color : Color,
  kind : PieceKind,
) -> Bitboard {
  Bitboard::from_u64(self.pieces[piece_index(color, kind)])
}

///|
/// The squares occupied by one colour.
pub fn Position::color_occupancy(self : Position, color : Color) -> Bitboard {
  let mut bits = 0UL
  for kind_index = 0; kind_index < 6; kind_index = kind_index + 1 {
    bits = bits | self.pieces[color.index() * 6 + kind_index]
  }
  Bitboard::from_u64(bits)
}

///|
/// Every occupied square.
pub fn Position::occupancy(self : Position) -> Bitboard {
  self.color_occupancy(White).union(self.color_occupancy(Black))
}

///|
/// The piece on a square, or `None` when the square is empty.
pub fn Position::piece_at(self : Position, square : Square) -> Piece? {
  let mask = 1UL << square.index()
  for index = 0; index < 12; index = index + 1 {
    if (self.pieces[index] & mask) != 0UL {
      let color = if index < 6 { White } else { Black }
      let kind = PieceKind::from_index(index % 6).unwrap()
      return Some(Piece::new(color, kind))
    }
  }
  None
}

///|
/// Whether the square holds no piece.
pub fn Position::is_empty_square(self : Position, square : Square) -> Bool {
  match self.piece_at(square) {
    Some(_) => false
    None => true
  }
}

///|
/// The square of one colour's king, or `None` when the king is missing.
pub fn Position::king_square(self : Position, color : Color) -> Square? {
  self.pieces_of(color, King).first()
}

///|
/// The number of pieces on the board.
pub fn Position::piece_count(self : Position) -> Int32 {
  self.occupancy().count()
}
