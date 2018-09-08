open Core

let file = "input.txt"

exception Bad_input of string

let seq = "abcdefghijklmnop"

let str_to_char s =
  (* this default is bogus *)
  Option.value (List.nth (String.to_list s) 0) ~default:'a'

let get_input () =
  let f = open_in file in
  input_line f

let spin seq op =
  match op with
  | None -> seq
  | Some s ->
      let n = int_of_string s in
      let sl = Core.String.length seq in
      let offset = sl - n in
      let tl = Core.String.sub seq ~pos:0 ~len:offset in
      let hd = Core.String.sub seq ~pos:offset ~len:n in
      hd ^ tl

let exchange seq op =
  match op with
  | None -> seq
  | Some s ->
      let idxs = List.map (String.split s '/') ~f:int_of_string in
      (* 0 as default is bogus *)
      let idx1 = Option.value (List.nth idxs 0) ~default:0 in
      (* 0 as default is bogus *)
      let idx2 = Option.value (List.nth idxs 1) ~default:0 in
      let c1 = Core.String.sub seq ~pos:idx1 ~len:1 in
      let c2 = Core.String.sub seq ~pos:idx2 ~len:1 in
      let swap_chars idx c =
        if idx == idx1 then str_to_char c2
        else if idx == idx2 then str_to_char c1
        else c
      in
      Core.String.mapi seq ~f:swap_chars

let partner seq op =
  match op with
  | None -> seq
  | Some s ->
      let op_split = String.split s ~on:'/' in
      let p1 = Option.value (List.nth op_split 0) ~default:"" in
      let p2 = Option.value (List.nth op_split 1) ~default:"" in
      let p1_pos =
        Option.value
          (Base.String.lfindi ~pos:0 ~f:(fun x c -> c == str_to_char p1) seq)
          ~default:0
      in
      let p2_pos =
        Option.value
          (Base.String.lfindi ~pos:0 ~f:(fun x c -> c == str_to_char p2) seq)
          ~default:0
      in
      let exchange_op = string_of_int p1_pos ^ "/" ^ string_of_int p2_pos in
      exchange seq (Some exchange_op)

let perform_move seq move =
  let move_type = Core.String.nget move 0 in
  match move_type with
  | 's' ->
      let move_op = Core.String.chop_prefix move ~prefix:"s" in
      spin seq move_op
  | 'x' ->
      let move_op = Core.String.chop_prefix move ~prefix:"x" in
      exchange seq move_op
  | 'p' ->
      let move_op = Core.String.chop_prefix move ~prefix:"p" in
      partner seq move_op
  | _ -> seq

let rec dance seq instructions =
  match instructions with
  | [] -> seq
  | head :: tail -> dance (perform_move seq head) tail

let raw_input = get_input ()

let instructions = Core.String.split raw_input ','

let mutate_ht ht k =
  match Core.Hashtbl.find ht k with
  | None ->
      let _ = Core.Hashtbl.add ht k 1 in
      ()
  | Some c ->
      let _ = Core.Hashtbl.set ht k (c + 1) in
      ()

let rec find_cycle seq max iter ht =
  let _ = mutate_ht ht seq in
  if iter == max then seq
  else find_cycle (dance seq instructions) max (iter + 1) ht

let ht = Core.String.Table.create () ~size:5000

let _ = find_cycle seq 1000 0 ht

let cycle = List.length (Hashtbl.keys ht)

let cycle_mod = 1_000_000_000 mod cycle

let result = find_cycle seq (cycle + cycle_mod) 0 ht

let () = print_endline result

let _ =
  if result <> "abocefghijklmndp" then print_endline "wrong answer!" else ()
