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
--                     S p e c i f i c a t i o n                     --
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
--  as a traditional ASCII character array, values 0..255).          --
   --                                                                   --
--  Currently  the package has hit a big snag: 00h is treated as  a  --
--  string  terminator by GNATCOLL.  So haven't figured out how  to  --
--  read in a full blob (it stops at the first 00h).                 --
--  That is, because GNATCOLL is brain dead when it comes to blobs,  --
--  that is, it stores everything as a string and hopes the DB will  --
--  convert,  and worse, it uses C strings rather than Ada  strings  --
--  (so  null  terminated), we use a very ugly hack of  storing  as  --
--  Base  64.  This means that you need to load the blob as a  Base  --
--  64  (for instance, using the application provided) or  you  let  --
--  your  application load the so-called 'blob' (which is really  a  --
--  character string).                                               --
--                                                                   --
-----------------------------------------------------------------------

with GNATCOLL.SQL_Impl;    use GNATCOLL.SQL_Impl;
with GNATCOLL.SQL.Exec;    use GNATCOLL.SQL.Exec;
with Ada.Strings.Unbounded;
with Blobs.Base_64;
package GNATCOLL.SQL_BLOB is

   subtype byte is Blobs.byte;
   -- type Blob is private;
   type blob is record
         data : Ada.Strings.Unbounded.Unbounded_String;
         length : natural;
      end record;
   Null_Blob : constant Blob;

   function Blob_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : Blob;
                          Quote : boolean := false) return string;
   function SQL_To_Blob (D : String; Quote : boolean := false) return Blob;
   
   package Blob_Parameters is new Scalar_Parameters
      (Blob, "blob", Blob_To_SQL);
   subtype SQL_Parameter_Blob is Blob_Parameters.SQL_Parameter;

   package Blob_Fields is new GNATCOLL.SQL_Impl.Field_Types 
                                    (Blob, Blob_To_SQL, SQL_Parameter_Blob);
                
   type SQL_Field_Blob is new Blob_Fields.Field with null record;
   Null_Field_Blob : constant SQL_Field_Blob :=
                                    (Blob_Fields.Null_Field with null record);
   function Blob_Param (Index : Positive) return Blob_Fields.Field'Class
      renames Blob_Fields.Param;

   function "-" is new Blob_Fields.Operator ("-");
   function "+" is new Blob_Fields.Operator ("+");
   function "+" (Value : Blob) return SQL_Parameter;

   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob;
   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Forward_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob;
   
   --byte and blob operations
   procedure Clear(the_blob : in out blob);
   function Element(in_blob : blob; at_position : in positive) return byte;
   function "&" (the_blob : blob; the_byte : byte) return blob;
   function "&" (the_byte : byte; the_blob : blob) return blob;
   function Length(of_the_blob : in blob) return natural;
   function Raw_Blob(from_the_blob : blob) return Blobs.blob;
   function To_Blob(from_raw : Blobs.blob) return Blob;
   
   private
   Null_blob : constant Blob := (Ada.Strings.Unbounded.Null_Unbounded_String, 0);
   
end GNATCOLL.SQL_BLOB;
