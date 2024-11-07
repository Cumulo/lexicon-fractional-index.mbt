fn keys_test() -> Unit! {
  fn test_check(a : String?, b : String?, exp : String) -> Unit! {
    match key_between?(a, b) {
      Ok(act) => assert_eq!(exp, act)
      Err(err) =>
        match err {
          KeyError(s) => assert_eq!(exp, s)
        }
    }
  }

  test_check!(None, None, "a0")
  test_check!(None, Some("a0"), "Zz")
  test_check!(None, Some("Zz"), "Zy")
  test_check!(Some("a0"), None, "a1")
  test_check!(Some("a1"), None, "a2")
  test_check!(Some("a0"), Some("a1"), "a0V")
  test_check!(Some("a1"), Some("a2"), "a1V")
  test_check!(Some("a0V"), Some("a1"), "a0l")
  test_check!(Some("Zz"), Some("a0"), "ZzV")
  test_check!(Some("Zz"), Some("a1"), "a0")
  test_check!(None, Some("Y00"), "Xzzz")
  test_check!(Some("bzz"), None, "c000")
  test_check!(Some("a0"), Some("a0V"), "a0G")
  test_check!(Some("a0"), Some("a0G"), "a08")
  test_check!(Some("b125"), Some("b129"), "b127")
  test_check!(Some("a0"), Some("a1V"), "a1")
  test_check!(Some("Zz"), Some("a01"), "a0")
  test_check!(None, Some("a0V"), "a0")
  test_check!(None, Some("b999"), "b99")
  test_check!(
    None,
    Some("A00000000000000000000000000"),
    "invalid order key: A00000000000000000000000000",
  )
  test_check!(
    None,
    Some("A000000000000000000000000001"),
    "A000000000000000000000000000V",
  )
  test_check!(
    Some("zzzzzzzzzzzzzzzzzzzzzzzzzzy"),
    None,
    "zzzzzzzzzzzzzzzzzzzzzzzzzzz",
  )
  test_check!(
    Some("zzzzzzzzzzzzzzzzzzzzzzzzzzz"),
    None,
    "zzzzzzzzzzzzzzzzzzzzzzzzzzzV",
  )
  test_check!(Some("a00"), None, "invalid order key: a00")
  test_check!(Some("a00"), Some("a1"), "invalid order key: a00")
  test_check!(Some("0"), Some("1"), "invalid order key head: 0")
  test_check!(Some("a1"), Some("a0"), "invalid order: a1 >= a0")
}

fn test_n_keys() -> Unit! {
  fn test_check(a : String?, b : String?, n : UInt, exp : String) -> Unit! {
    match n_keys_between?(a, b, n.reinterpret_as_int()) {
      Ok(act_slice) => {
        let act = String::concat(act_slice, separator=" ")
        assert_eq!(exp, act)
      }
      Err(err) => assert_eq!(exp, err.to_string())
    }
  }

  test_check!(None, None, 5, "a0 a1 a2 a3 a4")
  test_check!(Some("a4"), None, 10, "a5 a6 a7 a8 a9 aA aB aC aD aE")
  test_check!(None, Some("a0"), 5, "Zv Zw Zx Zy Zz")
  test_check!(
    Some("a0"),
    Some("a2"),
    20,
    "a04 a08 a0G a0K a0O a0V a0Z a0d a0l a0t a1 a14 a18 a1G a1O a1V a1Z a1d a1l a1t",
  )
}

fn test_to_float64_approx() -> Unit! {
  let t_max = @int64.max_value
  let t_max_f = t_max.to_double()
  let epsilon = 1.0 / t_max_f
  fn test_check(key : String, exp : Double, exp_err : String) -> Unit! {
    println("Case: " + key + " " + exp.to_string())
    match float64_approx?(key) {
      Ok(act) => {
        println("act " + act.to_string() + " exp " + exp.to_string())
        assert_true!((exp - act).abs() < epsilon)
      }
      Err(err) =>
        match err {
          KeyError(s) => assert_eq!(exp_err, s)
        }
    }
  }

  let n_62 = 62.0
  test_check!("a0", 0.0, "")
  test_check!("a1", 1.0, "")
  test_check!("az", 61.0, "")
  test_check!("b10", 62.0, "")
  test_check!("z20000000000000000000000000", powf(n_62, 25) * 2.0, "")
  test_check!("Z1", -1.0, "")
  test_check!("Zz", -61.0, "")
  test_check!("Y10", -62.0, "")
  test_check!("A20000000000000000000000000", powf(n_62, 25) * -2.0, "")
  test_check!("a0V", 0.5, "")
  test_check!("a00V", 31.0 / powf(n_62, 2), "")
  test_check!("aVV", 31.5, "")
  test_check!("ZVV", -31.5, "")
  test_check!("", 0.0, "invalid order key")
  test_check!("!", 0.0, "invalid order key head: !")
  test_check!("a400", 0.0, "invalid order key: a400")
  test_check!("a!", 0.0, "invalid order key: a!")
}

test {
  keys_test!()
  test_n_keys!()
  test_to_float64_approx!()
}
