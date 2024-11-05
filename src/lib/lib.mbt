const BASE62_DIGITS : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

const SMALLEST_INT : String = "A00000000000000000000000000"

const ZERO : String = "a0"

type! KeyError String

/// key_between returns a key that sorts lexicographically between a and b.
/// Either a or b can be empty strings. If a is empty it indicates smallest key,
/// If b is empty it indicates largest key.
/// b must be empty string or > a.
pub fn key_between(a : String?, b : String?) -> String!KeyError {
  // println!("between: {} {}", a, b);
  if not(a.is_empty()) {
    validate_order_key!(a.unwrap())
  }
  if not(b.is_empty()) {
    validate_order_key!(b.unwrap())
  }
  if not(a.is_empty()) && not(b.is_empty()) && a >= b {
    raise KeyError(
      "invalid order: {} >= {}" +
      a.unwrap().to_string() +
      b.unwrap().to_string(),
    )
  }
  if a.is_empty() {
    if b.is_empty() {
      return ZERO
    }
    let int_b = get_int_part!(b.unwrap())
    let float_part_b = b.unwrap().substring(start=int_b.length())
    if int_b == SMALLEST_INT {
      return int_b + midpoint("", float_part_b)
    }
    if int_b < b.unwrap() {
      return int_b
    }
    let res = decrement_int!(int_b)
    if res.is_empty() {
      raise KeyError("range underflow")
    }
    return res
  }
  if b.is_empty() {
    let int_a = get_int_part!(a.unwrap())
    let float_part_a = a.unwrap().substring(start=int_a.length())
    let i = increment_int!(int_a)
    if i.is_empty() {
      return int_a + midpoint(float_part_a, "")
    }
    return i
  }
  let int_a = get_int_part!(a.unwrap())
  let float_part_a = a.unwrap().substring(start=int_a.length())
  let int_b = get_int_part!(b.unwrap())
  let float_part_b = b.unwrap().substring(start=int_b.length())
  if int_a == int_b {
    return int_a + midpoint(float_part_a, float_part_b)
  }
  let i = increment_int!(int_a)
  if i.is_empty() {
    raise KeyError("range overflow")
  }
  if i < b.unwrap() {
    return i
  }
  int_a + midpoint(float_part_a, "")
}

/// `a < b` lexicographically if `b` is non-empty.
/// a == "" means first possible string.
/// b == "" means last possible string.
/// a, b MUST be str without head
fn midpoint(a : String, b : String) -> String {
  if not(b.is_empty()) {
    // remove longest common prefix.  pad `a` with 0s as we
    // go.  note that we don't need to pad `b`, because it can't
    // end before `a` while traversing the common prefix.
    let mut i = 0
    for _i = 0; _i < a.length(); _i = _i + 1 {
      let mut c : Char = '0'
      if a.length() > i {
        c = a.to_array()[i]
      }
      if i >= b.length() || c != b[i] {
        break
      }
      i += 1
    }
    if i > 0 {
      if i > a.length() - 1 {
        return b.substring(end=i).to_string() +
          midpoint("", b.substring(start=i))
      } else {
        return b.substring(end=i) +
          midpoint(a.substring(start=1), b.substring(start=i))
      }
    }
  }

  // first digits (or lack of digit) are different
  let mut digit_a = 0
  if not(a.is_empty()) {
    digit_a = BASE62_DIGITS.index_of(a[0].to_string())
  }
  let mut digit_b = BASE62_DIGITS.length()
  if not(b.is_empty()) {
    digit_b = BASE62_DIGITS.index_of(b[0].to_string())
  }
  if digit_b - digit_a > 1 {
    let mid_digit = (0.5 * (digit_a + digit_b).to_double())
      .round()
      .reinterpret_as_int64()
      .to_int()
    return BASE62_DIGITS[mid_digit].to_string()
  }

  // first digits are consecutive
  if b.length() > 1 {
    if not(b.starts_with('0'.to_string())) {
      return b.substring(end=1)
    }
    return BASE62_DIGITS[digit_a].to_string() +
      midpoint("", b.substring(start=1))
  }

  // `b` is empty or has length 1 (a single digit).
  // the first digit of `a` is the previous digit to `b`,
  // or 9 if `b` is null.
  // given, for example, midpoint('49', '5'), return
  // '4' + midpoint('9', null), which will become
  // '4' + '9' + midpoint('', null), which is '495'
  let mut sa = ""
  if not(a.is_empty()) {
    sa = a.substring(start=1)
  }
  return BASE62_DIGITS.to_array()[digit_a].to_string() + midpoint(sa, "")
}

fn validate_int(i : String) -> Unit!KeyError {
  let exp = get_int_len!(i[0])
  if i.length() != exp {
    raise KeyError("invalid integer part of order key: " + i)
  }
}

///
// length map:
// A-Z -> 28-2
// a-z -> 2-28
fn get_int_len(head : Char) -> Int!KeyError {
  if 'a' <= head && head <= 'z' {
    head.to_int() - 'a'.to_int() + 2
  } else if 'A' <= head && head <= 'Z' {
    'Z'.to_int() - head.to_int() + 2
  } else {
    raise KeyError("invalid order key head: " + head.to_string())
  }
}

/// throw error when shorter than `get_int_len(head)`
fn get_int_part(key : String) -> String!KeyError {
  let int_part_len = get_int_len!(key[0])
  if int_part_len > key.length() {
    raise KeyError("invalid order key: " + key)
  }
  key.substring(start=0, end=int_part_len)
}

/// throw when:
/// first charater is not valid head
/// short than `get_int_len(head)`
/// ends with 0
///
fn validate_order_key(key : String) -> Unit!KeyError {
  if key == SMALLEST_INT {
    raise KeyError("invalid order key: " + key)
  }
  // get_int_part will return error if the first character is bad,
  // or the key is too short.  we'd call it to check these things
  // even if we didn't need the result
  let int_part = get_int_part!(key)
  let float_part = key.substring(start=int_part.length())
  if float_part.ends_with("0") {
    raise KeyError("invalid order key:" + key)
  }
}

/// returns error if x is invalid, or if range is exceeded
/// x MUST be int without float part
fn increment_int(x : String) -> String!KeyError {
  validate_int!(x)
  let digs : Array[Char] = x.to_array()
  let head = digs[0]
  let _v = digs.remove(0)
  let mut carry = true
  let mut i = digs.length() - 1
  while carry && i >= 0 {
    let d = BASE62_DIGITS.index_of(digs[i].to_string()) + 1
    if d == BASE62_DIGITS.length() {
      digs[i] = '0'
    } else {
      digs[i] = BASE62_DIGITS.to_array()[d]
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
    let h = head.to_uint() + 1
    if h > 'a'.to_uint() {
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

fn decrement_int(x : String) -> String!KeyError {
  validate_int!(x)
  let digs : Array[Char] = x.to_array()
  let head = digs[0]
  let _t = digs.remove(0)
  let mut borrow = true
  let mut i = digs.length() - 1
  while borrow && i >= 0 {
    let d = BASE62_DIGITS.index_of(digs[i].to_string()) - 1
    if d == -1 {
      digs[i] = BASE62_DIGITS[-1]
    } else {
      digs[i] = BASE62_DIGITS.to_array()[d]
      borrow = false
    }
    i -= 1
  }
  if borrow {
    if head == 'a' {
      return "Z" + BASE62_DIGITS.to_array()[-1].to_string()
    }
    if head == 'A' {
      return ""
    }
    let h = head.to_uint() - 1
    if h < 'Z'.to_uint() {
      digs.push(BASE62_DIGITS.to_array()[-1])
    } else {
      let _v = digs.pop()

    }
    return h.to_string() + String::from_array(digs)
  }
  head.to_string() + String::from_array(digs)
}

/// float64_approx converts a key as generated by key_between() to a float64.
/// Because the range of keys is far larger than float64 can represent
/// accurately, this is necessarily approximate. But for many use cases it should
/// be, as they say, close enough for jazz.
pub fn float64_approx(key : String) -> Double!KeyError {
  if key.is_empty() {
    raise KeyError("invalid order key")
  }
  validate_order_key!(key)
  let ip = get_int_part!(key)
  let digs : Array[Char] = ip.to_array()
  let head = digs[0]
  let _v = digs.remove(0)
  let mut rv : Double = 0.0
  for i = 0; i < digs.length(); i = i + 1 {
    let d = digs[digs.length() - i - 1]
    let p = BASE62_DIGITS.index_of(d.to_string())
    if p < 0 {
      raise KeyError("invalid order key: " + key)
    }
    rv += (pow(BASE62_DIGITS.length(), i) * p).to_float().to_double()
  }
  let fp = key.substring(start=ip.length())
  for i, d in fp.to_array() {
    let p = BASE62_DIGITS.index_of(d.to_string())
    if p < 0 {
      raise KeyError("invalid key: " + key)
    }
    rv += (p / pow(BASE62_DIGITS.length(), i + 1)).to_double()
  }
  if head < 'a' {
    rv *= -1.0
  }
  rv
}

/// n_keys_between returns n keys between a and b that sorts lexicographically.
/// Either a or b can be empty strings. If a is empty it indicates smallest key,
/// If b is empty it indicates largest key.
/// b must be empty string or > a.
pub fn n_keys_between(
  a : String?,
  b : String?,
  n : Int
) -> Array[String]!KeyError {
  if n == 0 {
    return []
  }
  if n == 1 {
    let c = key_between!(a, b)
    return [c]
  }
  if b.is_empty() {
    let mut c = key_between!(a, b)
    let result : Array[String] = []
    result.push(c)
    for _i = 0; _i < n - 1; _i = _i + 1 {
      c = key_between!(Some(c), b)
      result.push(c)
    }
    return result
  }
  if a.is_empty() {
    let mut c = key_between!(a, b)
    let mut result : Array[String] = []
    result.push(c)
    for _i = 0; _i < n - 1; _i = _i + 1 {
      c = key_between!(a, Some(c))
      result.push(c)
    }
    result = result.rev()
    return result
  }
  let mid = n / 2
  let c = key_between!(a, b)
  let result : Array[String] = []
  {
    let key_r = n_keys_between!(a, Some(c), mid)
    for item in key_r {
      result.push(item)
    }
  }
  result.push(c)
  {
    let key_r = n_keys_between!(Some(c), b, n - mid - 1)
    for item in key_r.iter() {
      result.push(item)
    }
  }
  result
}

pub fn pow(x : Int, exp : Int) -> Int {
  let mut result : Int = 1
  for _i = 0; _i < exp; _i = _i + 1 {
    result *= x
  }
  result
}
