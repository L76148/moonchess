///|
/// The text printed for `moonchess help`.
let usage : String = "moonchess - a MoonBit chess core\n\nUsage: moonchess <command> [FEN]\n\nCommands:\n  board [FEN]      draw the board with FEN letters (default)\n  unicode [FEN]    draw the board with Unicode pieces\n  fen [FEN]        print the canonical six-field FEN\n  moves [FEN]      list the pseudo-legal moves of the side to move\n  validate [FEN]   report whether a FEN document is valid\n  help             show this message\n\nWhen no FEN is given the standard starting position is used."

///|
/// Joins the tokens of a FEN document back into one string.
fn join_tokens(tokens : Array[String], from : Int32) -> String {
  let buf = StringBuilder()
  for index = from; index < tokens.length(); index = index + 1 {
    if index > from {
      buf.write_char(' ')
    }
    buf.write_string(tokens[index])
  }
  buf.to_string()
}

///|
fn main {
  let raw = @env.args()
  let args : Array[String] = []
  for index = 1; index < raw.length(); index = index + 1 {
    args.push(raw[index])
  }
  let command = if args.length() == 0 { "board" } else { args[0] }
  let fen_text = if args.length() <= 1 {
    @chess.start_fen()
  } else {
    join_tokens(args, 1)
  }
  match command {
    "help" | "--help" | "-h" => println(usage)
    "board" => draw(fen_text, false)
    "unicode" => draw(fen_text, true)
    "fen" => print_canonical_fen(fen_text)
    "moves" => list_moves(fen_text)
    "validate" => validate(fen_text)
    _ => {
      println("error: unknown command '" + command + "'")
      println(usage)
      abort("unknown command")
    }
  }
}

///|
/// Draws one position, optionally with the Unicode piece symbols.
fn draw(fen_text : String, unicode : Bool) -> Unit {
  match @chess.Position::try_from_fen(fen_text) {
    Ok(position) => {
      if unicode {
        println(position.to_unicode())
      } else {
        println(position.to_ascii())
      }
      println("")
      println(position.to_fen())
    }
    Err(error) => report(error)
  }
}

///|
/// Prints the canonical six-field FEN of one document.
fn print_canonical_fen(fen_text : String) -> Unit {
  match @chess.Position::try_from_fen(fen_text) {
    Ok(position) => println(position.to_fen())
    Err(error) => report(error)
  }
}

///|
/// Lists the pseudo-legal moves of the side to move, twelve to a line.
fn list_moves(fen_text : String) -> Unit {
  match @chess.Position::try_from_fen(fen_text) {
    Ok(position) => {
      let moves = position.pseudo_legal_moves()
      let buf = StringBuilder()
      buf.write_string(position.turn().name())
      buf.write_string(" to move, ")
      buf.write_string(moves.length().to_string())
      buf.write_string(" pseudo-legal moves, in check: ")
      buf.write_string(position.in_check(position.turn()).to_string())
      println(buf.to_string())
      let lines = StringBuilder()
      let mut column = 0
      for candidate in moves {
        if column == 12 {
          lines.write_char('\n')
          column = 0
        }
        lines.write_string(candidate.to_uci())
        lines.write_char(' ')
        column = column + 1
      }
      println(lines.to_string())
    }
    Err(error) => report(error)
  }
}

///|
/// Reports whether a FEN document is valid and summarises it.
fn validate(fen_text : String) -> Unit {
  match @chess.Position::try_from_fen(fen_text) {
    Ok(position) => {
      let summary = StringBuilder()
      summary.write_string("valid: ")
      summary.write_string(position.piece_count().to_string())
      summary.write_string(" pieces, ")
      summary.write_string(position.turn().name())
      summary.write_string(" to move, ")
      summary.write_string(position.castling().to_fen())
      summary.write_string(" castling")
      println(summary.to_string())
    }
    Err(error) => report(error)
  }
}

///|
/// Prints a FEN error and stops the program.
fn report(error : @chess.FenError) -> Unit {
  println("error: " + error.message())
  abort("invalid FEN document")
}
