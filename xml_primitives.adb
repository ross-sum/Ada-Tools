-----------------------------------------------------------------------
--                                                                   --
--                      X M L   P R I M I T I V E S                  --
--                                                                   --
--                        P a c k a g e   B o d y                    --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2003-2020  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  library  provides a primitive interface for  reading  and  --
--  traversing XML files.  It ssumes the XML file is nested and can  --
--  extract  a nest at any level.  It relies on the  Hyper  Quantum  --
--  library  tools  dStrings (which, these days, is built  on  wide  --
--  unbounded strings, but was developed under Ada 83 when they did  --
--  not exist) and on the standard Wide_Text_IO library.             --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  XML Primitives is free software; you can redistribute it and/or  --
--  modify  it under terms of the GNU  General  Public  Licence  as  --
--  published by the Free Software Foundation; either version 2, or  --
--  (at   your  option)  any   later  version.   XML Primitives  is  --
--  distributed  in  hope that it will be useful,  but  WITHOUT  ANY --
--  WARRANTY; without even the implied warranty of  MERCHANTABILITY  --
--  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public  --
--  Licence for  more details.  You should have received a copy  of  --
--  the GNU General Public Licence distributed with Port_Logger. If  --
--  not,  write to the Free Software Foundation, 59 Temple Place  -  --
--  Suite 330, Boston, MA 02111-1307, USA.                           --
--                                                                   --
-----------------------------------------------------------------------
-- with UTF8_Text_IO;
package body XML_Primitives is

   function Strip_Comments(from_text : text) return text is
      soc        : natural := 0;  -- start of comment
      the_result : text    := from_text;
   begin
      while soc < Length(the_result) loop
         soc := locate(fragment=>"<!--", within=>the_result);
         if soc > 0 then  -- comment exists
            Delete(the_result, soc, 4);  -- start of comment
            while Length(the_result) > soc and 
            Locate(fragment=>"-->", within=>the_result) /= 1 
            loop
               Delete(the_result, soc, 1);
            end loop;
            if Length(the_result) >= soc + 3 then
               Delete(the_result, soc, 3); -- delete '-->'
            end if;
         else -- no (more) comments
            soc := Length(the_result);
         end if;
      end loop;
      return the_result;
   end Strip_Comments;

   function Get_Nest(for_section : wide_string; from_text : text) 
   return text is
      son : natural;             -- start of nest
      son_count  : natural:= 1;  -- in case of nests within nests
      the_result : text;
   begin
      Clear(the_result);  -- ensure default of empty
      son := locate('<' & for_section & '>', from_text);
         -- WAS: Upper_Case(from_text));
      if son > 0 then  -- nest exists
         -- move past nest header
         son := son + for_section'Length + 2;  
         -- read in text until hit nest tail (</for_section>)
         for cntr in son .. Length(from_text) loop
            Append(Element(from_text, cntr), the_result);
            declare
               del_start  : integer :=
               cntr-son+1-(for_section'Length+3)+1;
            begin
               if cntr >= son+for_section'Length+2 and then
               '<' & for_section & '>' = Value( --Upper_Case(
               Sub_String(the_result, 
               cntr-son+1-(for_section'Length+2)+1,
               for_section'Length+2)) -- )
               then
                  son_count := son_count + 1;
               elsif cntr>=son+for_section'Length+3 and then
               "</" & for_section & '>' = Value( --Upper_Case(
               Sub_String(the_result, del_start,
               for_section'length+3))  -- )
               then
                  son_count := son_count - 1;
                  if son_count = 0 then  -- got what we are after
                     Delete(the_result, del_start,
                        for_section'Length+3);
                     return the_result;
                  end if;
               end if;
            end;
         end loop;
      end if;
      return the_result;
   end Get_Nest;

   function Get_Nest(for_section : wide_string; 
   from_file : Ada.Wide_Text_IO.file_type) return text is
      use Ada.Wide_Text_IO;
      -- use UTF8_Text_IO;
      input_line : text;
      input_char : wide_character;
      nest_count : natural:= 1;  -- in case of nests within nests
      the_result : text;
   begin
      Clear(the_result);  -- ensure default of empty
      Clear(input_line);
      while not End_Of_File(from_file) and then
      -- locate('<' & for_section & '>', Upper_Case(input_line)) = 0
      locate('<' & for_section & '>', input_line) = 0
      loop
         Get(from_file, input_char);
         Append(input_char, to => input_line);
      end loop;
      if locate('<'& for_section &'>', input_line) > 0
        -- Upper_Case(input_line)) > 0 then  -- nest exists
       then  -- nest exists
         -- do a bit of clean up
         Clear(input_line);
         -- read in text until hit nest tail (</for_section>)
         while not End_Of_File(from_file) loop
            Get(from_file, input_char);
            Append(input_char, to => the_result);
            declare
               del_start  : integer :=
               Length(the_result)-(for_section'Length+3)+1;
            begin
               if Length(the_result) >= for_section'Length+2 and 
               then '<' & for_section & '>' = Value(  -- Upper_Case(
               Sub_String(the_result, 
               Length(the_result)-(for_section'Length+2)+1,
               for_section'Length+2))  -- )
               then
                  nest_count := nest_count + 1;
               elsif Length(the_result)>=for_section'Length+3 and 
               then "</" & for_section & '>' = Value(  --Upper_Case(
               Sub_String(the_result, del_start,
               for_section'length+3))  -- )
               then
                  nest_count := nest_count - 1;
                  if nest_count = 0 then  -- got what we are after
                     Delete(the_result, del_start,
                        for_section'Length+3);
                     return the_result;
                  end if;
               end if;
            end;
         end loop;
      end if;
      return the_result;
   end Get_Nest;

   procedure Strip_White_Space(from_text : in out text) is
      space : constant character := ' ';
      tab   : constant character := character'Val(16#09#);
      lf    : constant character := character'Val(16#0A#);
      cr    : constant character := character'Val(16#0D#);
   begin
      if Length(from_text) > 0 then
         declare
            current_char : character;
         begin
            current_char := Element(from_text, at_position=>1);
            while Length(from_text) > 0 and then 
            (current_char = space or current_char = tab or
            current_char = lf or current_char = cr) loop
               Delete(from_text, 1, 1);
               if Length(from_text) > 0 then
                  current_char := 
                     Element(from_text, at_position=>1);
               end if;
            end loop;
         end;
         declare
            endline : natural;
            current_char : character;
         begin
            endline := Length(from_text);
            current_char := 
               Element(from_text, at_position=>endline);
            while endline > 0 and then
            (current_char = space or current_char = tab or
            current_char = lf or current_char = cr ) loop
               Delete(from_text, endline, 1);
               endline := Length(from_text);
               if endline > 0 then
                  current_char := 
                     Element(from_text, at_position=>endline);
               end if;
            end loop;
         end;
      end if;
   end Strip_White_Space;

   procedure Extract(section : out text; with_name : wide_string;
   from_XML: in out text) is
      start_pos : natural;
   begin
      section := 
         Get_Nest(for_section => with_name, from_text=> from_XML);
      if Length(section) > 0 then
         start_pos := Pos(section,from_XML)-(with_name'Length+2);
         Delete(from_XML, start_pos, with_name'Length + 2);
         Delete(from_XML, start_pos, Length(section));
         if Length(from_XML) >= with_name'Length + 3 then
            Delete(from_XML, start_pos, with_name'Length + 3);
         else
            Clear(from_XML);
         end if;
      end if;
      Strip_White_Space(from_text => from_XML);
   end Extract;

begin
   null;
end XML_Primitives;