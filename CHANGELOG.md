# Changelog

## 0.1.1

- Documentation patch: the README and the package page now describe legal
  filtering as layered on `make_move` instead of a planned `unmake`.
- No API or behaviour changes.

## 0.1.0

### Core model and FEN

- Square, colour, piece, piece-kind and castling-rights types with algebraic
  square parsing and rendering.
- `Bitboard`: rank and file masks, union/intersection/difference, popcount,
  lowest square, ascending iteration and an ASCII diagram.
- `Position`: twelve piece bitboards plus side to move, castling rights, en
  passant target, halfmove clock and move number.
- Strict FEN reader and canonical writer: four to six fields, default clocks,
  repeated whitespace, twelve structured error variants, byte-for-byte
  round trips of canonical documents, exactly one king per colour enforced.
- ASCII and Unicode board rendering.
- Deterministic Zobrist keys derived from fixed SplitMix64 seeds.

### Attacks and move generation

- Step attacks for knights, kings and pawns; ray attacks for rooks, bishops
  and queens. Each ray includes the first blocked square.
- Attack maps, attacker lookups and check detection.
- Pseudo-legal move generation for every piece, including double pawn pushes,
  promotions, en passant and castling.
- `make_move`, which updates the piece bitboards, captures, the en passant
  pawn, promotions, the castling rook, castling rights, the en passant target,
  the halfmove clock and the move number.
- `legal_moves` and `is_legal`: king safety after the move, castling through,
  out of and into check, and en passant discovered checks.

### Tooling

- `cmd/moonchess` with `board`, `unicode`, `fen`, `moves`, `validate` and
  `help`.
- GitHub Actions workflow covering the all-backend check, formatting, wasm and
  wasm-gc tests, interface drift and a command line smoke test.