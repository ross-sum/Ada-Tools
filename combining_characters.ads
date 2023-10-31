-----------------------------------------------------------------------
--                                                                   --
--              C O M B I N I N G _ C H A R A C T E R S              --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2023  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  builds and provides information on  the  set  of  --
--  combining  characters  in the short  (from  Ada's  perspective,  --
--  Wide_Character) set.                                             --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  Combining_Characters is free software; you can redistribute  it  --
--  and/or modify it under terms of the GNU General Public  Licence  --
--  as published by the Free Software Foundation; either version 2,  --
--  or  (at  your  option)  any  later  version.   Cell_Writer   is  --
--  distributed  in  hope that it will be useful, but  WITHOUT  ANY  --
--  WARRANTY; without even the implied warranty of  MERCHANTABILITY  --
--  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public  --
--  Licence f or more details.  You should have received a copy  of  --
--  the  GNU  General Public Licence  distributed  with  Combining_  --
--  Characters.  If not, write to the Free Software Foundation,  51  --
--  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.        --
--                                                                   --
-----------------------------------------------------------------------
with Set_of;
package Combining_Characters is

   -- There is a standard list of combining characters.  this list is not set
   -- up as a set.  It also does not include  the Blissymbolic characters
   -- (currently located in the Private area from E100 to E18C).
   -- Here we create a set of combining characters.
   type character_list is array (natural range <>) of wide_character;
   package Combining_Sets is new Set_Of(Element => wide_character,
                                        Index   => natural,
                                        List    => character_list);
   use Combining_Sets;
   subtype combining_character_set  is Combining_Sets.Set;
   
   function Combining_Check_On(the_character:in wide_character) return boolean;
      -- Returns true if the specified character is combining.

   function The_Combining_Characters return combining_character_set;
    
   procedure Add_To_The_Combining_Characters(the_character:in wide_character);
    
private

   all_combining_characters : combining_character_set := Empty;
   procedure Initialise_Combining_Characters;
   
end Combining_Characters;