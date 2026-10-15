///|
test "bitboard membership" {
  let empty = @moonchess.Bitboard::empty()
  assert_true(empty.is_empty())
  assert_eq(empty.count(), 0)
  let set = empty.set(sq("a1")).set(sq("h8"))
  assert_true(set.contains(sq("a1")))
  assert_true(set.contains(sq("h8")))
  assert_eq(set.count(), 2)
  assert_eq(set.remove(sq("a1")).contains(sq("a1")), false)
  assert_eq(set.remove(sq("a1")).count(), 1)
  assert_eq(set.count(), 2)
}

///|
test "bitboard set algebra" {
  let one = @moonchess.Bitboard::single(sq("a1"))
  let two = @moonchess.Bitboard::single(sq("b2"))
  assert_eq(one.union(two).count(), 2)
  assert_eq(one.intersect(two).count(), 0)
  assert_eq(one.union(two).intersect(one).count(), 1)
  assert_eq(one.union(two).difference(one).count(), 1)
  assert_eq(@moonchess.Bitboard::full().count(), 64)
  assert_eq(
    @moonchess.Bitboard::full()
    .difference(@moonchess.Bitboard::rank_mask(0))
    .count(),
    56,
  )
}

///|
test "bitboard squares are ordered by index" {
  let bits = @moonchess.Bitboard::single(sq("b1"))
    .union(@moonchess.Bitboard::single(sq("a1")))
    .union(@moonchess.Bitboard::single(sq("c2")))
  let squares = bits.squares()
  assert_eq(squares.length(), 3)
  assert_eq(squares[0].to_string(), "a1")
  assert_eq(squares[1].to_string(), "b1")
  assert_eq(squares[2].to_string(), "c2")
  assert_eq(bits.first(), Some(sq("a1")))
  assert_eq(@moonchess.Bitboard::empty().first(), None)
  assert_eq(@moonchess.Bitboard::empty().squares().length(), 0)
}

///|
test "rank and file masks" {
  let rank1 = @moonchess.Bitboard::rank_mask(0)
  assert_eq(rank1.count(), 8)
  assert_true(rank1.contains(sq("a1")))
  assert_true(rank1.contains(sq("h1")))
  assert_eq(rank1.contains(sq("a2")), false)
  let file_a = @moonchess.Bitboard::file_mask(0)
  assert_eq(file_a.count(), 8)
  assert_true(file_a.contains(sq("a8")))
  assert_eq(file_a.contains(sq("b1")), false)
  assert_eq(rank1.intersect(file_a).count(), 1)
  assert_eq(rank1.intersect(file_a).first(), Some(sq("a1")))
  assert_eq(
    @moonchess.Bitboard::file_mask(7)
    .intersect(@moonchess.Bitboard::rank_mask(7))
    .first(),
    Some(sq("h8")),
  )
}

///|
test "bitboard words round trip" {
  let bits = @moonchess.Bitboard::single(sq("e4"))
  assert_eq(@moonchess.Bitboard::from_u64(bits.to_u64()), bits)
  assert_eq(bits.to_u64(), 1UL << 28)
}

///|
test "bitboard diagram" {
  let diagram = @moonchess.Bitboard::single(sq("a1")).to_ascii()
  let expected = "8 . . . . . . . .\n7 . . . . . . . .\n6 . . . . . . . .\n5 . . . . . . . .\n4 . . . . . . . .\n3 . . . . . . . .\n2 . . . . . . . .\n1 X . . . . . . .\n  a b c d e f g h"
  assert_eq(diagram, expected)
}
