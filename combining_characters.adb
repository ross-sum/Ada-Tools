
-- with Set_of;
package body Combining_Characters is

   -- There is a standard list of combining characters.  this list is not set
   -- up as a set.  It also does not include  the Blissymbolic characters
   -- (currently located in the Private area from E100 to E18C).
   -- Here we create a set of combining characters.
   -- type character_list is array (natural range <>) of wide_character;
   -- package Combining_Sets is new Set_Of(Element => wide_character,
   --                                      Index   => natural,
   --                                      List    => character_list);
   -- use Combining_Sets;
   -- subtype combining_character_set  is Combining_Sets.Set;
   -- all_combining_characters : combining_character_set := Empty;
   
   function Combining_Check_On(the_character:in wide_character) return boolean
   is
      -- Returns true if the specified character is combining.
   begin
      return the_character < all_combining_characters;
   end Combining_Check_On;

   procedure Initialise_Combining_Characters is
   -- Set up the list of combining characters
   begin
      all_combining_characters := all_combining_characters +
         Make_Set(Wide_Character'Val(16#300#), Wide_Character'Val(16#34e#))+
         Make_Set(Wide_Character'Val(16#350#), Wide_Character'Val(16#36f#))+
         Make_Set(Wide_Character'Val(16#483#), Wide_Character'Val(16#487#))+
         Make_Set(Wide_Character'Val(16#591#), Wide_Character'Val(16#5bd#))+
         Make_Set(Wide_Character'Val(16#5bf#))+
         Make_Set(Wide_Character'Val(16#5c1#), Wide_Character'Val(16#5c2#))+
         Make_Set(Wide_Character'Val(16#5c4#), Wide_Character'Val(16#5c5#))+
         Make_Set(Wide_Character'Val(16#5c7#))+
         Make_Set(Wide_Character'Val(16#610#), Wide_Character'Val(16#61a#))+
         Make_Set(Wide_Character'Val(16#64b#), Wide_Character'Val(16#65f#))+
         Make_Set(Wide_Character'Val(16#670#))+
         Make_Set(Wide_Character'Val(16#6d6#), Wide_Character'Val(16#6dc#))+
         Make_Set(Wide_Character'Val(16#6df#), Wide_Character'Val(16#6e4#))+
         Make_Set(Wide_Character'Val(16#6e7#), Wide_Character'Val(16#6e8#))+
         Make_Set(Wide_Character'Val(16#6ea#), Wide_Character'Val(16#6ed#))+
         Make_Set(Wide_Character'Val(16#711#))+
         Make_Set(Wide_Character'Val(16#730#), Wide_Character'Val(16#74a#))+
         Make_Set(Wide_Character'Val(16#7eb#), Wide_Character'Val(16#7f3#))+
         Make_Set(Wide_Character'Val(16#816#), Wide_Character'Val(16#819#))+
         Make_Set(Wide_Character'Val(16#81b#), Wide_Character'Val(16#823#))+
         Make_Set(Wide_Character'Val(16#825#), Wide_Character'Val(16#827#))+
         Make_Set(Wide_Character'Val(16#829#), Wide_Character'Val(16#82d#))+
         Make_Set(Wide_Character'Val(16#859#), Wide_Character'Val(16#85b#))+
         Make_Set(Wide_Character'Val(16#8d4#), Wide_Character'Val(16#8e1#))+
         Make_Set(Wide_Character'Val(16#8e3#), Wide_Character'Val(16#8ff#))+
         Make_Set(Wide_Character'Val(16#93c#))+
         Make_Set(Wide_Character'Val(16#94d#))+
         Make_Set(Wide_Character'Val(16#951#), Wide_Character'Val(16#954#))+
         Make_Set(Wide_Character'Val(16#9bc#))+
         Make_Set(Wide_Character'Val(16#9cd#))+
         Make_Set(Wide_Character'Val(16#a3c#))+
         Make_Set(Wide_Character'Val(16#a4d#))+
         Make_Set(Wide_Character'Val(16#abc#))+
         Make_Set(Wide_Character'Val(16#acd#))+
         Make_Set(Wide_Character'Val(16#b3c#))+
         Make_Set(Wide_Character'Val(16#b4d#))+
         Make_Set(Wide_Character'Val(16#bcd#))+
         Make_Set(Wide_Character'Val(16#c4d#))+
         Make_Set(Wide_Character'Val(16#c55#), Wide_Character'Val(16#c56#))+
         Make_Set(Wide_Character'Val(16#cbc#))+
         Make_Set(Wide_Character'Val(16#ccd#))+
         Make_Set(Wide_Character'Val(16#d4d#))+
         Make_Set(Wide_Character'Val(16#dca#))+
         Make_Set(Wide_Character'Val(16#e38#), Wide_Character'Val(16#e3a#))+
         Make_Set(Wide_Character'Val(16#e48#), Wide_Character'Val(16#e4b#))+
         Make_Set(Wide_Character'Val(16#eb8#), Wide_Character'Val(16#eb9#))+
         Make_Set(Wide_Character'Val(16#ec8#), Wide_Character'Val(16#ecb#))+
         Make_Set(Wide_Character'Val(16#f18#), Wide_Character'Val(16#f19#))+
         Make_Set(Wide_Character'Val(16#f35#))+
         Make_Set(Wide_Character'Val(16#f37#))+
         Make_Set(Wide_Character'Val(16#f39#))+
         Make_Set(Wide_Character'Val(16#f71#), Wide_Character'Val(16#f72#))+
         Make_Set(Wide_Character'Val(16#f74#))+
         Make_Set(Wide_Character'Val(16#f7a#), Wide_Character'Val(16#f7d#))+
         Make_Set(Wide_Character'Val(16#f80#))+
         Make_Set(Wide_Character'Val(16#f82#), Wide_Character'Val(16#f84#))+
         Make_Set(Wide_Character'Val(16#f86#), Wide_Character'Val(16#f87#))+
         Make_Set(Wide_Character'Val(16#fc6#))+
         Make_Set(Wide_Character'Val(16#1037#))+
         Make_Set(Wide_Character'Val(16#1039#), Wide_Character'Val(16#103a#))+
         Make_Set(Wide_Character'Val(16#108d#))+
         Make_Set(Wide_Character'Val(16#135d#), Wide_Character'Val(16#135f#))+
         Make_Set(Wide_Character'Val(16#1714#))+
         Make_Set(Wide_Character'Val(16#1734#))+
         Make_Set(Wide_Character'Val(16#17d2#))+
         Make_Set(Wide_Character'Val(16#17dd#))+
         Make_Set(Wide_Character'Val(16#18a9#))+
         Make_Set(Wide_Character'Val(16#1939#), Wide_Character'Val(16#193b#))+
         Make_Set(Wide_Character'Val(16#1a17#), Wide_Character'Val(16#1a18#))+
         Make_Set(Wide_Character'Val(16#1a60#))+
         Make_Set(Wide_Character'Val(16#1a75#), Wide_Character'Val(16#1a7c#))+
         Make_Set(Wide_Character'Val(16#1a7f#))+
         Make_Set(Wide_Character'Val(16#1ab0#), Wide_Character'Val(16#1abd#))+
         Make_Set(Wide_Character'Val(16#1b34#))+
         Make_Set(Wide_Character'Val(16#1b44#))+
         Make_Set(Wide_Character'Val(16#1b6b#), Wide_Character'Val(16#1b73#))+
         Make_Set(Wide_Character'Val(16#1baa#), Wide_Character'Val(16#1bab#))+
         Make_Set(Wide_Character'Val(16#1be6#))+
         Make_Set(Wide_Character'Val(16#1bf2#), Wide_Character'Val(16#1bf3#))+
         Make_Set(Wide_Character'Val(16#1c37#))+
         Make_Set(Wide_Character'Val(16#1cd0#), Wide_Character'Val(16#1cd2#))+
         Make_Set(Wide_Character'Val(16#1cd4#), Wide_Character'Val(16#1ce0#))+
         Make_Set(Wide_Character'Val(16#1ce2#), Wide_Character'Val(16#1ce8#))+
         Make_Set(Wide_Character'Val(16#1ced#))+
         Make_Set(Wide_Character'Val(16#1cf4#))+
         Make_Set(Wide_Character'Val(16#1cf8#), Wide_Character'Val(16#1cf9#))+
         Make_Set(Wide_Character'Val(16#1dc0#), Wide_Character'Val(16#1df5#))+
         Make_Set(Wide_Character'Val(16#1dfb#), Wide_Character'Val(16#1dff#))+
         Make_Set(Wide_Character'Val(16#20d0#), Wide_Character'Val(16#20dc#))+
         Make_Set(Wide_Character'Val(16#20e1#))+
         Make_Set(Wide_Character'Val(16#20e5#), Wide_Character'Val(16#20f0#))+
         Make_Set(Wide_Character'Val(16#2cef#), Wide_Character'Val(16#2cf1#))+
         Make_Set(Wide_Character'Val(16#2d7f#))+
         Make_Set(Wide_Character'Val(16#2de0#), Wide_Character'Val(16#2dff#))+
         Make_Set(Wide_Character'Val(16#302a#), Wide_Character'Val(16#302f#))+
         Make_Set(Wide_Character'Val(16#3099#), Wide_Character'Val(16#309a#))+
         Make_Set(Wide_Character'Val(16#a66f#))+
         Make_Set(Wide_Character'Val(16#a674#), Wide_Character'Val(16#a67d#))+
         Make_Set(Wide_Character'Val(16#a69e#), Wide_Character'Val(16#a69f#))+
         Make_Set(Wide_Character'Val(16#a6f0#), Wide_Character'Val(16#a6f1#))+
         Make_Set(Wide_Character'Val(16#a806#))+
         Make_Set(Wide_Character'Val(16#a8c4#))+
         Make_Set(Wide_Character'Val(16#a8e0#), Wide_Character'Val(16#a8f1#))+
         Make_Set(Wide_Character'Val(16#a92b#), Wide_Character'Val(16#a92d#))+
         Make_Set(Wide_Character'Val(16#a953#))+
         Make_Set(Wide_Character'Val(16#a9b3#))+
         Make_Set(Wide_Character'Val(16#a9c0#))+
         Make_Set(Wide_Character'Val(16#aab0#))+
         Make_Set(Wide_Character'Val(16#aab2#), Wide_Character'Val(16#aab4#))+
         Make_Set(Wide_Character'Val(16#aab7#), Wide_Character'Val(16#aab8#))+
         Make_Set(Wide_Character'Val(16#aabe#), Wide_Character'Val(16#aabf#))+
         Make_Set(Wide_Character'Val(16#aac1#))+
         Make_Set(Wide_Character'Val(16#aaf6#))+
         Make_Set(Wide_Character'Val(16#abed#))+
         Make_Set(Wide_Character'Val(16#fb1e#))+
         Make_Set(Wide_Character'Val(16#fe20#), Wide_Character'Val(16#fe2f#))+
         -- Blissymbolics
         Make_Set(Wide_Character'Val(16#E106#), Wide_Character'Val(16#E18F#));
   end Initialise_Combining_Characters;

   function The_Combining_Characters return combining_character_set is
   begin
      return all_combining_characters;
   end The_Combining_Characters;
    
   procedure Add_To_The_Combining_Characters(the_character:in wide_character)
   is
   begin
      all_combining_characters := all_combining_characters + 
                                  Make_Set(the_character);
   end Add_To_The_Combining_Characters;

begin
   Initialise_Combining_Characters;
end Combining_Characters;