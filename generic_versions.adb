-----------------------------------------------------------------------
--                                                                   --
--                  G E N E R I C _ V E R S I O N S                  --
--                                                                   --
--                             B o d y                               --
--                                                                   --
--                         $Revision: 1.1 $                          --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides  version  numbering  details  for   the  --
--  application.   That includes providing the version number,  the  --
--  application title, the application name and the computer  name.  --
--  It also registers revision numbers (from CVS or RCS check-ins).  --
--                                                                   --
--  Version History:                                                 --
--  $Log: generic_versions.adb,v $
--  Revision 1.1  2001/04/29 01:15:03  ross
--  Initial revision
--                                                            --
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

   -- generic
   -- version_number : wide_string;
      -- The application's version number.  It is normally of the
      -- form re.cha.bug where re is the revision, cha is the
      -- change and bug is the defect repair number for the change.
      -- The revision increments when the change is major, say
      -- requiring a rewrite to a significant section, perhaps more
      -- than 20%, of the code or a significant change to the design.
   -- the_title : wide_string;
      -- The application's title (as ought to be displayed in the
      -- title bar).

   with Ada.Command_Line;        use Ada.Command_Line;
   with Sockets.Naming;
   with Ada.Characters.Latin_1;
   with Ada.Strings.Wide_Unbounded;
	with Ada.Characters.Handling; use Ada.Characters.Handling;
   -- with dStrings;
   package body Generic_Versions is
   
      function Version           return wide_string is
      begin
         return version_number;
      end Version;
   
      function Application_Title return wide_string is
      begin
         return the_title;
      end Application_Title;
   
      function Application_Name  return wide_string is
         -- Strips the application name from the command line
         -- use dStrings;
         the_application : text := Value(Command_Name);
         slash : constant text  := To_Text("/");
      begin
         while Length(the_application) > 0 and then
         Pos(slash, the_application) > 0 loop
            Delete(the_application, 1, Pos(slash, the_application));
         end loop;
         return Value(the_application);
      end Application_Name;
   
      function Computer_Name     return wide_string is
         use Sockets.Naming;
      begin
         return To_Wide_String(Host_Name);
      end Computer_Name;
   
      procedure Register(revision, for_module : in wide_string) is
         use Ada.Strings.Wide_Unbounded;
         new_revision : revision_list_register_pointer;
      begin
         new_revision := new revision_list_register;
         new_revision.revision := To_Text(revision);
      	-- To_UnBounded_Wide_String(revision);
         new_revision.module   := To_Text(for_module);
      	-- To_UnBounded_Wide_String(for_module);
         if first_revision /= null and then -- some loaded
         revision_register = null then  -- but not pointing at any
            revision_register := first_revision;
         end if;
         if revision_register /= null then
            while revision_register.next /= null loop
               revision_register := revision_register.next;
            end loop;
            new_revision.last := revision_register;
            revision_register.next := new_revision;
         else
            revision_register := new_revision;
         end if;
         if first_revision = null then  -- not loaded any yet
            first_revision := revision_register;
         end if;
      end Register;
   
      function Revision_List     return wide_string is
         HT : constant wide_character := 
      	To_Wide_Character(Ada.Characters.Latin_1.HT);
      	LF : constant wide_character := 
      	To_Wide_Character(Ada.Characters.Latin_1.LF);
         the_result : text := Clear;
      	-- unbounded_wide_string := null_unbounded_wide_string;
         current_register : revision_list_register_pointer := 
         first_revision;
      begin
         while current_register /= null loop
            if Length(the_result) > 0 then
               the_result := the_result & LF;
            end if;
            the_result := the_result & 
               current_register.revision & HT & current_register.module;
            current_register := current_register.next;
         end loop;
         return Value(the_result);
      end Revision_List;
   
   begin
      null;
   end Generic_Versions;