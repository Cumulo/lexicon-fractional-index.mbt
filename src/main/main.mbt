///|
fn demo_1() -> Unit {
  // let next = key_between("Xb0M", "Xb0M0V")?;

  // println!("next {}", next);

  // expected "Zz"
  // println!("next: {}", next);

  // println!("{:?}", key_between("a", "b"));
  // println!("{:?}", key_between("", ""));

  // let base = "b".to_owned();
  // let mut edge = "c".to_owned();
  // for _ in 0..1000 {
  //   edge = key_between(&base, &edge)?;
  //   println!("base: {}", edge)
  // }

  let left = "Xb0M"
  let mut right = "Xb0M0V"
  for _i = 0; _i < 1000; _i = _i + 1 {
    try @lib.key_between(Some(left), Some(right)) catch {
      e => {
        println("error: " + e.to_string())
        abort("error")
      }
    } noraise {
      next => {
        println("key: " + next.to_string())
        right = next
      }
    }
  }
  println("left: {}" + left.length().to_string())
  println("left: {}" + left.to_string())
}

///|
fn demo_2() -> Unit {
  let left = "a0V"
  let right = "a1"
  try @lib.key_between(Some(left), Some(right)) catch {
    e => {
      println("error: " + e.to_string())
      abort("error")
    }
  } noraise {
    next => println("key: " + next.to_string())
  }
}

///|
/// None and Y00
fn demo_3() -> Unit {
  let left = None
  let right = Some("Y00")
  try @lib.key_between(left, right) catch {
    e => {
      println("error: " + e.to_string())
      abort("error")
    }
  } noraise {
    next => println("key: " + next.to_string())
  }
}

///|
fn demo_4() -> Unit {
  try @lib.float64_approx("a0V") catch {
    err =>
      match err {
        KeyError(s) => println("err " + s)
      }
  } noraise {
    act => println("act " + act.to_string())
  }
}

///|
fn main {
  // demo_1()
  // demo_2()
  // demo_3()
  demo_4()
}
