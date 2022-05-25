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
--                     S p e c i f i c a t i o n                     --
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

with GNATCOLL.SQL_Impl;    use GNATCOLL.SQL_Impl;
with GNATCOLL.SQL.Exec;    use GNATCOLL.SQL.Exec;
with Calendar_Extensions;  use Calendar_Extensions;

package GNATCOLL.SQL_Date_and_Time is

   ----------
   -- Date --
   ----------
   type tDate is new Calendar_Extensions.Time;

   function tDate_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : tDate;
                          Quote : boolean := false) return string;
   function SQL_To_tDate (D : String; Quote : boolean := false) return tDate;
   
   package tDate_Parameters is new Scalar_Parameters
      (tDate, "date", tDate_To_SQL);
   subtype SQL_Parameter_tDate is tDate_Parameters.SQL_Parameter;

   package tDate_Fields is new GNATCOLL.SQL_Impl.Field_Types 
                                    (tDate, tDate_To_SQL, SQL_Parameter_tDate);
                
   type SQL_Field_tDate is new tDate_Fields.Field with null record;
   Null_Field_tDate : constant SQL_Field_tDate :=
                                    (tDate_Fields.Null_Field with null record);
   function tDate_Param (Index : Positive) return tDate_Fields.Field'Class
      renames tDate_Fields.Param;

   function "-" is new tDate_Fields.Operator ("-");
   function "+" is new tDate_Fields.Operator ("+");
   function "+" (Value : tDate) return SQL_Parameter;

   function tDate_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                         Field : GNATCOLL.SQL.Exec.Field_Index) return tDate;
   function tDate_Value (Self  : GNATCOLL.SQL.Exec.Forward_Cursor; 
                         Field : GNATCOLL.SQL.Exec.Field_Index) return tDate;
   
   ----------
   -- Time --
   ----------

   type tTime is new Calendar_Extensions.Time;

   function tTime_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : tTime;
                          Quote : boolean := false) return string;
   function SQL_To_tTime (T : String; Quote : boolean := false) return tTime;
   
   package tTime_Parameters is new Scalar_Parameters
      (tTime, "time", tTime_To_SQL);
   subtype SQL_Parameter_tTime is tTime_Parameters.SQL_Parameter;

   package tTime_Fields is new GNATCOLL.SQL_Impl.Field_Types 
                                    (tTime, tTime_To_SQL, SQL_Parameter_tTime);
 
   type SQL_Field_tTime is new tTime_Fields.Field with null record;
   Null_Field_tTime : constant SQL_Field_tTime :=
                                    (tTime_Fields.Null_Field with null record);
   function tTime_Param (Index : Positive) return tTime_Fields.Field'Class
      renames tTime_Fields.Param;

   function "-" is new tTime_Fields.Operator ("-");
   function "+" is new tTime_Fields.Operator ("+");
   function "+" (Value : tTime) return SQL_Parameter;
      
   function tTime_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                         Field : GNATCOLL.SQL.Exec.Field_Index) return tTime;

end GNATCOLL.SQL_Date_and_Time;
