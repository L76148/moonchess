///|
/// The shape of a move, which the board alone cannot infer.
pub(all) enum MoveKind {
  /// A quiet move or an ordinary capture.
  Normal
  /// A two square pawn advance, which sets the en passant target.
  DoublePawnPush
  /// A pawn captures a pawn that has just advanced two squares.
  EnPassant
  /// The king moves from e1 to g1, or from e8 to g8.
  CastleKingside
  /// The king moves from e1 to c1, or from e8 to c8.
  CastleQueenside
  /// A pawn reaches the last rank and becomes a queen, rook, bishop or
  /// knight.
  Promotion
} derive(Eq, @debug.Debug)

///|
pub extend MoveKind with Eq::{equal, not_equal}

///|
pub extend MoveKind with @debug.Debug::{to_repr}

///|
pub extend MoveKind with Show::{to_string, output}

///|
pub impl Show for MoveKind with fn output(self, logger) {
  logger.write_string(MoveKind::name(self))
}

///|
/// The lower-case name of the move shape.
pub fn MoveKind::name(self : MoveKind) -> String {
  match self {
    Normal => "normal"
    DoublePawnPush => "double pawn push"
    EnPassant => "en passant"
    CastleKingside => "castle kingside"
    CastleQueenside => "castle queenside"
    Promotion => "promotion"
  }
}

///|
/// A move between two squares.
///
/// The fields are public because move generation touches them in tight
/// loops. `promotion` is `Some` exactly when `kind` is `Promotion`.
pub(all) struct Move {
  from : Square
  to : Square
  kind : MoveKind
  promotion : PieceKind?
} derive(Eq, @debug.Debug)

///|
pub extend Move with Eq::{equal, not_equal}

///|
pub extend Move with @debug.Debug::{to_repr}

///|
pub extend Move with Show::{to_string, output}

///|
pub impl Show for Move with fn output(self, logger) {
  logger.write_string(Move::to_uci(self))
}

///|
/// Builds a quiet move or an ordinary capture.
pub fn Move::new(from : Square, to : Square) -> Move {
  { from, to, kind: Normal, promotion: None, }
}

///|
/// Builds a two square pawn advance.
pub fn Move::double_push(from : Square, to : Square) -> Move {
  { from, to, kind: DoublePawnPush, promotion: None, }
}

///|
/// Builds an en passant capture into the empty square behind the pawn.
pub fn Move::en_passant(from : Square, to : Square) -> Move {
  { from, to, kind: EnPassant, promotion: None, }
}

///|
/// Builds a king, rook, bishop or queen promotion.
pub fn Move::promotion(from : Square, to : Square, piece : PieceKind) -> Move {
  { from, to, kind: Promotion, promotion: Some(piece), }
}

///|
/// Builds the king move of a castling.
pub fn Move::castle(color : Color, kingside : Bool) -> Move {
  let rank = if color == White { 0 } else { 7 }
  let from = Square::make(4, rank)
  let to = Square::make(if kingside { 6 } else { 2 }, rank)
  {
    from,
    to,
    kind: if kingside {
      CastleKingside
    } else {
      CastleQueenside
    },
    promotion: None,
  }
}

///|
/// The promotion piece, or `None` for a move that does not promote.
pub fn Move::promotion_piece(self : Move) -> PieceKind? {
  self.promotion
}

///|
/// Whether the move promotes.
pub fn Move::is_promotion(self : Move) -> Bool {
  self.kind == Promotion
}

///|
/// Whether the move captures something, directly or in passing.
pub fn Move::is_capture(self : Move, position : Position) -> Bool {
  match self.kind {
    EnPassant => true
    _ =>
      match position.piece_at(self.to) {
        Some(_) => true
        None => false
      }
  }
}

///|
/// Whether the move castles.
pub fn Move::is_castling(self : Move) -> Bool {
  self.kind == CastleKingside || self.kind == CastleQueenside
}

///|
/// The move in UCI notation, for example `e2e4` or `e7e8q`.
///
/// Castling is written as the king move, which is what UCI sends.
pub fn Move::to_uci(self : Move) -> String {
  let buf = StringBuilder()
  buf.write_string(self.from.to_string())
  buf.write_string(self.to.to_string())
  match self.promotion {
    Some(kind) => buf.write_char(kind.fen_char())
    None => ()
  }
  buf.to_string()
}
