open! Base
open! Prefix

let%test "ip_mask"  =
  IP.eq (IP.mask (IP.of_string "192.168.100.100") 24) (IP.of_string "192.168.100.0")

let%test "ip_incr_1"  =
  IP.eq (IP.incr (IP.of_string "192.168.100.100") 1) (IP.of_string "192.168.100.101")

let%test "ip_incr_255"  =
  IP.eq (IP.incr (IP.of_string "192.168.101.100") 255) (IP.of_string "192.168.102.99")

let%test "ip_str"  =
  String.compare (IP.to_string (IP.of_string "192.168.101.100"))  "192.168.101.100" = 0

let%test "prefix_contains"  =
  Prefix.contains (Prefix.of_string "192.168.100.0/24") (IP.of_string "192.168.100.100")

let%test "prefix_not_contains"  =
  not (Prefix.contains (Prefix.of_string "192.168.101.0/24") (IP.of_string "192.168.100.100"))

let%test "prefix_mask"  =
  Prefix.eq (Prefix.of_string "192.168.101.100/16") (Prefix.of_string "192.168.101.200/16")

let%test "prefix_covers" =
  Prefix.covers (Prefix.of_string "192.168.1.0/24") (Prefix.of_string "192.168.1.100/32")

let%test "prefix_not_covers" =
  not (Prefix.covers (Prefix.of_string "192.168.100.100/16") (Prefix.of_string "192.169.200.100/24"))

let%test "prefix_split" =
  List.equal Prefix.eq (Prefix.split (Prefix.of_string "192.168.0.0/24"))
    [Prefix.of_string "192.168.0.0/25"; Prefix.of_string "192.168.0.128/25"]

let%test "prefix_list_contains" =
  let l = (PrefixList.empty
      |> PrefixList.add ~p:(Prefix.of_string "192.168.0.0/24")
      |> PrefixList.add ~p:(Prefix.of_string "192.168.1.0/24")
      |> PrefixList.add ~p:(Prefix.of_string "192.168.2.0/24")
    )
  in
  PrefixList.contains l (Prefix.of_string "192.168.1.100/32") &&
  PrefixList.contains l (Prefix.of_string "192.168.2.100/32")

let%test "prefix_list_contains_rem" =
  let l =
    (PrefixList.empty
      |> PrefixList.add ~p:(Prefix.of_string "192.168.1.0/24")
      |> PrefixList.rem ~p:(Prefix.of_string "192.168.1.100/32")
    )
  in
  PrefixList.contains l (Prefix.of_string "192.168.1.99/32") &&
  PrefixList.contains l (Prefix.of_string "192.168.1.101/32") &&
  not (PrefixList.contains l (Prefix.of_string "192.168.1.100/32"))
