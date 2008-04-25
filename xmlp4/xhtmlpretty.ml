(* Ocsigen
 * Copyright (C) 2007 Vincent Balat
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception; 
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)


open Format
open XML

let ocsigenadv =
  "<!-- Page generated by OCaml with Ocsigen.
See http://www.ocsigen.org and http://caml.inria.fr for information -->\n"

let xh_string = str_formatter

let taille_tab = 2

let xh_topxml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n\n"

let id x = x

(* The following tags are written <br />, etc. 
   The other empty tags are written <p></p> for html compatibility.
   See guidelines here:
   http://www.w3.org/TR/xhtml1/#guidelines
 *)
let emptytags = ["hr"; "br"; "img"; "meta"; "link"; "input"; 
                 "col"; "area"; "param"; "base"; "basefont"; 
                 "isindex"; "frame"]


let blocktags = [ "fieldset"; "form"; "address"; "body"; "head"; "blockquote"; "div"; "html"; "h1"; "h2"; "h3"; "h4"; "h5"; "h6"; "p"; "dd"; "dl"; "li"; "ol"; "ul"; "colgroup"; "table"; "tbody"; "tfoot"; "thead"; "td"; "th"; "tr" ]
    
let semiblocktags = [ "pre"; "style"; "title" ]

(* A pretty_printer that handles inline tags properly 
    (based on code by Julien Mineraud) *)
let x_print, xh_print = 

  let aux ~width ~encode ?(html_compat = false) doctype arbre =
    let endemptytag = if html_compat then ">" else " />" in
    let rec xh_print_attrs encode attrs = match attrs with
      [] ->  ();
    | attr::queue -> 
        pp_print_string xh_string (" "^(XML.attrib_to_string encode attr));
        xh_print_attrs encode queue
          
    and xh_print_text texte i is_first = 
      pp_print_string xh_string texte
        
    and xh_print_closedtag encode tag attrs i is_first =
      if List.mem tag emptytags
      then begin
        pp_open_tbox xh_string ();
        if (i > 0) || is_first then 
          pp_force_newline xh_string ();
        if ((i > 0) || is_first) then
          pp_print_tbreak xh_string (taille_tab*i) 0;
        pp_print_string xh_string ("<"^tag);
        xh_print_attrs encode attrs;
        pp_print_string xh_string endemptytag;
        pp_close_tbox xh_string ()
      end
      else begin
        pp_open_tbox xh_string ();
        if (i > 0) || is_first then 
          pp_force_newline xh_string ();
        if ((i > 0) || is_first) then
          pp_print_tbreak xh_string (taille_tab*i) 0;
        pp_print_string xh_string ("<"^tag);
        xh_print_attrs encode attrs;
        pp_print_string xh_string "></";
        pp_print_string xh_string tag;
        pp_print_string xh_string ">";
        pp_close_tbox xh_string ()
      end
      
    and xh_print_inlinetag encode tag attrs taglist i is_first = 
      pp_print_string xh_string ("<"^tag);
      xh_print_attrs encode attrs;
      pp_print_string xh_string ">";
      xh_print_taglist taglist 0 false false;
      pp_print_string xh_string ("</"^tag^">")
        
    and xh_print_blocktag encode tag attrs taglist i = 
      if taglist = [] 
      then xh_print_closedtag encode tag attrs i true
      else begin
        pp_open_tbox xh_string ();
        pp_force_newline xh_string ();
        if i > 0 then
          pp_print_tbreak xh_string (taille_tab*i) 0;
        pp_print_string xh_string ("<"^tag);
        xh_print_attrs encode attrs;
        pp_print_string xh_string ">";
        
        xh_print_taglist_removews taglist (i+1) true;
        
        pp_force_newline xh_string ();
        if i > 0 then
          pp_print_tbreak xh_string (taille_tab*i) 0;
        pp_print_string xh_string ("</"^tag^">");
        pp_close_tbox xh_string ()
      end

    and xh_print_semiblocktag encode tag attrs taglist i = 
      (* New line before and after but not inside, for ex for <pre> *)
      if taglist = []
      then xh_print_closedtag encode tag attrs i true
      else begin
        pp_open_tbox xh_string ();
        pp_force_newline xh_string ();
        if i > 0 then
          pp_print_tbreak xh_string (taille_tab*i) 0;
        pp_print_string xh_string ("<"^tag);
        xh_print_attrs encode attrs;
        pp_print_string xh_string ">";
        
        xh_print_taglist taglist 0 false false;

        pp_print_string xh_string ("</"^tag^">");
        pp_close_tbox xh_string ()
      end

    and xh_print_taglist_removews taglist i is_first = 
      match taglist with
        (Whitespace s)::l -> xh_print_taglist_removews l i is_first
      | l -> xh_print_taglist l i is_first true


    and print_nodes ws1 name xh_attrs xh_taglist ws2 queue i is_first removetailingws =
      if (List.mem name blocktags)
      then xh_print_blocktag encode name xh_attrs xh_taglist i
      else 
        (if (List.mem name semiblocktags)
        then xh_print_semiblocktag encode name xh_attrs xh_taglist i
        else begin
          xh_print_text (encode ws1) i is_first;
          xh_print_inlinetag encode name xh_attrs xh_taglist i is_first;
          xh_print_text (encode ws2) i is_first;
        end);
      xh_print_taglist queue i false removetailingws

    and xh_print_taglist taglist i is_first removetailingws = match taglist with 
      
      [] -> pp_open_tbox xh_string ();
        pp_close_tbox xh_string ();

    | (Comment texte)::queue ->
        xh_print_text ("<!--"^(encode texte)^"-->") i is_first;
        xh_print_taglist queue i false removetailingws;

    | (Entity e)::queue ->
        xh_print_text ("&"^e^";") i is_first; (* no encoding *)
        xh_print_taglist queue i false removetailingws;

    | (PCDATA texte)::queue ->
        xh_print_text (encode texte) i is_first;
        xh_print_taglist queue i false removetailingws;

    | (EncodedPCDATA texte)::queue ->
        xh_print_text texte i is_first;
        xh_print_taglist queue i false removetailingws;

    | (Whitespace _)::(Element ("hr",xh_attrs,[]))::(Whitespace _)::queue
    | (Element ("hr",xh_attrs,[]))::(Whitespace _)::queue
    | (Whitespace _)::(Element ("hr",xh_attrs,[]))::queue
    | (Element ("hr",xh_attrs,[]))::queue ->
        xh_print_closedtag id "hr" xh_attrs i is_first;
        xh_print_taglist queue i false removetailingws;

    | (Element (name, xh_attrs, []))::queue ->
        xh_print_closedtag id name xh_attrs i is_first;
        xh_print_taglist queue i false removetailingws;

        (* Balises de presentation, type inline *)
    | (Element (name, xh_attrs, xh_taglist))::queue ->
        xh_print_inlinetag id name xh_attrs xh_taglist i is_first;
        xh_print_taglist queue i false removetailingws;

        (* Balises de type block *)
    | (Whitespace _)::(BlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
    | (BlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
    | (Whitespace _)::(BlockElement (name,xh_attrs,xh_taglist))::queue
    | (BlockElement (name,xh_attrs,xh_taglist))::queue ->
        xh_print_blocktag id name xh_attrs xh_taglist i;
        xh_print_taglist queue i false removetailingws;

        (* Balises de type "semi block", for ex <pre> *)
    | (Whitespace _)::(SemiBlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
    | (SemiBlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
    | (Whitespace _)::(SemiBlockElement (name,xh_attrs,xh_taglist))::queue
    | (SemiBlockElement (name,xh_attrs,xh_taglist))::queue ->
        xh_print_semiblocktag id name xh_attrs xh_taglist i;
        xh_print_taglist queue i false removetailingws;

        (* Nodes and Leafs *)
    | (Whitespace ws1)::(Node (name,xh_attrs,xh_taglist))::(Whitespace ws2)::queue ->
        print_nodes ws1 name xh_attrs xh_taglist ws2 queue i is_first removetailingws

    | (Node (name,xh_attrs,xh_taglist))::(Whitespace ws2)::queue ->
        print_nodes "" name xh_attrs xh_taglist ws2 queue i is_first removetailingws

    | (Whitespace ws1)::(Node (name,xh_attrs,xh_taglist))::queue ->
        print_nodes ws1 name xh_attrs xh_taglist "" queue i is_first removetailingws

    | (Node (name,xh_attrs,xh_taglist))::queue ->
        print_nodes "" name xh_attrs xh_taglist "" queue i is_first removetailingws

    | (Whitespace ws1)::(Leaf (name,xh_attrs))::(Whitespace ws2)::queue ->
        print_nodes ws1 name xh_attrs [] ws2 queue i is_first removetailingws

    | (Leaf (name,xh_attrs))::(Whitespace ws2)::queue ->
        print_nodes "" name xh_attrs [] ws2 queue i is_first removetailingws

    | (Whitespace ws1)::(Leaf (name,xh_attrs))::queue ->
        print_nodes ws1 name xh_attrs [] "" queue i is_first removetailingws

    | (Leaf (name,xh_attrs))::queue ->
        print_nodes "" name xh_attrs [] "" queue i is_first removetailingws

          (* Whitespaces *)
    | (Whitespace(texte))::queue ->
        xh_print_text (encode texte) i is_first;
        xh_print_taglist queue i false removetailingws

    | Empty::queue ->
        xh_print_taglist queue i false removetailingws



    in
    xh_print_taglist [arbre] 0 true false
  in
  ((fun ?(width = 132) ?(encode = encode_unsafe)
      ?html_compat doctype foret ->
        
        pp_set_margin str_formatter width;

        pp_open_tbox xh_string ();
        
        List.iter (aux ?width ?encode ?html_compat doctype) foret;
          
        pp_force_newline xh_string ();
        pp_close_tbox xh_string ();
        
        flush_str_formatter ()),

   (fun ?(width = 132) ?(encode = encode_unsafe)
       ?html_compat doctype arbre ->
         
         pp_set_margin str_formatter width;
         pp_open_tbox xh_string ();
(*  pp_print_string xh_string xh_topxml; Does not work with IE ...
   pp_force_newline xh_string (); *)
         pp_print_string xh_string doctype;
         pp_force_newline xh_string ();
         
         pp_print_string xh_string ocsigenadv;
         pp_force_newline xh_string ();
         
         aux ?width ?encode ?html_compat doctype arbre;
           
         pp_force_newline xh_string ();
         pp_close_tbox xh_string ();
         
         flush_str_formatter ()))


    
let xhtml_print ?(version=`XHTML_01_01) ?width ?encode ?html_compat arbre =
  xh_print ?width ?encode ?html_compat
    (XHTML.M.doctype version) (XHTML.M.toelt arbre)
    
let xhtml_list_print ?(version=`XHTML_01_01)
    ?width ?encode ?html_compat foret =
  x_print ?width ?encode ?html_compat
    (XHTML.M.doctype version) (XHTML.M.toeltl foret)





(*****************************************************************************)
(* print to Ocsigen's streams *)

let x_stream, xh_stream = 

  let aux ~width ~encode ?(html_compat = false) arbre cont =
    let endemptytag = if html_compat then ">" else " />" in
    let rec xh_print_attrs encode attrs cont = match attrs with
    | [] -> cont ();
    | attr::queue -> 
        (Ocsigen_stream.cont (" "^XML.attrib_to_string encode attr)) (fun () ->
        xh_print_attrs encode queue cont)
          
    and xh_print_text texte i is_first cont = 
      (Ocsigen_stream.cont texte) cont
        
    and xh_print_closedtag encode tag attrs i is_first cont =
      if List.mem tag emptytags
      then
        (if (i > 0) || is_first then 
          Ocsigen_stream.cont (String.make (taille_tab*i) ' ')
        else (fun cont -> cont ())) (fun () ->
          (Ocsigen_stream.cont ("<"^tag)) (fun () ->
          xh_print_attrs encode attrs (fun () ->
          (Ocsigen_stream.cont endemptytag) cont)))
      else
        (if (i > 0) || is_first then 
          Ocsigen_stream.cont (String.make (taille_tab*i) ' ')
        else (fun cont -> cont ())) (fun () ->
          (Ocsigen_stream.cont ("<"^tag)) (fun () ->
          xh_print_attrs encode attrs (fun () ->
          (Ocsigen_stream.cont ("></"^tag^">")) cont)))
      
    and xh_print_inlinetag encode tag attrs taglist i is_first cont = 
      (Ocsigen_stream.cont ("<"^tag)) (fun () ->
      xh_print_attrs encode attrs (fun () ->
      (Ocsigen_stream.cont ">") (fun () ->
      xh_print_taglist taglist 0 false false (fun () ->
      (Ocsigen_stream.cont ("</"^tag^">") cont)))))
        
    and xh_print_blocktag encode tag attrs taglist i cont = 
      if taglist = [] 
      then xh_print_closedtag encode tag attrs i true cont
      else begin
        (if i > 0 then
          (Ocsigen_stream.cont ("\n"^String.make (taille_tab*i) ' '))
        else (Ocsigen_stream.cont "\n")) (fun () ->
        (Ocsigen_stream.cont ("<"^tag)) (fun () ->
        xh_print_attrs encode attrs (fun () ->
        (Ocsigen_stream.cont ">") (fun () ->
        
        xh_print_taglist_removews taglist (i+1) true (fun () ->
        
        (if i > 0 then
          (Ocsigen_stream.cont ("\n"^String.make (taille_tab*i) ' '))
        else (Ocsigen_stream.cont "\n")) (fun () ->
        (Ocsigen_stream.cont ("</"^tag^">") cont)))))))

      end

    and xh_print_semiblocktag encode tag attrs taglist i cont = 
      (* New line before and after but not inside, for ex for <pre> *)
      if taglist = []
      then xh_print_closedtag encode tag attrs i true cont
      else begin
        (if i > 0 then
          (Ocsigen_stream.cont ("\n"^String.make (taille_tab*i) ' '))
        else (Ocsigen_stream.cont "\n")) (fun () ->
        (Ocsigen_stream.cont ("<"^tag)) (fun () ->

        xh_print_attrs encode attrs (fun () ->
        (Ocsigen_stream.cont ">") (fun () ->
        
        xh_print_taglist taglist 0 false false (fun () ->

        (Ocsigen_stream.cont ("</"^tag^">") cont))))))

      end

    and xh_print_taglist_removews taglist i is_first cont = 
      match taglist with
      | (Whitespace s)::l -> xh_print_taglist_removews l i is_first cont
      | l -> xh_print_taglist l i is_first true cont


    and print_nodes ws1 name xh_attrs xh_taglist ws2 queue i is_first removetailingws cont =
      (fun cont ->
        if (List.mem name blocktags)
        then xh_print_blocktag encode name xh_attrs xh_taglist i cont
        else 
          (if (List.mem name semiblocktags)
          then xh_print_semiblocktag encode name xh_attrs xh_taglist i cont
          else begin
            xh_print_text (encode ws1) i is_first (fun () ->
            xh_print_inlinetag encode name xh_attrs xh_taglist i is_first (fun () ->
            xh_print_text (encode ws2) i is_first cont))
          end))
        (fun () -> xh_print_taglist queue i false removetailingws cont)

    and xh_print_taglist taglist i is_first removetailingws cont = 
      match taglist with 
      
      | [] -> cont ()

      | (Comment texte)::queue ->
          xh_print_text ("<!--"^(encode texte)^"-->") i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)

      | (Entity e)::queue ->
          xh_print_text ("&"^e^";") i is_first (* no encoding *)
          (fun () -> xh_print_taglist queue i false removetailingws cont)

      | (PCDATA texte)::queue ->
          xh_print_text (encode texte) i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
      | (EncodedPCDATA texte)::queue ->
          xh_print_text texte i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
      | (Whitespace _)::(Element ("hr",xh_attrs,[]))::(Whitespace _)::queue
      | (Element ("hr",xh_attrs,[]))::(Whitespace _)::queue
      | (Whitespace _)::(Element ("hr",xh_attrs,[]))::queue
      | (Element ("hr",xh_attrs,[]))::queue ->
          xh_print_closedtag id "hr" xh_attrs i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
      | (Element (name, xh_attrs, []))::queue ->
          xh_print_closedtag id name xh_attrs i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
              (* Balises de presentation, type inline *)
      | (Element (name, xh_attrs, xh_taglist))::queue ->
          xh_print_inlinetag id name xh_attrs xh_taglist i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
              (* Balises de type block *)
      | (Whitespace _)::(BlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
      | (BlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
      | (Whitespace _)::(BlockElement (name,xh_attrs,xh_taglist))::queue
      | (BlockElement (name,xh_attrs,xh_taglist))::queue ->
          xh_print_blocktag id name xh_attrs xh_taglist i
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
              (* Balises de type "semi block", for ex <pre> *)
      | (Whitespace _)::(SemiBlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
      | (SemiBlockElement (name,xh_attrs,xh_taglist))::(Whitespace _)::queue
      | (Whitespace _)::(SemiBlockElement (name,xh_attrs,xh_taglist))::queue
      | (SemiBlockElement (name,xh_attrs,xh_taglist))::queue ->
          xh_print_semiblocktag id name xh_attrs xh_taglist i
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
              (* Nodes and Leafs *)
      | (Whitespace ws1)::(Node (name,xh_attrs,xh_taglist))::(Whitespace ws2)::queue ->
          print_nodes ws1 name xh_attrs xh_taglist ws2 queue i is_first removetailingws cont
            
      | (Node (name,xh_attrs,xh_taglist))::(Whitespace ws2)::queue ->
          print_nodes "" name xh_attrs xh_taglist ws2 queue i is_first removetailingws cont
            
      | (Whitespace ws1)::(Node (name,xh_attrs,xh_taglist))::queue ->
          print_nodes ws1 name xh_attrs xh_taglist "" queue i is_first removetailingws cont
            
      | (Node (name,xh_attrs,xh_taglist))::queue ->
          print_nodes "" name xh_attrs xh_taglist "" queue i is_first removetailingws cont
            
      | (Whitespace ws1)::(Leaf (name,xh_attrs))::(Whitespace ws2)::queue ->
          print_nodes ws1 name xh_attrs [] ws2 queue i is_first removetailingws cont
            
      | (Leaf (name,xh_attrs))::(Whitespace ws2)::queue ->
          print_nodes "" name xh_attrs [] ws2 queue i is_first removetailingws cont
            
      | (Whitespace ws1)::(Leaf (name,xh_attrs))::queue ->
          print_nodes ws1 name xh_attrs [] "" queue i is_first removetailingws cont
            
      | (Leaf (name,xh_attrs))::queue ->
          print_nodes "" name xh_attrs [] "" queue i is_first removetailingws cont
            
            (* Whitespaces *)
      | (Whitespace(texte))::queue ->
          xh_print_text (encode texte) i is_first
          (fun () -> xh_print_taglist queue i false removetailingws cont)
              
      | Empty::queue ->
          xh_print_taglist queue i false removetailingws cont
            
            
            
    in
    xh_print_taglist [arbre] 0 true false cont
  in
  ((fun ?(width = 132) ?(encode = encode_unsafe)
      ?html_compat doctype foret ->
       
         (List.fold_right
             (fun arbre cont () ->
               aux ?width ?encode ?html_compat arbre cont)
             foret
             
         (fun () -> Ocsigen_stream.empty None))),


   (fun ?(width = 132) ?(encode = encode_unsafe)
       ?html_compat doctype arbre ->

        Ocsigen_stream.cont doctype
        (fun () -> Ocsigen_stream.cont ocsigenadv
        (fun () -> 

          aux ?width ?encode ?html_compat arbre
           
           (fun () -> Ocsigen_stream.empty None)))))

let xhtml_stream ?(version=`XHTML_01_01) ?width ?encode ?html_compat arbre =
  Ocsigen_stream.make
    (fun () ->
      xh_stream ?width ?encode ?html_compat
        (XHTML.M.doctype version) (XHTML.M.toelt arbre))
    
let xhtml_list_stream ?(version=`XHTML_01_01)
    ?width ?encode ?html_compat foret =
  Ocsigen_stream.make
    (fun () ->
      x_stream ?width ?encode ?html_compat
        (XHTML.M.doctype version) (XHTML.M.toeltl foret) ())







