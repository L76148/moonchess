# MoonChess

[![CI](https://github.com/L76148/moonchess/actions/workflows/ci.yml/badge.svg)](https://github.com/L76148/moonchess/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-L76148%2Fmoonchess-blue)](https://mooncakes.io/docs/L76148/moonchess)

A pure-MoonBit chess core: bitboards, FEN, Zobrist keys and, in the coming
increments, legal move generation with PGN, SAN and UCI support.

Published as [`L76148/moonchess`](https://mooncakes.io/docs/L76148/moonchess)
and developed at <https://github.com/L76148/moonchess>.

## Why

`mooncakes.io` already ships Chinese chess (`xiangqi`) packages, but the
ecosystem has no international chess library and nothing that reads or writes
the standard chess file formats. Anything that wants to replay a PGN game,
index a puzzle database, validate a position string or drive an engine over
UCI has to start from a board representation.

This module supplies that representation as a small, dependency-light library:
a 64-bit board layout, a strict FEN reader and writer, an ASCII/Unicode board
renderer and deterministic Zobrist keys. Legal move generation, SAN, PGN, EPD
and UCI follow as separately verified increments.

## Status

The project is developed one capability at a time. This release covers the
first milestone.

| Capability | State |
| --- | --- |
| Square, colour, piece and castling-rights types | done |
| 64-bit `Bitboard` with rank/file masks, popcount, iteration | done |
| `Position` with twelve piece bitboards and FEN state | done |
| Strict FEN reader and canonical writer | done |
| ASCII and Unicode board rendering | done |
| Deterministic Zobrist keys | done |
| Legal move generation, make/unmake, perft | next |
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

Work with bitboards:

```text
let pawns = position.pieces_of(@moonchess.White, @moonchess.Pawn)
pawns.count()                     // number of white pawns
pawns.squares()                   // squares in index order
pawns.contains(@moonchess.Square::parse("e4").unwrap())
```

Compute a repetition-friendly key:

```text
position.zobrist_hash()  // ignores the halfmove clock and move number
```

The root package exports `Color`, `PieceKind`, `Piece`, `Square`, `Bitboard`,
`CastlingRights`, `Position`, `Zobrist` and `FenError`.

## Command line

```text
moon run cmd/moonchess                            # the starting position
moon run cmd/moonchess -- board "<FEN>"           # draw any position
moon run cmd/moonchess -- unicode "<FEN>"         # Unicode piece symbols
moon run cmd/moonchess -- fen "<FEN>"             # canonical six-field FEN
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

The current increment is covered by 36 tests spanning square arithmetic, piece
and colour conversions, bitboard algebra and diagrams, FEN round trips, every
FEN error path, board rendering, castling-rights algebra and Zobrist key
separation. The same suites pass on the `wasm` and `wasm-gc` backends, and the
sources are checked warning-free on every configured backend.

## Roadmap

1. **Core model and FEN** — the types, the bitboards, the FEN reader and
   writer, board rendering and Zobrist keys.
2. **Move generation** — legal moves for every piece, castling, en passant and
   promotion, `make`/`unmake` with incremental keys, and perft counters checked
   against published node counts.
3. **Game status and SAN** — check, checkmate, stalemate, insufficient
   material, the fifty-move rule, threefold repetition, and SAN parsing and
   generation with disambiguation.
4. **PGN and EPD** — a tag-pair and movetext reader, comment and variation
   handling, and an EPD reader and writer.
5. **UCI and tooling** — UCI move notation, a richer command line with a
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
moon run cmd/moonchess
```

## License

Apache-2.0. The rules and file formats follow the FIDE Laws of Chess, the FEN
description in the PGN standard (Portable Game Notation Specification and
Implementation Guide) and the Zobrist hashing scheme described by Albert
Zobrist; no third-party source code is copied. See `LICENSE`.