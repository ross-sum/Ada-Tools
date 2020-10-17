
package body String_Conversions is

   function To_Wide_String(from : string) 
   return wide_string is
      -- convert the input wide string to a regular string
      temp_string    : wide_string(1 .. from'Length);
      temps_number   : positive := 1;
      string_element : wide_character;
   begin
      for char_number in from'range loop
         string_element := 
            wide_character'Val(character'Pos(from(char_number)));
         temp_string(temps_number) := string_element;
         temps_number := temps_number + 1;
      end loop;
      return temp_string;
   end To_Wide_String;

   function To_String(from_wide : wide_string) return string is
      -- convert the input regular string to a wide string,
      -- discarding any high order bits.
      temp_string    : string(1 .. from_wide'Length);
      string_element : character;
   begin
      for char_number in temp_string'range loop
         string_element := 
            character'Val(wide_character'Pos(from_wide(char_number)) 
            mod 16#100#);
         temp_string(char_number) := string_element;
      end loop;
      return temp_string;
   end To_String;

begin
   null;
end String_Conversions;