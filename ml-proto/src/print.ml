(*
 * (c) 2015 Andreas Rossberg
 *)

open Ast
open Source
open Printf


(* Types *)

open Types

let func_type f =
  let {Ast.params; results; _} = f.it in
  {ins = List.map Source.it params; outs = List.map Source.it results}

let string_of_table_type = function
  | None -> "()"
  | Some t -> "(" ^ string_of_func_type t ^ ")*"


let print_var_sig prefix i t =
  printf "%s %d : %s\n" prefix i (Types.string_of_value_type t.it)

let print_func_sig prefix i f =
  printf "%s %d : %s\n" prefix i (Types.string_of_func_type (func_type f))

let print_export_sig prefix str f =
  printf "%s %s : %s\n" prefix str (Types.string_of_func_type (func_type f))

let print_table_sig prefix i t_opt =
  printf "%s %d : %s\n" prefix i (string_of_table_type t_opt)


(* Ast *)

let print_func i f =
  print_func_sig "func" i f

let print_global i t =
  print_var_sig "global" i t

let print_export m str x =
  print_export_sig "export" str (List.nth m.it.funcs x.it)

let print_table m i tab =
  let t_opt =
    match tab.it with
    | [] -> None
    | x::_ -> Some (func_type (List.nth m.it.funcs x.it))
  in print_table_sig "table" i t_opt


let print_module m =
  let {funcs; globals; exports; tables} = m.it in
  List.iteri print_func funcs;
  List.iteri print_global globals;
  Ast.ExportMap.iter (print_export m) exports;
  List.iteri (print_table m) tables;
  flush_all ()

let print_module_sig m =
  Ast.ExportMap.iter (print_export m) m.it.exports;
  flush_all ()


let print_values vs =
  let ts = List.map Values.type_of vs in
  printf "%s : %s\n"
    (Values.string_of_values vs) (Types.string_of_expr_type ts);
  flush_all ()

