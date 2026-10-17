# MoonChess

[![CI](https://github.com/L76148/moonchess/actions/workflows/ci.yml/badge.svg)](https://github.com/L76148/moonchess/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-L76148%2Fmoonchess-blue)](https://mooncakes.io/docs/L76148/moonchess)

A pure-MoonBit chess core: bitboards, FEN, move generation and Zobrist keys,
with PGN, SAN and UCI support following in later increments.

Published as [`L76148/moonchess`](https://mooncakes.io/docs/L76148/moonchess)
and developed at <https://github.com/L76148/moonchess>.

## Why

`mooncakes.io` already ships Chinese chess (`xiangqi`) packages, but the
ecosystem has no international chess library and nothing that reads or writes
the standard chess file formats. Anything that wants to replay a PGN game,
index a puzzle database, validate a position string or drive an engine over
UCI has to start from a board representation.

This module supplies that representation as a small, dependency-light library:
a 64-bit board layout, a strict FEN reader and writer, attack and move
generation, an ASCII/Unicode board renderer and deterministic Zobrist keys.
Legal move filtering, perft counters, SAN, PGN, EPD and UCI follow as
separately verified increments.

## Status

The project is developed one capability at a time.

| Capability | State |
| --- | --- |
| Square, colour, piece and castling-rights types | done |
| 64-bit `Bitboard` with rank/file masks, popcount, iteration | done |
| `Position` with twelve piece bitboards and FEN state | done |
| Strict FEN reader and canonical writer | done |
| ASCII and Unicode board rendering | done |
| Deterministic Zobrist keys | done |
| Step (knight, king, pawn) and slider (rook, bishop, queen) attacks | done |
| Attack maps, attacker lookups and check detection | done |
| Pseudo-legal move generation, castling and en passant | done |
| Applying a move and updating all FEN state | done |
| Legal move filtering, including castling and en passant edge cases | done |
| Perft node counters | next |
| Game status and SAN | planned |
| PGN and EPD | planned |
| UCI move notation and a richer CLI | planned |

## Install

```text
moon add L76148/moonchess
```

## Use

Parse and inspect a position:

```text
let position = @moonchess.Position::from_fen(
  "r3k2r/8/8/3pP3/8/8/8/R3K2R w Kq d6 0 12",
)
position.turn()               // @moonchess.White
position.en_passant()         // Some(Square of d6)
position.castling().to_fen()  // "Kq"
position.piece_count()        // 8
```

Read a position without raising:

```text
match @moonchess.Position::try_from_fen(input) {
  Ok(position) => println(position.to_fen())
  Err(error) => println("error: " + error.message())
}
```

Generate moves and ask about attacks:

```text
let moves = position.pseudo_legal_moves()          // Array[Move]
moves.length()                                     // 20 in the start position
position.legal_moves()                             // the legal subset
position.is_legal(moves[0])                        // Bool
position.pseudo_legal_moves_from(e2)               // moves from one square
position.in_check(position.turn())                 // Bool
position.is_attacked(d5, @moonchess.White)         // Bool
position.attackers_to(d5, @moonchess.White)        // Bitboard of attackers
moves[0].to_uci()                                  // "e1g1", "e7e8q", ...
```

Work with bitboards and attack sets:

```text
let pawns = position.pieces_of(@moonchess.White, @moonchess.Pawn)
pawns.count()                                  // number of white pawns
pawns.squares()                                // squares in index order

@moonchess.Bitboard::knight_attacks(sq)        // eight targets at most
@moonchess.Bitboard::rook_attacks(sq, occupancy)
@moonchess.Bitboard::bishop_attacks(sq, occupancy)
@moonchess.Bitboard::queen_attacks(sq, occupancy)
@moonchess.Bitboard::rank_mask(0)              // the first rank
```

Compute a repetition key:

```text
position.zobrist_hash()  // ignores the halfmove clock and move number
```

The root package exports `Color`, `PieceKind`, `Piece`, `Square`, `Bitboard`,
`CastlingRights`, `Position`, `Move`, `MoveKind`, `Zobrist` and `FenError`.

## Command line

```text
moon run cmd/moonchess                            # the starting position
moon run cmd/moonchess -- board "<FEN>"           # draw any position
moon run cmd/moonchess -- unicode "<FEN>"         # Unicode piece symbols
moon run cmd/moonchess -- fen "<FEN>"             # canonical six-field FEN
moon run cmd/moonchess -- moves "<FEN>"           # the pseudo-legal move list
moon run cmd/moonchess -- validate "<FEN>"        # validity summary
```

The `--` separates the MoonBit arguments from the program arguments.

## Design notes

**Board layout.** Square index `0` is `a1` and `63` is `h8`; a square index is
`rank * 8 + file`. Bit `i` of a bitboard therefore always refers to that same
square, which keeps board scans and bit masks in step.

**Twelve bitboards.** A position stores the six white piece kinds followed by
the six black kinds, so `Position::pieces_of(color, kind)` is an array lookup
and colour occupancy is a three-way union over six words.

**Attacks include the blocker.** `rook_attacks`, `bishop_attacks` and
`queen_attacks` walk each ray until an occupied square and include it, so the
blocking piece is always part of the set. Move generation removes the mover's
own pieces from the result, which keeps "capture the blocker" free and avoids
a second pass over the board.

**Pseudo-legal by contract.** `pseudo_legal_moves` ignores king safety, so a
pinned piece still reports its moves and castling only checks the right and
the empty path. The name says so, and the CLI says so. Legal filtering is layered on top
of `make_move`: a move is legal when the mover's king is not attacked
afterwards, plus the castling transit rules. Perft node counts are the
acceptance test for that layer.

**Strict FEN.** Four to six fields are accepted; the clock fields default to
`0` and `1` when omitted, and repeated spaces are tolerated. Everything else
is rejected with a structured `FenError`, including a board that does not hold
exactly one king per colour. Writing back always produces the six-field form,
so reading and writing a canonical document round trips byte for byte.

**Deterministic Zobrist keys.** The key tables are derived from fixed seeds
with the SplitMix64 finalizer rather than a random source, so a key is
reproducible across runs and backends. The keys deliberately ignore the
halfmove clock and move number, which is the definition repetition detection
needs.

## Quality gates

```text
moon check --target all --deny-warn
moon fmt --check
moon test --target wasm --deny-warn
moon test --target wasm-gc --deny-warn
```

The current increment is covered by 77 tests spanning square arithmetic, piece
and colour conversions, bitboard algebra and diagrams, FEN round trips, every
FEN error path, board rendering, castling-rights algebra, Zobrist key
separation, step and slider attack sets, blocker handling, attacker lookups,
check detection, move notation, applying a move, and pseudo-legal and legal
generation for pawns, promotions, en passant, castling, pins and check. The same suites pass on the `wasm` and
`wasm-gc` backends, and the sources are checked warning-free on every
configured backend.

## Roadmap

1. **Core model and FEN** 鈥?the types, the bitboards, the FEN reader and
   writer, board rendering and Zobrist keys.
2. **Move generation** — attacks, pseudo-legal generation, applying a move and legal filtering (done), then perft counters checked against published node counts.
3. **Game status and SAN** 鈥?check, checkmate, stalemate, insufficient
   material, the fifty-move rule, threefold repetition, and SAN parsing and
   generation with disambiguation.
4. **PGN and EPD** 鈥?a tag-pair and movetext reader, comment and variation
   handling, and an EPD reader and writer.
5. **UCI and tooling** 鈥?UCI move notation, a richer command line with a
   `perft`, `pgn` and `move` command, an example corpus and reference
   documentation.

### Explicitly out of scope

Shredder-FEN variants, Chess960, search and evaluation engines, opening books,
endgame tablebases, GUIs, network play and chess variants other than standard
chess are not planned. The library is a format and rules core, not an engine.

## Build from source

```text
git clone https://github.com/L76148/moonchess
cd moonchess
moon check --target all --deny-warn
moon test --deny-warn
moon run cmd/moonchess -- moves
```

## License

Apache-2.0. The rules follow the FIDE Laws of Chess, the FEN and PGN
descriptions come from the PGN standard (Portable Game Notation Specification
and Implementation Guide), and the hashing scheme follows Albert Zobrist's
description of Zobrist hashing; no third-party source code is copied. See
`LICENSE`.