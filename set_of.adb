-----------------------------------------------------------------------
--                                                                   --
--                             S E T _ O F                           --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides simple set facilities.                    --
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
   -- generic
   -- type Element is (<>);
   -- type Index is (<>);
   -- type List is array (Index range <>) of Element;

   package body Set_Of is

      -- type Set is private;
      -- private
      --    type Set is array (Element) of boolean;

      function Empty return Set is
      begin
         return (Set'Range => false);
      end Empty;

      function Full return Set is
      begin
         return (Set'Range => true);
      end Full;

      function Make_Set(L: List) return Set is
         the_set : Set := Empty;
      begin
         for item in L'Range loop
            the_set(L(item)) := true;
         end loop;
         return the_set;
      end Make_Set;

      function Make_Set(E: Element) return Set is
         the_set : Set := Empty;
      begin
         the_set(E) := true;
         return the_set;
      end Make_Set;

      function Set_Width return Index is
        -- Need to create a list that is only as wide as a set.
        -- This works out how wide in 'Index' we need to be.
         count : Index := Index'First;
      begin
         for E in Set'Range loop
            count := Index'Succ(count);
         end loop;
         return count;
      end Set_Width;

      function Decompose(S: Set) return List is
         the_list  : List(Index'First .. Set_Width);
         item      : Index := Index'First;
      begin
         for E in Set'Range loop
            if S(E) then
               the_list(item) := E;
               item := Index'Succ(item);
            end if;
         end loop;
         return the_list;
      end Decompose;

      function "+" (S, T: Set) return Set is
         -- union
      begin
         return S or T;
      end "+";

      function "*" (S, T: Set) return Set is
         -- intersection
      begin
         return S and T;
      end "*";

      function "-" (S, T: Set) return Set is
         -- symetric difference
      begin
         return S xor T;
      end "-";

      function "<" (E: Element; S: Set) return boolean is
         --inclusion
      begin
         return S(E);
      end "<";

      function "<=" (S, T: Set) return boolean is
         -- contains
      begin
         return (S and T) = S;
      end "<=";

      function Size(of_set: Set) return natural is
         -- number of elements
         items : natural := 0;
      begin
         for item in Set'Range loop
            if of_set(item) then
               items := items + 1;
            end if;
         end loop;
         return items;
      end Size;

   begin
      null;
   end Set_Of;
