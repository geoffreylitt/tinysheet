(* Utility function to generate a range of integers from 0 to n-1
adapted from https://stackoverflow.com/questions/36681643/generating-list-of-integers-in-ocaml-without-recursion *)
let rec unfold_right f init =
    match f init with
    | None -> []
    | Some (x, next) -> x :: unfold_right f next
(* ex: 5 -> [0, 1, 2, 3, 4] *)
let range (n:int) =
    let irange x = if x >= n then None else Some (x, x + 1) in
    unfold_right irange 0