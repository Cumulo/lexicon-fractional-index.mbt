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
    match @lib.key_between?(Some(left), Some(right)) {
      Ok(next) => {
        println("key: " + next.to_string())
        right = next
      }
      Err(e) => {
        println("error: " + e.to_string())
        abort("error")
      }
    }
  }
  println("left: {}" + left.length().to_string())
  println("left: {}" + left.to_string())
}

fn demo_2() -> Unit {
  let left = "a0V"
  let right = "a1"
  match @lib.key_between?(Some(left), Some(right)) {
    Ok(next) => println("key: " + next.to_string())
    Err(e) => {
      println("error: " + e.to_string())
      abort("error")
    }
  }
}

/// None and Y00
fn demo_3() -> Unit {
  let left = None
  let right = Some("Y00")
  match @lib.key_between?(left, right) {
    Ok(next) => println("key: " + next.to_string())
    Err(e) => {
      println("error: " + e.to_string())
      abort("error")
    }
  }
}

fn main {
  // demo_1()
  // demo_2()
  demo_3()
}
