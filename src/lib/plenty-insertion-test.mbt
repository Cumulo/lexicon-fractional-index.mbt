fn insert_end_test() -> Unit! {
  let mut left : String? = None
  let right : String? = None
  for _i = 0; _i < 100000; _i = _i + 1 {
    let next = key_between!(left, right)
    assert_not_eq!(left, Some(next))
    assert_not_eq!(right, Some(next))
    if not(left.is_empty()) {
      // println!("< {:?} {:?} {:?}", left, next, right);
      assert_eq!(str_compare(left.unwrap(), next), -1)
    }
    left = Some(next)
  }
  println("< " + left.to_string() + " " + right.to_string())
}

fn insert_beggining_test() -> Unit! {
  let left : String? = None
  let mut right : String? = None
  for _i = 0; _i < 100000; _i = _i + 1 {
    let next = key_between!(left, right)
    assert_not_eq!(left, Some(next))
    assert_not_eq!(right, Some(next))
    if not(right.is_empty()) {
      // println!("< {:?} {:?} {:?}", left, next, right);
      println(
        "< " +
        left.to_string() +
        " " +
        next.to_string() +
        " " +
        right.to_string(),
      )
      assert_eq!(str_compare(next, right.unwrap()), -1)
    }
    right = Some(next)
  }
  println("< " + left.to_string() + " " + right.to_string())
}

fn insert_middle_left_test() -> Unit! {
  let left = Some("Zj")
  let mut right = Some("Zk")

  // too slow to have 100k insertions, use 4k only
  for _i = 0; _i < 4000; _i = _i + 1 {
    let next = key_between!(left, right)
    assert_not_eq!(left.unwrap(), next)
    assert_not_eq!(right.unwrap(), next)
    if not(right.is_empty()) {
      // println!("< {:?} {:?} {:?}", left, next, right);
      assert_eq!(str_compare(left.unwrap(), next), -1)
      assert_eq!(str_compare(next, right.unwrap()), -1)
    }
    right = Some(next)
  }
  println("< " + left.to_string() + " " + right.to_string())
}

fn insert_middle_right_test() -> Unit! {
  let mut left = Some("Zj")
  let right = Some("Zk")
  for _i = 0; _i < 4000; _i = _i + 1 {
    let next = key_between!(left, right)
    assert_not_eq!(left.unwrap(), next)
    assert_not_eq!(right.unwrap(), next)
    if not(right.is_empty()) {
      // println!("< {:?} {:?} {:?}", left, next, right);
      assert_eq!(str_compare(left.unwrap(), next), -1)
      assert_eq!(str_compare(next, right.unwrap()), -1)
    }
    left = Some(next)
  }
  println("< " + left.to_string() + " " + right.to_string())
}

fn insert_middle_left_right_test() -> Unit! {
  let mut left = Some("Zj")
  let mut right = Some("Zk")
  let mut at_right = false
  for _i = 0; _i < 2000; _i = _i + 1 {
    let next = key_between!(left, right)
    assert_not_eq!(left.unwrap(), next)
    assert_not_eq!(right.unwrap(), next)

    // println!("< {:?} {:?}", left, right);
    assert_eq!(str_compare(left.unwrap(), next), -1)
    assert_eq!(str_compare(next, right.unwrap()), -1)
    if at_right {
      right = Some(next)
      at_right = false
    } else {
      left = Some(next)
      at_right = true
    }
  }
  println("< " + left.to_string() + " " + right.to_string())
}

test {
  insert_end_test!()
  insert_beggining_test!()
  insert_middle_left_test!()
  insert_middle_right_test!()
  insert_middle_left_right_test!()
}
