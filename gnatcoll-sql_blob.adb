------------------------------------------------------------------------------
--                             G N A T C O L L                              --
--                                                                          --
--                     Copyright (C) 2016-2018, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public Licence  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- You should have received a copy of the GNU General Public Licence and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                   --
--                          S Q L   B L O B                          --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides the BLOB (Binary  Large  OBject)  field  --
--  access to and from a database table such that the BLOB field is  --
--  treated  in  the  table as just a blob (or an  array  of  byte,  --
--  represented as characters from 0 (NULL) to 255, that represents  --
--  a blob).                                                         --
--  This  edition  of dealing with a BLOB assumes that  the  format  --
--  stored in the data base is textual (but not as a UTF-8,  rather  --
--  as a traditional ASCII character array).                         --
--  However, because GNATCOLL is brain dead when it comes to blobs,  --
--  that is, it stores everything as a string and hopes the DB will  --
--  convert,  and worse, it uses C strings rather than Ada  strings  --
--  (so  null  terminated), we use a very ugly hack of  storing  as  --
--  Base  64.  This means that you need to load the blob as a  Base  --
--  64  (for instance, using the application provided) or  you  let  --
--  your  application load the so-called 'blob' (which is really  a  --
--  character string).                                               --
--                                                                   --
-----------------------------------------------------------------------

-- with GNATCOLL.SQL_Impl;    use GNATCOLL.SQL_Impl;
-- with GNATCOLL.SQL.Exec;    use GNATCOLL.SQL.Exec;
-- with Ada.Strings.Unbounded;
-- with Blobs.Base_64; 
package body GNATCOLL.SQL_BLOB is
   use Ada.Strings.Unbounded;
   -- use Blobs.Base_64;

   function Class_Value
            (Self : Forward_Cursor'Class; Field : Field_Index) return string is
   -- (Value (Self, Field)) with Inline_Always;
   -- translates the class into the call to GNATCOLL.SQL.Exec.Value
   -- for Self : Forward_Cursor
   begin
      return Value (Self, Field);
   end Class_Value;
   pragma Inline_Always (Class_Value);
   
   -- subtype byte is Base_64.byte;
   -- subtype Blob is Base_64.blob;
   --package Blob_Fields is new GNATCOLL.SQL_Impl.Field_Types 
   --                                 (Blob, Blob_To_SQL, SQL_Parameter_Blob);
   -- type SQL_Field_Blob is new Blob_Fields.Field with null record;

   function Blob_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : Blob;
                         Quote : boolean := false) return string is
   begin
      if Quote then
         return '"' & Blobs.Base_64.Encode(the_string => To_String(T.data)) & '"';
      else
         return Blobs.Base_64.Encode(the_string => To_String(T.data));
      end if;
   end Blob_To_SQL;

   function SQL_To_Blob (D : String; Quote : boolean := false) return Blob is
   begin
      if Quote then
         return To_Blob(Blobs.Base_64.Decode(the_base_64 => D(D'First+1 .. D'Last-1)));
      else
         return To_Blob(Blobs.Base_64.Decode(the_base_64 => D));
      end if;
   end SQL_To_Blob;
   
   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob is
      Val : constant String := Class_Value (Self, Field);
   begin
      if Val = "" then
         return Null_Blob;
      else
         return SQL_To_Blob(Val);
      end if;
   end Blob_Value;
   
   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Forward_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob is
   begin
      return To_Blob(Blobs.Base_64.Decode(To_String(GNATCOLL.SQL.Exec.Unbounded_Value(Self,Field))));
      exception
         when others =>  -- default on error is an empty blob
            return Null_Blob;
   end Blob_Value;
   
   function "+" (Value : Blob) return SQL_Parameter is
      R : SQL_Parameter;
      P : SQL_Parameter_Blob;
   begin
      P.Val := Value;
      R.Set (P);
      return R;
   end "+";
   
   --byte and blob operations
   
   procedure Clear(the_blob : in out blob) is
   begin
      the_blob := Null_Blob;
   end Clear;
   
   function Element(in_blob : blob; at_position : in positive) return byte is
   begin
      return Byte(Character'Pos(Element(in_blob.data, at_position)));
   end Element;
   
   function "&" (the_blob : blob; the_byte : byte) return blob is
      result : Blobs.blob(1..the_blob.Length + 1);
      use Blobs.Base_64;
   begin
      result(1..the_blob.Length) := Raw_Blob(the_blob);
      result(the_blob.Length + 1) := the_byte;
      return To_Blob(result);
   end "&";
   
   function "&" (the_byte : byte; the_blob : blob) return blob is
      result : Blobs.blob(1..the_blob.Length + 1);
      use Blobs.Base_64;
   begin
      result(1) := the_byte;
      result(2..the_blob.Length+1) := Raw_Blob(the_blob);
      return To_Blob(result);
   end "&";
   
   function Length(of_the_blob : in blob) return natural is
   begin
      return of_the_blob.Length;
   end Length;
   
   function Raw_Blob(from_the_blob : blob) return Blobs.blob is
      result : Blobs.blob(1..from_the_blob.Length);
      use Blobs.Base_64;
   begin
      for char_pos in 1 .. from_the_blob.Length loop
         result(char_pos):=Byte(Character'Pos(Element(from_the_blob.data,char_pos)));
      end loop;
      return result;
   end Raw_Blob;
   
   function To_Blob(from_raw : Blobs.blob) return Blob is
      result : Blob;
      use Blobs.Base_64;
   begin
      result.Length := from_raw'Length;
      for char_pos in 1 .. from_raw'Length loop
         result.data:=result.data & Character'Val(Integer(from_raw(char_pos)));
      end loop;
      return result;
   end To_Blob;

end GNATCOLL.SQL_BLOB;
