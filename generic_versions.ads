-----------------------------------------------------------------------
--                                                                   --
--                  G E N E R I C _ V E R S I O N S                  --
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
--  $Log: generic_versions.ads,v $
--  Revision 1.1  2001/04/29 01:14:03  ross
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

with dStrings;  -- Ada.Strings.Wide_Unbounded;
generic
   version_number : wide_string;
      -- The application's version number.  It is normally of the
      -- form re.cha.bug where re is the revision, cha is the
      -- change and bug is the defect repair number for the change.
      -- The revision increments when the change is major, say
      -- requiring a rewrite to a significant section, perhaps more
      -- than 20%, of the code or a significant change to the design.
   the_title : wide_string;
      -- The application's title (as ought to be displayed in the
      -- title bar).
   package Generic_Versions is

   function Version           return wide_string;
   function Application_Title return wide_string;
   function Application_Name  return wide_string;
   function Computer_Name     return wide_string;

   procedure Register(revision, for_module : in wide_string);
   function Revision_List     return wide_string;

private
   use dStrings;  -- Ada.Strings.Wide_Unbounded;

   type revision_list_register;
   type revision_list_register_pointer is access revision_list_register;
   type revision_list_register is record
         revision, 
         module     : text  := Clear;
         	-- unbounded_wide_string := null_unbounded_wide_string;
         next, last : revision_list_register_pointer;
      end record;
   revision_register : revision_list_register_pointer;
   first_revision    : revision_list_register_pointer;

end Generic_Versions;