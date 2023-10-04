 -----------------------------------------------------------------------
--                                                                   --
--                           B A S E _ 6 4                           --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  pacakge  converts  to  and from  Base  64  encoding.   It  --
--  typically assumes the input is an array of byte (a blob).        --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  Base_64 is free software; you can redistribute it and/or modify  --
--  it  under terms of the GNU General Public Licence as  published  --
--  by the Free Software Foundation; either version 2, or (at  your  --
--  option) any later version.  Base_64 is distributed in hope that  --
--  it  will be useful, but WITHOUT ANY WARRANTY; without even  the  --
--  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  --
--  PURPOSE.  See the GNU General Public Licence for more  details.  --
--  You  should  have  received a copy of the  GNU  General  Public  --
--  Licence distributed with  Urine_Records.  If  not, write to the  --
--  Free  Software  Foundation, 51 Franklin  Street,  Fifth  Floor,  --
--  Boston, MA 02110-1301, USA.                                      --
--                                                                   --
-----------------------------------------------------------------------
with dStrings;   use dStrings;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
package body Blobs.Base_64 is
   
   -- type Byte is mod 256;
   -- type blob is array(positive range <>) of byte;
   --    pragma Pack(blob);
   pad : constant character := '=';
   null_byte : constant byte := 16#00#;
   base_64_map : constant array (0..63) of character :=
      ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
       'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
       'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
       'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
       '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/');
   
   function Encode(the_blob : in blob) return string is
      group     : blob(1..3);
      four_bits : blob(1..4);
      input_pos : positive := 1;
      result    : text;
   begin
      while input_pos <= the_blob'Length loop
         -- Grab 3 bytes from the blob
         for byte_pos in 1 .. 3 loop
            if input_pos + byte_pos - 1 <= the_blob'Length then
               group(byte_pos) := the_blob(input_pos + byte_pos - 1);
            else
               group(byte_pos) := null_byte;
            end if;
         end loop;
         -- Split the 3 bytes into 24 bits, in 4 groups of 6 bits
         four_bits(1) := group(1) / 2#0000_0100#;
         four_bits(2) := group(1) rem 2#0000_0100# * 2#0001_0000# + 
                         group(2) / 2#0001_0000#;
         four_bits(3) := group(2) rem 2#0001_0000# * 2#0000_0100# +
                         group(3) / 2#0100_0000#;
         four_bits(4) := group(3) rem 2#0100_0000#;
         -- Convert to Base 64
         for bit_pos in 1 .. 4 loop
            append(tail=>base_64_map(Integer(four_bits(bit_pos))), to=>result);
         end loop;
         -- check for padding and override accordingly
         if input_pos + 1 > the_blob'Length then
            Delete(result, Length(result)-1, 2);
            Append(pad, result);
            Append(pad, result);
         elsif input_pos + 2 > the_blob'Length then
            Delete(result, Length(result), 1);
            Append(pad, result);
         end if;
         input_pos := input_pos + 3;
      end loop;
      return Value(of_string => result);
   end Encode;
   
   function Encode(the_string : in string) return string is
      the_blob : blob(1..the_string'Length);
   begin
      -- convert the string into a blob
      for char_pos in 1 .. the_string'Length loop
         the_blob(char_pos) := byte(Character'Pos(the_string(char_pos)));
      end loop;
      return Encode(the_blob);
   end Encode;
   
   function Decode(the_base_64 : in string) return blob is
      function Lookup_Number(for_the_char : in character) return byte is
      begin
         for char_no in base_64_map'First .. base_64_map'Last loop
            if base_64_map(char_no) = for_the_char then
               return byte(char_no);
            end if;
         end loop;
         return 0;  -- default if found nothing (never gets here)
      end Lookup_Number;
      res_length: positive := the_base_64'Length/4*3;
      result    : blob(1 .. res_length);
      group     : blob(1..3);
      four_bits : blob(1..4);
      the_bit   : Character;
   begin
      for input_pos in 1 .. the_base_64'Length / 4 loop
         -- Get the first 4 sets of 6 bits
         for bit_no in 1 .. 4 loop
            -- First, extract the characer
            the_bit := the_base_64((input_pos - 1) * 4 + bit_no);
            -- then convert into the 6 bit number
            if the_bit  /= pad then
               four_bits(bit_no) := Lookup_Number(the_bit);
            else  -- padding - convert to pad (16#00#)
               four_bits(bit_no) := 2#0000_0000#;
               res_length := res_length - 1;  -- shorten the blob
            end if;
         end loop;
         -- Convert back into the 3 blobs
         group(1) := four_bits(1) * 2#100# + four_bits(2) / 2#01_0000#;
         group(2) := four_bits(2) rem 2#01_0000# * 2#01_0000# + four_bits(3) / 2#00_0100#;
         group(3) := four_bits(3) rem 2#00_0100# * 2#0100_0000# + four_bits(4);
         -- then load into the result
         for byte_pos in 1 .. 3 loop
            result((input_pos -1)*3 + byte_pos) := group(byte_pos);
         end loop;
      end loop;
      return result(1..res_length);
   end Decode;
   
   function Decode(the_base_64_text : in string) return string is
      blob_result : blob := Decode(the_base_64_text);
      str_result  : String(1..blob_result'Length);
   begin
      for char_num in 1 .. blob_result'Length loop
         str_result(char_num) := Character'Val(blob_result(char_num));
      end loop;
      return str_result;
   end Decode;

   function Cast_String_As_Blob(the_string : in string) return blob is
      result : blob(1..the_string'Length);
   begin
      for i in the_string'First .. the_string'Last loop
         result(i-the_string'First+1) :=
	                        Byte'Val(Character'Pos(the_string(i)));
      end loop;
      return result;
   end Cast_String_As_Blob;
   
   function Cast_Blob_As_String(the_blob   : in blob) return string is
      result : string(the_blob'First..the_blob'Last);
   begin
      for i in the_blob'First .. the_blob'Last loop
         result(i) := Character'Val(Byte'Pos(the_blob(i)));
      end loop;
      return result;
   end Cast_Blob_As_String;

end Blobs.Base_64;
