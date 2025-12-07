///|
/// Tests for internal helper functions using snapshot testing
test "str_compare basic" {
  // Equal strings
  assert_eq(str_compare("abc", "abc"), 0)
  assert_eq(str_compare("", ""), 0)

  // Different lengths
  assert_eq(str_compare("", "a"), -1)
  assert_eq(str_compare("a", ""), 1)

  // Lexicographic order
  assert_eq(str_compare("a", "b"), -1)
  assert_eq(str_compare("b", "a"), 1)
}

///|
test "base62_index_of basic" {
  // Digits 0-9 -> indices 0-9
  assert_eq(base62_index_of('0'), 0)
  assert_eq(base62_index_of('9'), 9)

  // Uppercase A-Z -> indices 10-35
  assert_eq(base62_index_of('A'), 10)
  assert_eq(base62_index_of('Z'), 35)

  // Lowercase a-z -> indices 36-61
  assert_eq(base62_index_of('a'), 36)
  assert_eq(base62_index_of('z'), 61)

  // Invalid character
  assert_eq(base62_index_of('!'), -1)
}

///|
test "base62_char_at basic" {
  assert_eq(base62_char_at(0), '0')
  assert_eq(base62_char_at(9), '9')
  assert_eq(base62_char_at(10), 'A')
  assert_eq(base62_char_at(35), 'Z')
  assert_eq(base62_char_at(36), 'a')
  assert_eq(base62_char_at(61), 'z')
}

///|
test "get_int_len snapshot" {
  inspect(try? get_int_len('a'), content="Ok(2)")
  inspect(try? get_int_len('b'), content="Ok(3)")
  inspect(try? get_int_len('z'), content="Ok(27)")
  inspect(try? get_int_len('A'), content="Ok(27)")
  inspect(try? get_int_len('Z'), content="Ok(2)")
  inspect(
    try? get_int_len('0'),
    content=(
      #|Err(KeyError("invalid order key head: 0"))
    ),
  )
}

///|
test "midpoint basic snapshot" {
  inspect(midpoint("", ""), content="V")
  inspect(midpoint("", "V"), content="G")
  inspect(midpoint("V", ""), content="l")
  inspect(midpoint("0", "2"), content="1")
}

///|
test "increment_int snapshot" {
  inspect(
    try? increment_int("a0"),
    content=(
      #|Ok("a1")
    ),
  )
  inspect(
    try? increment_int("az"),
    content=(
      #|Ok("b00")
    ),
  )
  inspect(
    try? increment_int("Zz"),
    content=(
      #|Ok("a0")
    ),
  )
}

///|
test "decrement_int snapshot" {
  inspect(
    try? decrement_int("a1"),
    content=(
      #|Ok("a0")
    ),
  )
  inspect(
    try? decrement_int("a0"),
    content=(
      #|Ok("Zz")
    ),
  )
  inspect(
    try? decrement_int("b00"),
    content=(
      #|Ok("az")
    ),
  )
}

///|
test "key_between snapshot" {
  inspect(
    try? key_between(None, None),
    content=(
      #|Ok("a0")
    ),
  )
  inspect(
    try? key_between(Some("a0"), None),
    content=(
      #|Ok("a1")
    ),
  )
  inspect(
    try? key_between(None, Some("a0")),
    content=(
      #|Ok("Zz")
    ),
  )
  inspect(
    try? key_between(Some("a0"), Some("a1")),
    content=(
      #|Ok("a0V")
    ),
  )
}

///|
test "n_keys_between snapshot" {
  inspect(
    try? n_keys_between(None, None, 3),
    content=(
      #|Ok(["a0", "a1", "a2"])
    ),
  )
  inspect(
    try? n_keys_between(Some("a0"), Some("a2"), 5),
    content=(
      #|Ok(["a0G", "a0V", "a1", "a1G", "a1V"])
    ),
  )
}

///|
test "float64_approx snapshot" {
  inspect(try? float64_approx("a0"), content="Ok(0)")
  inspect(try? float64_approx("a1"), content="Ok(1)")
  inspect(try? float64_approx("Z1"), content="Ok(-1)")
  inspect(try? float64_approx("a0V"), content="Ok(0.5)")
}
