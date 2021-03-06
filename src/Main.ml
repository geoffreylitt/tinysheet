[%raw {|import ("./tinysheet.css")|}]

(* This line opens the Tea.App modules into the current scope for Program access functions and types *)
open Tea

(* This opens the Elm-style virtual-dom functions and types into the current scope *)
open Tea.Html

open Util

type cell = int * int

type direction = Up | Down | Left | Right

type value = 
  | Number of int
  | String of string

(* Let's create a new type here to be our main message type that is passed around *)
type msg =
  | Select of cell  (* This will be our message to increment the counter *)
  | Move of direction
  | Key_pressed of Keyboard.key_event
  | Edit of value
  [@@bs.deriving {accessors}] (* This is  nice quality-of-life addon from Bucklescript, it will generate function names for each constructor name, optional, but nice to cut down on code, this is unused in this example but good to have regardless *)

module C = struct
  type t = cell
  let compare = compare
  let equal = ( = )
end

module CellMap = Map.Make(C)

type model = {
  selection : cell;
  values : value CellMap.t 
}

let string_of_value (value : value) : string = 
  match value with
  | Number n -> string_of_int n
  | String s -> s

let subscriptions _model = Keyboard.downs key_pressed

(* This is optional for such a simple example, but it is good to have an `init` function to define your initial model default values, the model for Counter is just an integer *)
let init () = {
  selection = (0, 0);
  values = CellMap.add (0, 0) (Number 5) CellMap.empty;
}, Cmd.none

(* This is the central message handler, it takes the model as the first argument *)
let update model = function (* These should be simple enough to be self-explanatory, mutate the model based on the message, easy to read and follow *)
  | Select c -> { model with selection = c }, Cmd.none
  | Key_pressed key_event ->
    model,
    begin match key_event.key_code with
    | 37 -> Cmd.msg (Move Left)
    | 38 -> Cmd.msg (Move Up)
    | 39 -> Cmd.msg (Move Right)
    | 40 -> Cmd.msg (Move Down)
    | _ -> Cmd.none
    end
  | Move dir -> 
    begin match dir with 
    | Up -> { model with selection = ((fst model.selection) - 1), (snd model.selection) }
    | Down -> { model with selection = ((fst model.selection) + 1), (snd model.selection) }
    | Left -> { model with selection = (fst model.selection), ((snd model.selection - 1)) }
    | Right -> { model with selection = (fst model.selection), ((snd model.selection + 1)) }
    end, Cmd.none
  | Edit value -> { model with values = (CellMap.add model.selection value model.values) }, Cmd.none

(* This is just a helper function for the view, a simple function that returns a button based on some argument *)
let view_button title msg =
  button
    [ onClick msg
    ]
    [ text title
    ]

(* This is the main callback to generate the virtual-dom.
  This returns a virtual-dom node that becomes the view, only changes from call-to-call are set on the real DOM for efficiency, this is also only called once per frame even with many messages sent in within that frame, otherwise does nothing *)
let view (model : model) =
  div
    [] [
      div [] [
        input'
          [
            classList ["formula-editor", true];
            onInput (fun value -> (Edit (String value)));
            value (if (CellMap.mem model.selection model.values)
            then string_of_value (CellMap.find model.selection model.values)
            else "")
          ]
          []
      ]
      ; div []
      (List.map (fun row -> div [classList ["sheet-row", true]] 
        (List.map (fun col -> div
          [
            onClick (Select (row, col))
            ; classList ["sheet-cell", true]
            ; style "border" (if model.selection = (row, col) then "solid thin blue" else "solid thin #ddd")
          ]
          [
            if (CellMap.mem (row, col) model.values)
            then text (string_of_value (CellMap.find (row, col) model.values))
            else noNode
          ]) (range 10))
      ) (range 10))]

(* This is the main function, it can be named anything you want but `main` is traditional.
  The Program returned here has a set of callbacks that can easily be called from
  Bucklescript or from javascript for running this main attached to an element,
  or even to pass a message into the event loop.  You can even expose the
  constructors to the messages to javascript via the above [@@bs.deriving {accessors}]
  attribute on the `msg` type or manually, that way even javascript can use it safely. *)
let main =
  App.standardProgram {
    init
    ; update
    ; view
    ; subscriptions
  }