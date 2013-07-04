(* MySQL module for Augeas                    *)
(* Author: Tim Stoop <tim@kumina.nl>          *)
(* Heavily based on php.aug by Raphael Pinson *)
(* <raphink@gmail.com>                        *)
(*                                            *)

module MySQL =
  autoload xfm

(************************************************************************
 * INI File settings
 *************************************************************************)
let comment  = IniFile.comment IniFile.comment_re "#"

let sep      = IniFile.sep IniFile.sep_re IniFile.sep_default

let entry    = [ key IniFile.entry_re . sep . IniFile.sto_to_comment . (comment|IniFile.eol) ] | 
               [ key IniFile.entry_re . store // . (comment|IniFile.eol) ] | 
               [ key /\![A-Za-z][A-Za-z0-9\._-]+/ . del / / " " . store /\/[A-Za-z0-9\.\/_-]+/ . (comment|IniFile.eol) ] |
               comment

(************************************************************************
 * sections, led by a "[section]" header
 * We can't use titles as node names here since they could contain "/"
 * We remove #comment from possible keys
 * since it is used as label for comments
 * We also remove / as first character
 * because augeas doesn't like '/' keys (although it is legal in INI Files)
 *************************************************************************)
let title   = IniFile.indented_title_label "target" IniFile.record_label_re
let record  = IniFile.record title entry

let lns    = IniFile.lns record comment

let filter = (incl "/etc/mysql/my.cnf")
             . (incl "/etc/mysql/conf.d/*.cnf")
             . (incl "/etc/mysql/*.cnf")
             . (incl "/etc/my.cnf")
             . Util.stdexcl

let xfm = transform lns filter


