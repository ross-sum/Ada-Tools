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

   with Ada.Strings.Wide_Maps;
   with dStrings;                       use dStrings;
   with Generic_Binary_Trees_With_Data;
   package Wide_String_Maps is
   
      type wide_string_mapping is private;
   
      procedure To_Mapping
      (from : in wide_character; to : in text;
      for_map : in out wide_string_mapping);
   
      function Value (map : in wide_string_mapping;
      element : in wide_character) return text;
   
   private
      package Wide_String_Mapping_Tree is new 
      Generic_Binary_Trees_With_Data(
      T=> wide_character, D=> text);
   
      type wide_string_mapping is record
            the_list : Wide_String_Mapping_Tree.list;
         end record;
   
   end Wide_String_Maps;