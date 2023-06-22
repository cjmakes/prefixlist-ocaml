open Base

module IP : sig
  type t
  
  (** Parse an ipv4 from dotted quad **)
  val of_string : string -> t

  (** Print an ipv4 address as dotted quad **)
  val to_string : t -> string

  (** Implements compare pattern for ips **)
  val eq: t -> t -> bool

  (** Apply the given prefix to t **)
  val mask: t -> int -> t

  (** Inrement t by x ips **)
  val incr: t -> int -> t
end = struct
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

module Prefix : sig
  type t
  (** Parse an ipv4 CIDR notation **)
  val of_string: string -> t

  (** Return a prefix as CIDR notation **)
  val to_string: t -> string

  val eq: t -> t -> bool

  val contains: t -> IP.t -> bool
  val covers: t -> t -> bool
  val split: t -> t list
end = struct 
  type t = {host: IP.t; pfix: int}

  let contains t ip = IP.eq t.host (IP.mask ip t.pfix)

  let covers lhs rhs = (IP.eq lhs.host (IP.mask rhs.host lhs.pfix)) && (lhs.pfix < rhs.pfix)

  let eq lhs rhs = IP.eq lhs.host rhs.host && rhs.pfix = rhs.pfix

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

module PrefixList : sig
  type t
  val add: t -> Prefix.t -> t
  val rem: t -> Prefix.t -> t
  val contains: t -> Prefix.t -> bool
end = struct
  type t = Prefix.t list

  let add t pfix = (pfix :: t)

  let contains t pfix = List.exists t ~f:(Prefix.eq pfix)
  
  let rec rem (t: Prefix.t list) pfix = 
  let open Prefix in 
  let open List in 
    match t with
    | [] as l -> l 
    | hd :: tl when eq hd pfix -> tl
    | hd :: tl when covers hd pfix -> rem (append (split hd) tl) pfix
    | hd :: tl -> hd :: rem tl pfix
end
