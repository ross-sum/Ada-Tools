
package String_Conversions is

   function To_Wide_String(from : string) return wide_string;
   		-- Convert the input wide string to a regular string.

   function To_String(from_wide : wide_string) return string;
   		-- Convert the input regular string to a wide string,
      -- discarding any high order bits.

end String_Conversions;