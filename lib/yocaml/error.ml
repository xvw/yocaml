type t =
  | List of t Preface.Nonempty_list.t
  | Labelled_list of string * t Preface.Nonempty_list.t
  | Unix of string * string * string
  | Unreadable_file of string
  | Missing_field of string
  | Invalid_field of string
  | Invalid_metadata of string
  | Required_metadata of string list
  | Yaml of string
  | Mustache of string
  | Invalid_date of string
  | Invalid_year of int
  | Invalid_day of int
  | Invalid_month of int
  | Invalid_range of int * int * int
  | Unknown of string
  | Message of string

exception Error of t

let rec pp formater error =
  let ppf x = Format.fprintf formater x in
  match error with
  | Unknown message -> ppf "Unknown (%s)" message
  | Message message -> ppf "%s" message
  | Unix (error, fname, arg) -> ppf "Unix (%s, %s, %s)" error fname arg
  | Unreadable_file filename -> ppf "Unreadable_file (%s)" filename
  | Missing_field field -> ppf "Missing_field (%s)" field
  | Invalid_field field -> ppf "Invalid_field (%s)" field
  | Invalid_metadata metadata -> ppf "Invalid_metadata (%s)" metadata
  | Yaml message -> ppf "Yaml (%s)" message
  | Mustache message -> ppf "Mustache (%s)" message
  | Required_metadata list ->
    ppf "Required_metadata (%a)" (Preface.List.pp Format.pp_print_string) list
  | Invalid_date str -> ppf "Invalid_date (%s)" str
  | Invalid_year x -> ppf "Invalid_year (%d)" x
  | Invalid_day x -> ppf "Invalid_day (%d)" x
  | Invalid_month x -> ppf "Invalid_month (%d)" x
  | Invalid_range (x, min, max) ->
    ppf "Invalid_range (%d, [%d, %d[)" x min max
  | List nonempty_list ->
    ppf "List (%a)" (Preface.Nonempty_list.pp pp) nonempty_list
  | Labelled_list (message, nonempty_list) ->
    ppf "List: %s (%a)" message (Preface.Nonempty_list.pp pp) nonempty_list
;;

let to_string = Format.asprintf "%a" pp
let to_exn error = Error error
let to_try error = Preface.Result.Error error

let to_validate error =
  let open Preface in
  Validation.Invalid (Nonempty_list.create error)
;;

let raise' error = raise (to_exn error)

let rec equal x y =
  match x, y with
  | Message a, Message b -> String.equal a b
  | Unknown a, Unknown b -> String.equal a b
  | Unix (a, b, c), Unix (x, y, z) ->
    a = x && String.equal b y && String.equal c z
  | Unreadable_file a, Unreadable_file b -> String.equal a b
  | List a, List b -> Preface.Nonempty_list.equal equal a b
  | Missing_field a, Missing_field b -> String.equal a b
  | Invalid_field a, Invalid_field b -> String.equal a b
  | Invalid_metadata a, Invalid_metadata b -> String.equal a b
  | Yaml a, Yaml b -> String.equal a b
  | Mustache a, Mustache b -> String.equal a b
  | Required_metadata a, Required_metadata b ->
    Preface.List.equal String.equal a b
  | Invalid_date a, Invalid_date b -> String.equal a b
  | Invalid_year a, Invalid_year b -> Int.equal a b
  | Invalid_day a, Invalid_day b -> Int.equal a b
  | Invalid_month a, Invalid_month b -> Int.equal a b
  | Invalid_range (a, b, c), Invalid_range (aa, bb, cc) ->
    List.equal Int.equal [ a; b; c ] [ aa; bb; cc ]
  | _ -> false
;;
