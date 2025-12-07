///|
const BASE62_DIGITS : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

///|
const SMALLEST_INT : String = "A00000000000000000000000000"

///|
const ZERO : String = "a0"

///|
/// common error structure of lexicon order key
pub suberror KeyError String derive(Show)

///|
/// Helper function to find the index of a character in BASE62_DIGITS
fn base62_index_of(c : Char) -> Int {
  match BASE62_DIGITS.find(c.to_string()[:]) {
    Some(i) => i
    None => -1
  }
}

///|
/// Helper function to get a character at index in BASE62_DIGITS
fn base62_char_at(i : Int) -> Char {
  match BASE62_DIGITS.get_char(i) {
    Some(c) => c
    None => '0' // fallback, should not happen
  }
}

///|
/// Helper function to get a character from a string safely
fn get_char_at(s : String, i : Int) -> Char {
  match s.get_char(i) {
    Some(c) => c
    None => '0' // fallback
  }
}

///|
/// compare them lexicographically, loop from head to tail, empty string is smallest
fn str_compare(a : String, b : String) -> Int {
  let mut i = 0
  while i < a.length() && i < b.length() {
    let ca = a.code_unit_at(i)
    let cb = b.code_unit_at(i)
    if ca < cb {
      return -1
    }
    if ca > cb {
      return 1
    }
    i += 1
  }
  if a.length() < b.length() {
    return -1
  }
  if a.length() > b.length() {
    return 1
  }
  0
}

///|
/// key_between returns a key that sorts lexicographically between a and b.
/// Either a or b can be empty strings. If a is empty it indicates smallest key,
/// If b is empty it indicates largest key.
/// b must be empty string or > a.
pub fn key_between(a : String?, b : String?) -> String raise KeyError {
  // println("between: " + a.to_string() + " " + b.to_string())
  match a {
    Some(av) => validate_order_key(av)
    None => ()
  }
  match b {
    Some(bv) => validate_order_key(bv)
    None => ()
  }
  match (a, b) {
    (Some(av), Some(bv)) if str_compare(av, bv) >= 0 =>
      raise KeyError("invalid order: " + av + " >= " + bv)
    _ => ()
  }
  match a {
    None =>
      match b {
        None => return ZERO
        Some(bv) => {
          let int_b = get_int_part(bv)
          let float_part_b = try! bv[int_b.length():].to_string()
          if int_b == SMALLEST_INT {
            // println("midpoint 1 is: " + midpoint("", float_part_b))
            return int_b + midpoint("", float_part_b)
          }
          if int_b < bv {
            return int_b
          }
          let res = decrement_int(int_b)
          if res.is_empty() {
            raise KeyError("range underflow")
          }
          return res
        }
      }
    Some(av) =>
      match b {
        None => {
          let int_a = get_int_part(av)
          let float_part_a = try! av[int_a.length():].to_string()
          let i = increment_int(int_a)
          if i.is_empty() {
            // println("midpoint 2 is: " + midpoint(float_part_a, ""))
            return int_a + midpoint(float_part_a, "")
          }
          return i
        }
        Some(bv) => {
          let int_a = get_int_part(av)
          let float_part_a = try! av[int_a.length():].to_string()
          let int_b = get_int_part(bv)
          let float_part_b = try! bv[int_b.length():].to_string()
          if int_a == int_b {
            // println("midpoint 3 is: " + midpoint(float_part_a, float_part_b))
            return int_a + midpoint(float_part_a, float_part_b)
          }
          let i = increment_int(int_a)
          if i.is_empty() {
            raise KeyError("range overflow")
          }
          if i < bv {
            return i
          }
          return int_a + midpoint(float_part_a, "")
        }
      }
  }
}

///|
/// `a < b` lexicographically if `b` is non-empty.
/// a == "" means first possible string.
/// b == "" means last possible string.
/// a, b MUST be str without head
fn midpoint(a : String, b : String) -> String {
  // println("midpoint: " + a + " " + b)
  if not(b.is_empty()) {
    // remove longest common prefix.  pad `a` with 0s as we
    // go.  note that we don't need to pad `b`, because it can't
    // end before `a` while traversing the common prefix.
    let mut i = 0
    for _i = 0; _i < a.length(); _i = _i + 1 {
      let mut c : Char = '0'
      if a.length() > i {
        c = get_char_at(a, i)
      }
      if i >= b.length() || c != get_char_at(b, i) {
        break
      }
      i += 1
    }
    if i > 0 {
      if i > a.length() - 1 {
        return try! (b[:i].to_string() + midpoint("", try! b[i:].to_string()))
      } else {
        return try! (b[:i].to_string() +
        midpoint(try! a[i:].to_string(), try! b[i:].to_string()))
      }
    }
  }

  // first digits (or lack of digit) are different
  let mut digit_a = 0
  if not(a.is_empty()) {
    digit_a = base62_index_of(get_char_at(a, 0))
  }
  let mut digit_b = BASE62_DIGITS.length()
  if not(b.is_empty()) {
    digit_b = base62_index_of(get_char_at(b, 0))
  }
  if digit_b - digit_a > 1 {
    // println(
    //   "DEBUG " + (0.5 * (digit_a + digit_b).to_double()).round().to_string(),
    // )
    let mid_digit = (0.5 * (digit_a + digit_b).to_double()).round().to_int()
    // println("mid_digit: " + mid_digit.to_string())
    return base62_char_at(mid_digit).to_string()
  }

  // first digits are consecutive
  if b.length() > 1 {
    if not(b.has_prefix("0")) {
      return try! b[:1].to_string()
    }
    return base62_char_at(digit_a).to_string() +
      midpoint("", try! b[1:].to_string())
  }

  // `b` is empty or has length 1 (a single digit).
  // the first digit of `a` is the previous digit to `b`,
  // or 9 if `b` is null.
  // given, for example, midpoint('49', '5'), return
  // '4' + midpoint('9', null), which will become
  // '4' + '9' + midpoint('', null), which is '495'
  let mut sa = ""
  if not(a.is_empty()) {
    sa = try! a[1:].to_string()
  }
  return base62_char_at(digit_a).to_string() + midpoint(sa, "")
}

///|
fn validate_int(i : String) -> Unit raise KeyError {
  let exp = get_int_len(get_char_at(i, 0))
  if i.length() != exp {
    raise KeyError("invalid integer part of order key: " + i)
  }
}

///|
// length map:
// A-Z -> 28-2
// a-z -> 2-28
fn get_int_len(head : Char) -> Int raise KeyError {
  if 'a' <= head && head <= 'z' {
    head.to_int() - 'a'.to_int() + 2
  } else if 'A' <= head && head <= 'Z' {
    'Z'.to_int() - head.to_int() + 2
  } else {
    raise KeyError("invalid order key head: " + head.to_string())
  }
}

///|
/// throw error when shorter than `get_int_len(head)`
fn get_int_part(key : String) -> String raise KeyError {
  let int_part_len = get_int_len(get_char_at(key, 0))
  if int_part_len > key.length() {
    raise KeyError("invalid order key: " + key)
  }
  try! key[:int_part_len].to_string()
}

///|
/// throw when:
/// first charater is not valid head
/// short than `get_int_len(head)`
/// ends with 0
///
fn validate_order_key(key : String) -> Unit raise KeyError {
  if key == SMALLEST_INT {
    raise KeyError("invalid order key: " + key)
  }
  // get_int_part will return error if the first character is bad,
  // or the key is too short.  we'd call it to check these things
  // even if we didn't need the result
  let int_part = get_int_part(key)
  let float_part = try! key[int_part.length():].to_string()
  if float_part.has_suffix("0") {
    raise KeyError("invalid order key: " + key)
  }
}

///|
/// returns error if x is invalid, or if range is exceeded
/// x MUST be int without float part
fn increment_int(x : String) -> String raise KeyError {
  validate_int(x)
  let digs : Array[Char] = x.to_array()
  let head = digs[0]
  let _v = digs.remove(0)
  let mut carry = true
  let mut i = digs.length() - 1
  while carry && i >= 0 {
    let d = base62_index_of(digs[i]) + 1
    if d == BASE62_DIGITS.length() {
      digs[i] = '0'
    } else {
      digs[i] = base62_char_at(d)
      carry = false
    }
    i -= 1
  }
  if carry {
    if head == 'Z' {
      return "a0"
    }
    if head == 'z' {
      return ""
    }
    let h = (head.to_int() + 1).unsafe_to_char()
    if h > 'a' {
      // a-z -> incr
      digs.push('0')
    } else {
      // A-Z -> decr
      let _v = digs.pop()

    }
    return h.to_string() + String::from_array(digs)
  }
  head.to_string() + String::from_array(digs)
}

///|
fn decrement_int(x : String) -> String raise KeyError {
  validate_int(x)
  let digs : Array[Char] = x.to_array()
  let head = digs[0]
  let _t = digs.remove(0)
  let mut borrow = true
  let mut i = digs.length() - 1
  while borrow && i >= 0 {
    let d = base62_index_of(digs[i]) - 1
    if d == -1 {
      digs[i] = base62_char_at(BASE62_DIGITS.length() - 1)
    } else {
      digs[i] = base62_char_at(d)
      borrow = false
    }
    i -= 1
  }
  if borrow {
    if head == 'a' {
      return "Z" + base62_char_at(BASE62_DIGITS.length() - 1).to_string()
    }
    if head == 'A' {
      return ""
    }
    let h = (head.to_int() - 1).unsafe_to_char()
    if h < 'Z' {
      digs.push(base62_char_at(BASE62_DIGITS.length() - 1))
    } else {
      let _v = digs.pop()

    }
    return h.to_string() + String::from_array(digs)
  }
  head.to_string() + String::from_array(digs)
}

///|
/// float64_approx converts a key as generated by key_between() to a float64.
/// Because the range of keys is far larger than float64 can represent
/// accurately, this is necessarily approximate. But for many use cases it should
/// be, as they say, close enough for jazz.
pub fn float64_approx(key : String) -> Double raise KeyError {
  if key.is_empty() {
    raise KeyError("invalid order key")
  }
  validate_order_key(key)
  let ip = get_int_part(key)
  let digs : Array[Char] = ip.to_array()
  let head = digs[0]
  let _v = digs.remove(0)
  let mut rv : Double = 0.0
  for i = 0; i < digs.length(); i = i + 1 {
    let d = digs[digs.length() - i - 1]
    let p = base62_index_of(d)
    if p < 0 {
      raise KeyError("invalid order key: " + key)
    }
    rv += (pow(BASE62_DIGITS.length(), i) * p).to_double()
  }
  let fp = try! key[ip.length():].to_string()
  for i, d in fp.to_array() {
    let p = base62_index_of(d)
    if p < 0 {
      raise KeyError("invalid key: " + key)
    }
    rv += p.to_double() / powf(BASE62_DIGITS.length().to_double(), i + 1)
  }
  if head < 'a' {
    rv *= -1.0
  }
  rv
}

///|
/// n_keys_between returns n keys between a and b that sorts lexicographically.
/// Either a or b can be empty strings. If a is empty it indicates smallest key,
/// If b is empty it indicates largest key.
/// b must be empty string or > a.
pub fn n_keys_between(
  a : String?,
  b : String?,
  n : Int,
) -> Array[String] raise KeyError {
  if n == 0 {
    return []
  }
  if n == 1 {
    let c = key_between(a, b)
    return [c]
  }
  match b {
    None => {
      let mut c = key_between(a, b)
      let result : Array[String] = []
      result.push(c)
      for _i = 0; _i < n - 1; _i = _i + 1 {
        c = key_between(Some(c), b)
        result.push(c)
      }
      return result
    }
    Some(_) =>
      match a {
        None => {
          let mut c = key_between(a, b)
          let mut result : Array[String] = []
          result.push(c)
          for _i = 0; _i < n - 1; _i = _i + 1 {
            c = key_between(a, Some(c))
            result.push(c)
          }
          result = result.rev()
          return result
        }
        Some(_) => {
          let mid = n / 2
          let c = key_between(a, b)
          let result : Array[String] = []
          {
            let key_r = n_keys_between(a, Some(c), mid)
            for item in key_r {
              result.push(item)
            }
          }
          result.push(c)
          {
            let key_r = n_keys_between(Some(c), b, n - mid - 1)
            for item in key_r.iter() {
              result.push(item)
            }
          }
          return result
        }
      }
  }
}

///|
pub fn pow(x : Int, exp : Int) -> Int {
  let mut result : Int = 1
  for _i = 0; _i < exp; _i = _i + 1 {
    result *= x
  }
  result
}

///|
pub fn powf(x : Double, exp : Int) -> Double {
  let mut result : Double = 1.0
  for _i = 0; _i < exp; _i = _i + 1 {
    result *= x
  }
  result
}
