-----------------------------------------------------------------------
--                                                                   --
--                   W I D E   S T R I N G   M A P S                 --
--                                                                   --
--                           $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 2004  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides sophisticated error logging facilities    --
--  to an application.                                               --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--                                                                   --
--  This  library is free software; you can redistribute it  and/or  --
--  modify it under terms of the GNU Lesser General  Public Licence  --
--  as  published by the Free Software Foundation;  either  version  --
--  2.1 of the licence, or (at your option) any later version.       --
--  This library is distributed in hope that it will be useful, but  --
--  WITHOUT  ANY  WARRANTY; without even the  implied  warranty  of  --
--  MERCHANTABILITY  or FITNESS FOR A PARTICULAR PURPOSE.  See  the  --
--  GNU Lesser General Public Licence for more details.              --
--  You  should  have  received a copy of the  GNU  Lesser  General  --
--  Public  Licence along with this library.  If not, write to  the  --
--  Free Software Foundation, 59 Temple Place -  Suite 330, Boston,  --
--  MA 02111-1307, USA.                                              --
--                                                                   --
-----------------------------------------------------------------------

   -- with Ada.Strings.Wide_Maps;
   -- with dStrings;                       use dStrings;
   -- with Generic_Binary_Trees_With_Data;
   --@ with Error_Log;
   package body Wide_String_Maps is
   
      -- type wide_string_mapping is private;
      -- private
      --    package Wide_String_Mapping_Tree is new 
      --    Generic_Binary_Trees_With_Data(
      --    T=> wide_character, D=> text);
      --    type wide_string_mapping is record
      --          the_list : Wide_String_Mapping_Tree.list;
      --       end record;
      use Wide_String_Mapping_Tree;
   
      procedure To_Mapping
      (from : in wide_character; to : in text;
      for_map : in out wide_string_mapping) is
      begin
         -- Error_Log.Debug_Data(9, "Mapping left part:" & 
            -- from & ", right part:" & To_String(to) & ".");
         Insert(into=>for_map.the_list,the_index=>from,the_data=>to);
      end To_Mapping;
   
      function Value (map : in wide_string_mapping;
      element : in wide_character) return text is
         working_map : Wide_String_Mapping_Tree.list;
      begin
         if The_List_Contains(the_item=>element, 
         in_the_list=>map.the_list)
         then
            -- Error_Log.Debug_Data(9, "Found " & element & ".");
            Assign(map.the_list, to => working_map);
            Allow_Shallow_Copy(working_map);  -- stop deletion at end
            First(in_the_list => working_map);
            Find(the_item=>element, in_the_list=>working_map);
            -- if Is_End(of_the_list => working_map) then
               -- Error_Log.Debug_Data(9, "At end (did not fetch it).");
            -- end if;
            return Deliver_Data(from_the_list => working_map);
         else
            -- Error_Log.Debug_Data(9, "Did not find " & element & ".");
            return to_text(from_wide => element);
         end if;
      end Value;
   
   end Wide_String_Maps;