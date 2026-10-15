///|
/// Parses a FEN document or fails the test.
fn parse_fen(fen : String) -> @moonchess.Position {
  match @moonchess.Position::try_from_fen(fen) {
    Ok(position) => position
    Err(error) => abort(error.message())
  }
}

///|
/// Parses an algebraic square name or fails the test.
fn sq(name : String) -> @moonchess.Square {
  match @moonchess.Square::parse(name) {
    Some(square) => square
    None => abort("not a square: " + name)
  }
}

///|
/// The error message of a FEN document, or `"no error"` when it parses.
fn fen_error(fen : String) -> String {
  match @moonchess.Position::try_from_fen(fen) {
    Ok(_) => "no error"
    Err(error) => error.message()
  }
}

///|
/// Whether one move text appears in a list of moves.
fn has_uci(moves : Array[@moonchess.Move], text : String) -> Bool {
  for candidate in moves {
    if candidate.to_uci() == text {
      return true
    }
  }
  false
}

///|
/// How many moves in a list carry one kind.
fn count_kind(
  moves : Array[@moonchess.Move],
  kind : @moonchess.MoveKind,
) -> Int32 {
  let mut total = 0
  for candidate in moves {
    if candidate.kind == kind {
      total = total + 1
    }
  }
  total
}
