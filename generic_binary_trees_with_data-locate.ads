-----------------------------------------------------------------------
--                                                                   --
--    G E N E R I C _ B I N A R Y _ T R E E S _ W I T H _ D A T A    --
--                           . L O C A T E                           --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a locate facility for the generic binary  --
--  trees with data package.                                         --
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

generic
   with function Comparison (comparitor, contains: T) return Boolean;
      -- Return true if "contains" exists within "comparitor" at
      -- the appropriate point.  For instance, to test with a
      -- Starting With type scenario on a type string, you would map
      -- a function that utilised Sub_String to ensure that "contains"
      -- was at the beginning (i.e. from character position 1) of
      -- "comparitor".
   with function Clear return T is <>;
      -- Return an "empty" T (for when the key is not found).
   go_down_left_if_less_than : boolean := true;
      -- The direction in the tree to go if the result of the
      -- Comparison function returns a false result.

   package Generic_Binary_Trees_With_Data.Locate is

   function The_Full_Key (for_partial_key : in T;
   in_the_list : in list) return T;

end Generic_Binary_Trees_With_Data.Locate;
