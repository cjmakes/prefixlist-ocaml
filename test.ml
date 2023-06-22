open! Base

let%test "covers" =
  Prefix.eq (Prefix.of_string "192.168.0.0/16") (Prefix.of_string "192.168.100.0/16")
