
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