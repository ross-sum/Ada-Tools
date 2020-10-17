
with Ada.Characters.Latin_1;
with Ada.Characters.Handling;

package body String_Functions is

   CR : constant wide_character := 
   Ada.Characters.Handling.To_Wide_Character(Ada.Characters.Latin_1.CR);
   LF : constant wide_character := 
   Ada.Characters.Handling.To_Wide_Character(Ada.Characters.Latin_1.LF);

   function Pos (of_string, within_string : in wide_string;
   starting_at : positive := 1) return integer is
   -- Find the position of_string within the string within_string.
   -- If the string cannot be found, return -1.
      matches : boolean;
   begin
      if of_string'Length > within_string'Length - starting_at + 1 or 
      of_string'Length = 0 then
         return 0;  -- cannot exist within the string
      else  -- string lengths allow for possible existence
         for char_num in starting_at ..
         within_string'Length - of_string'Length +1 loop
            if within_string(char_num) = of_string(of_string'First)
            then -- could be it
               matches := true;  -- initial assumption
               for sub_char in 2 .. of_string'Length loop
                  if within_string(char_num + sub_char - 1) /=
                  of_string(sub_char) then  -- no match
                     matches := false;
                     exit;  -- quit this inner loop
                  end if;  -- if non matching character found
               end loop;
               if matches then -- found it
                  return char_num;
               end if; -- if matches
            end if;  -- if match found for first character
         end loop;  -- for each possible character in within_string
         return 0;  -- cannot exist within the string if we got here
      end if;  -- else string lengths allow for possible existence
   end Pos;

-- Case conversion
   type case_type is (upper_case, lower_case);

   procedure Convert_Case(on_object : in out wide_string; 
   with_case : in case_type) is
      from_char,
      last_char,
      to_char    : wide_character;
   begin
      if with_case = upper_case then
         from_char := 'a';
         last_char := 'z';
         to_char   := 'A';
      else
         from_char := 'A';
         last_char := 'Z';
         to_char   := 'a';
      end if;
      for character_number in 1 .. on_object'Length loop
         if on_object(character_number) in
         from_char .. last_char then
            on_object(character_number) :=
               wide_character'Val(wide_character'Pos(
               on_object(character_number)) - 
               wide_character'Pos(from_char)+
               wide_character'Pos(to_char));
         end if;
      end loop;
   end Convert_Case;

   procedure Upper_Case(of_object : in out wide_string) is
   -- Use this when working with a text object
   begin
      if of_object'Length > 0 then  -- something to convert
         Convert_Case(of_object, with_case => upper_case);
      end if;
   end Upper_Case;

   function Upper_Case(of_object : in wide_string) 
   return wide_string is
   -- Use in equations where original text needs preserving
      temp_string : wide_string(1..of_object'Length) := of_object;
   begin
      Upper_Case(temp_string);
      return temp_string;
   end Upper_Case;

   procedure Lower_Case(of_object : in out wide_string) is
   -- Use this when working with a text object
   begin
      if of_object'Length > 0 then  -- something to convert
         Convert_Case(of_object, with_case => lower_case);
      end if;
   end Lower_Case;

   function Lower_Case(of_object : in wide_string) 
   return wide_string is
   -- Use in equations where original text needs preserving
      temp_string : wide_string(1..of_object'Length) := of_object;
   begin
      Lower_Case(temp_string);
      return temp_string;
   end Lower_Case;

   function Left_Trim (the_string : wide_string; 
   of_character : wide_character := ' ') return wide_string is
   -- Trim characters (usually spaces) from the left hand side
      character_number : natural range 0 .. the_string'Length + 1 := 1;
      first_character  : wide_character := ' ';
      working_string   : wide_string(1..the_string'Length) := the_string;
   begin
      if working_string'Length > 0 and of_character = LF then
         first_character := working_string(1);
         if wide_character'Pos(first_character) = 
         wide_character'Pos(LF) then
            return Left_Trim(working_string(2 .. working_string'Length), 
               of_character);
         else
            return working_string;
         end if;
      elsif working_string'Length > 0 and of_character = CR then
         if working_string'Length > 1 then
            first_character := working_string(2);
         end if;
         if working_string(1) = CR then
            if first_character = LF then  -- trim the line feed with it
               return Left_Trim(working_string(3 .. working_string'Length), 
                  of_character);
            else  -- ^M on its own - remove it
               return Left_Trim(working_string(2 .. working_string'Length), 
                  of_character);
            end if;  -- else just ^M, not CR-LF sequence
         else
            return working_string;
         end if;
      elsif working_string'Length > 0 then
         while character_number < working_string'Length and then
         the_string(character_number) = of_character loop
            character_number := character_number + 1;
         end loop;
         return working_string(character_number .. working_string'Length);
      else  -- empty string
         return working_string;
      end if;
   end Left_Trim;

   function Right_Trim (the_string : wide_string; 
   of_character : wide_character := ' ') return wide_string is
   -- Trim characters (usually spaces) from the right hand side
      character_number : natural range 0 .. the_string'Length := 
      the_string'Length;
   begin
      if the_string'Length > 0 then
         while character_number > 0 and then
         the_string(character_number) = of_character loop
            character_number := character_number - 1;
         end loop;
         return the_string(the_string'First .. character_number);
      else  -- empty string
         return the_string;
      end if;
   end Right_Trim;

   function Trim (the_string : wide_string; 
   of_character : wide_character := ' ') return wide_string is
   -- Trim characters (usually spaces) from both sides of the string.
   begin
      return Left_Trim(Right_Trim(the_string, of_character),
         of_character);
   end Trim;

   function Assign(the_string : in wide_string;
   of_length  : in natural;
   with_padding : in wide_character := ' ') return wide_string is
   -- Assign the_string to the result.  Pad out the result with 
   -- with_padding.
      dummy_string : wide_string(1..of_length);
      source_length : natural;
   begin
      Assign(the_string, of_length => source_length,
         to_string => dummy_string, with_padding => with_padding);
      return dummy_string;
   end Assign;

   procedure Assign(the_string : in wide_string;
   of_length  : out natural;
   to_string  : out wide_string;
   with_padding : in wide_character := ' ') is
   -- Assign the_string to to_string.  Set of_length to the_string's
   -- length and pad out to_string with with_padding.
   begin
      for char_num in 1 .. the_string'Length loop
         to_string(char_num) := the_string(char_num);
      end loop;
      for char_num in the_string'Length + 1 .. to_string'Length loop
         to_string(char_num) := with_padding;
      end loop;
      of_length := the_string'Length;
   end Assign;

   function There_Is(equivalence_between : in wide_string;
   and_the_string : in wide_string;
   of_length : in natural) return boolean is
   -- returns true if the string equivalence_between contains the
   -- same information as and_the_string(1..of_length).
   begin
      return equivalence_between = 
                           and_the_string(and_the_string'First .. of_length);
   end There_Is;

begin
   null;
end String_Functions;