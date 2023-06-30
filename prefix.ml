open Base

module IP = struct
  type t = int

  (* fold helper to turn a string into an int *)
  let fh i ip octet = ip + Int.shift_left (Int.of_string octet) ((3-i) * 8)
  let of_string s = String.split s ~on: '.' |> List.foldi ~init:0 ~f:fh

  (* unfold helper to turn an ip into a string. Stops after 4 iterations *)
  let ufh = function
    | (4, _) -> None
    | (i, ip) -> Some (Int.bit_and ip 0xff, (i+1, ip lsr 8))
  let to_string t = Sequence.unfold ~init:(0, t) ~f:ufh
    |> Sequence.to_list_rev
    |> List.map ~f:Int.to_string
    |> String.concat ~sep:"."

  let mask t l = Int.bit_and t (Int.bit_xor 0xffffffff ((1 lsl (32 - l)) - 1))

  let incr t i = t + i

  let eq lhs rhs = Int.compare lhs rhs = 0
end

module Prefix = struct
  type t = {host: IP.t; pfix: int}

  let contains t ip = IP.eq t.host @@ IP.mask ip t.pfix

  let covers lhs rhs = (IP.eq lhs.host @@ IP.mask rhs.host lhs.pfix) && lhs.pfix <= rhs.pfix

  let eq lhs rhs = IP.eq lhs.host rhs.host && lhs.pfix = rhs.pfix

  let split t = 
    [
      {host = t.host; pfix = t.pfix + 1 };
      {host = IP.incr t.host (1 lsl (32 - (t.pfix + 1))); pfix = t.pfix + 1};
    ]

  let of_string s = 
    let (ip, pfix) = String.lsplit2_exn ~on: '/' s
    in {
      host = IP.mask (IP.of_string ip) (Int.of_string pfix);
      pfix = Int.of_string pfix;
    }

  let to_string t = IP.to_string t.host ^ "/" ^ Int.to_string t.pfix
end

module PrefixList = struct
  type t = Prefix.t list

  let empty = []

  let add (t: Prefix.t list) ~p:pfix = (pfix :: t)

  let rec rem t ~p:pfix = 
  let open Prefix in 
  let open List in 
    match t with
    | [] as l -> l 
    | hd :: tl when eq hd pfix -> tl
    | hd :: tl when covers hd pfix -> rem (append (split hd) tl) ~p:pfix
    | hd :: tl -> hd :: rem tl ~p:pfix

  (** todo there is a fancy thing to do this without a closure**)
  let contains t pfix = List.exists t ~f:(fun p -> Prefix.covers p pfix) 
end
