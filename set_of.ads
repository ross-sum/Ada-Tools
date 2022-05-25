-----------------------------------------------------------------------
--                                                                   --
--                             S E T _ O F                           --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001-2022  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides simple set facilities.                     --
--  This package was inspired by the work of John Barnes, from his   --
--  book, "programming in Ada 95 2nd edition", 1998, section 17.2.   --
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
   type Element is (<>);
   type Index is (<>);
   type List is array (Index range <>) of Element;

   package Set_Of is

     -- example of usage:
     -- type Primary_List is array (positive range <>) of Primary;
     -- package Primary_Sets is new Set_Of(Element => Primary,
     --                                    Index   => Positive,
     --                                    List    => Primary_List);
     -- type colour is new Primary_Sets.Set;
     -- white : constant colour := Empty;
     -- black : constant colour := Full;

   type Set is private;

   function Empty return Set;
   function Full return Set;

   function Make_Set(L: List) return Set;
   function Make_Set(E: Element) return Set;
   function Make_Set(E_first, E_last: Element) return Set;
   function Decompose(S: Set) return List;
   
   function First_In(the_set : Set) return Element;
   function Last_In (the_set : Set) return Element;
   function Next_In (the_set : Set; from: Element) return Element;
   function Prev_In (the_set : Set; from: Element) return Element;

   function "+" (S, T: Set) return Set;   -- union
   function "*" (S, T: Set) return Set;   -- intersection
   function "-" (S, T: Set) return Set;   -- symetric difference
   function "<" (E: Element; S: Set) return boolean; --inclusion
   function "<=" (S, T: Set) return boolean;  -- contains
   function Size(of_set: Set) return natural;  -- number of elements

private

   type Set is array (Element) of boolean;

end Set_Of;
