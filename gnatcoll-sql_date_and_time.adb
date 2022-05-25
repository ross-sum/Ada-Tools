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
--                 S Q L   D A T E   A N D   T I M E                 --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides date and time field access to and from  a  -- 
--  database  table such that the date is treated in the  table  as  --
--  just  a  date (or a string that represents a date) and  just  a  --
--  time (or a string that represents just a time).                  --
--  This  edition  of dealing with date and time assumes  that  the  --
--  format stored in the data base is textual and that it is in the  --
--  same  time  zone  as  is to be  displayed (or  that  time  zone  --
--  manipulation  is done separately to dealing with this date  and  --
--  time).                                                           --
--                                                                   --
-----------------------------------------------------------------------

-- with GNATCOLL.SQL_Impl;    use GNATCOLL.SQL_Impl;
-- with GNATCOLL.SQL.Exec;    use GNATCOLL.SQL.Exec;
-- with Calendar_Extensions;  use Calendar_Extensions;
with String_Conversions, Ada.Strings.Unbounded;

package body GNATCOLL.SQL_Date_and_Time is

   function Class_Value
            (Self : Forward_Cursor'Class; Field : Field_Index) return string is
   -- (Value (Self, Field)) with Inline_Always;
   -- translates the class into the call to GNATCOLL.SQL.Exec.Value
   -- for Self : Forward_Cursor
   begin
      return Value (Self, Field);
   end Class_Value;
   pragma Inline_Always (Class_Value);
   
   ----------
   -- Date --
   ----------
   -- package tDate_Fields is new GNATCOLL.SQL_Impl.Field_Types 
   --              (Time, tDate_To_SQL, SQL_Parameter_tDate);
   -- type SQL_Field_tDate is new tDate_Fields.Field with null record;

   function tDate_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : tDate; 
                          Quote : boolean := false) return string is
   begin
      return String_Conversions.To_String(To_String(from_time => Time(T), 
                                                 with_format => "yyyy-mm-dd"));
   end tDate_To_SQL;

   function SQL_To_tDate (D : String; Quote : boolean := false) return tDate is
   begin
      return tDate(To_Time(from_string => String_Conversions.To_Wide_String(D),
                           with_format => "yyyy-mm-dd"));
   end SQL_To_tDate;
   
   function tDate_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                         Field : GNATCOLL.SQL.Exec.Field_Index) return tDate is
      Val : constant String := Class_Value (Self, Field);
   begin
      if Val = "" then
         return SQL_To_tDate("01/01/0001");
      else
         return SQL_To_tDate(Val);
      end if;
   end tDate_Value;
   
   function tDate_Value (Self  : GNATCOLL.SQL.Exec.Forward_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return tDate is
   begin
      return SQL_To_tDate(Ada.Strings.Unbounded.To_String(
                              GNATCOLL.SQL.Exec.Unbounded_Value(Self,Field)));
      exception
         when others =>  -- default on error is an 'empty' date
            return SQL_To_tDate("01/01/0001");
   end tDate_Value;
   
   function "+" (Value : tDate) return SQL_Parameter is
      R : SQL_Parameter;
      P : SQL_Parameter_tDate;
   begin
      P.Val := Value;
      R.Set (P);
      return R;
   end "+";

   ----------
   -- Time --
   ----------
   -- package tTime_Fields is new GNATCOLL.SQL_Impl.Field_Types 
   --              (Time, tTime_To_SQL, SQL_Parameter_tTime);
   -- type SQL_Field_tTime is new tTime_Fields.Field with null record;

   function tTime_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : tTime; 
                          Quote : boolean := false) return string is
   begin
      return String_Conversions.To_String(To_String(from_time  => Time(T), 
                                                    with_format=> "hh:nn:ss"));
   end tTime_To_SQL;

   function SQL_To_tTime (T : String; Quote : boolean := false) return tTime is
   begin
      return tTime(To_Time(from_string => String_Conversions.To_Wide_String(T),
                           with_format => "hh:nn:ss"));
   end SQL_To_tTime;
   
   function tTime_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                         Field : GNATCOLL.SQL.Exec.Field_Index) return tTime is
      Val : constant String := Class_Value (Self, Field);
   begin
      if Val = "" then
         return SQL_To_tTime("00:00:00");
      else
         return SQL_To_tTime(Val);
      end if;
   end tTime_Value;
   
   function "+" (Value : tTime) return SQL_Parameter is
      R : SQL_Parameter;
      P : SQL_Parameter_tTime;
   begin
      P.Val := Value;
      R.Set (P);
      return R;
   end "+";

end GNATCOLL.SQL_Date_and_Time;
