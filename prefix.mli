module IP : sig
  type t

  val of_string : string -> t
  val to_string : t -> string
  val eq: t -> t -> bool

  val mask: t -> int -> t
  val incr: t -> int -> t
end

module Prefix : sig
  type t

  val of_string: string -> t
  val to_string: t -> string
  val eq: t -> t -> bool

  val contains: t -> IP.t -> bool
  val covers: t -> t -> bool
  val split: t -> t list
end

module PrefixList : sig
  type t
  val empty: t
  val add: t -> p: Prefix.t -> t
  val rem: t -> p: Prefix.t -> t
  val contains: t -> Prefix.t -> bool
end
