# L76148/moonchess

A pure-MoonBit chess core: bitboards, FEN, Zobrist keys and, in the coming
increments, legal move generation with PGN, SAN and UCI support.

The library core has no runtime dependencies. The command line tool uses the
standard `moonbitlang/core/env` package for its arguments.

## Install

```text
moon add L76148/moonchess
```

## Why MoonChess

`mooncakes.io` already ships Chinese chess (`xiangqi`) packages, but the
ecosystem has no international chess library and nothing that reads or writes
the standard chess file formats. Anything that wants to replay a PGN game,
index a puzzle database, validate a position string or drive an engine over
UCI has to start from a board representation. This module supplies that
representation.

## Parse a position

```text
let position = @moonchess.Position::from_fen(
  "r3k2r/8/8/3pP3/8/8/8/R3K2R w Kq d6 0 12",
)
```

`Position::from_fen` accepts four to six fields. The clock fields default to
`0` and `1`, and a document that is missing a king, that names an unknown
piece or that carries a bad en passant square is rejected:

```text
match @moonchess.Position::try_from_fen(input) {
  Ok(position) => println(position.to_fen())
  Err(error) => println("error: " + error.message())
}
```

Every error is a `FenError` value, so callers can match on the failing field
instead of parsing a message.

## Inspect a position

```text
position.turn()                                            // White or Black
position.castling().to_fen()                               // "Kq"
position.en_passant()                                      // Square of d6
position.piece_at(@moonchess.Square::parse("d5").unwrap())  // black pawn
position.king_square(@moonchess.White)                     // Square of e1
position.piece_count()                                     // 8
```

The board renders as a diagram, with FEN letters or with Unicode symbols:

```text
println(position.to_ascii())
println(position.to_unicode())
```

## Work with bitboards

```text
let pawns = position.pieces_of(@moonchess.White, @moonchess.Pawn)
pawns.count()                                  // number of white pawns
pawns.squares()                                // squares in index order
pawns.contains(@moonchess.Square::parse("e5").unwrap())

let rank_one = @moonchess.Bitboard::rank_mask(0)
let file_a = @moonchess.Bitboard::file_mask(0)
rank_one.intersect(file_a).first()             // Square of a1
```

Square index `0` is `a1` and index `63` is `h8`, so bit `i` of a bitboard
always refers to `Square(i)`.

## Generate moves

```text
let moves = position.pseudo_legal_moves()
let legal = position.legal_moves()
position.is_legal(moves[0])
position.pseudo_legal_moves_from(square)
position.in_check(position.turn())
position.is_attacked(square, @moonchess.White)
position.attackers_to(square, @moonchess.White)
```

`pseudo_legal_moves` ignores king safety, as the name says: a pinned piece
still reports its moves, and castling only checks the right and the empty
path. Legality filtering through `make` and `unmake`, and perft counters
checked against published node counts, are the next increment.

Attack sets are built from step offsets for knights, kings and pawns and from
ray walks for rooks, bishops and queens. Each ray stops at the first occupied
square and includes it, so the blocking piece is part of the set:

```text
@moonchess.Bitboard::knight_attacks(square)
@moonchess.Bitboard::rook_attacks(square, occupancy)
```

## Compute a repetition key

```text
position.zobrist_hash()
```

The keys are derived from fixed seeds, so they are reproducible across runs
and backends, and they ignore the halfmove clock and the move number. Two
positions that differ only in those two fields share a key.

## Command line

```text
moon run cmd/moonchess
moon run cmd/moonchess -- board "<FEN>"
moon run cmd/moonchess -- unicode "<FEN>"
moon run cmd/moonchess -- fen "<FEN>"
moon run cmd/moonchess -- moves "<FEN>"
moon run cmd/moonchess -- validate "<FEN>"
```

## Current increment

This release covers two milestones: the square, colour, piece and
castling-rights types, the 64-bit bitboard, the position with its twelve piece
bitboards and FEN state, the strict FEN reader and canonical writer, ASCII and
Unicode rendering and deterministic Zobrist keys; then step and slider attack
generation, attack maps, check detection and pseudo-legal move generation with
castling and en passant; then applying a move and filtering pseudo-legal moves
down to legal ones.

Legal move filtering with make and unmake and perft counters, game status and
SAN, PGN and EPD, and UCI notation are the next increments. Search and
evaluation, opening books, tablebases, GUIs, network play and non-standard
variants are out of scope.

## Quality gates

```text
moon check --target all --deny-warn
moon fmt --check
moon test --target wasm --deny-warn
moon test --target wasm-gc --deny-warn
```

The project is licensed under Apache-2.0.