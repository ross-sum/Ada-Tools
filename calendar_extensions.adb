-----------------------------------------------------------------------
--                                                                   --
--                 C A L E N D A R _ E X T E N S I O N S             --
--                                                                   --
--                                B o d y                            --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001,2020  Hyper Quantum Pty Ltd.             --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package enhances Ada.Calendar to provide UTC time and  to  --
--  provide string conversion functions for time.                    --
--                                                                   --
--  Version History:                                                 --
--  $Log: calendar_extensions.adb,v $
--  Revision 1.1  2001/04/29 00:48:39  ross
--  Initial revision
--                                                            --
--                                                                   --
--  This  library is free software; you can redistribute it  and/or  --
--  modify it under terms of the GNU Lesser General  Public Licence  --
--  as  published by the Free Software Foundation;  either  version  --
--  2.1 of the licence, or (at your option) any later version.       --
--  This library is distributed in hope that it will be useful, but  --
--  WITHOUT  ANY  WARRANTY; without even the  implied  warranty  of  --
--  MERCHANTABILITY  or FITNESS FOR A PARTICULAR PURPOSE.  See  the  --
--  GNU Lesser General Public Licence for more details.              --
--  You  should  have  received a copy of the  GNU  Lesser  General  --
--  Public  Licence along with this library.  If not, write to  the  --
--  Free Software Foundation, 59 Temple Place -  Suite 330, Boston,  -- 
--  MA 02111-1307, USA.                                              --
--                                                                   --
-----------------------------------------------------------------------
with String_Functions;         use String_Functions;
with Ada.Integer_Wide_Text_IO; use Ada.Integer_Wide_Text_IO;
with Ada.Real_Time;
-- with Error_Log, String_Conversions; use String_Conversions;

--@ with Ada.Wide_Text_IO;
package body Calendar_Extensions is
   use Ada.Calendar;

   --    subtype Time          is Ada.Calendar.Time;
   --    subtype Year_Number   is Ada.Calendar.Year_Number;
   --    subtype Month_Number  is Ada.Calendar.Month_Number;
   --    subtype Day_Number    is Ada.Calendar.Day_Number;
   --    subtype Day_Duration  is Ada.Calendar.Day_Duration;
   --    type day_of_week is (Mon, Tue, Wed, Thur, Fri, Sat, Sun);
   --    subtype weekday is day range Mon .. Fri;

   function UTC_Clock return Time is
      use Ada.Real_Time;
      year      : year_number;
      month     : month_number;
      day       : day_number;
      secs      : Day_Duration;
      sec_count : seconds_count;
      elapsed   : Ada.Real_Time.time_span;
   begin
      Split(Clock, year, month, day, secs);
      Ada.Real_Time.Split(Ada.Real_Time.Clock, sec_count,elapsed);
      secs := Day_Duration(sec_count rem 
         seconds_count(Day_Duration'Last)) + To_Duration(elapsed);
      return Time_Of(year, month, day, secs);
   end UTC_Clock;

   function Trunc(the_number : in Day_Duration) 
   return long_integer is
   begin
      if Day_Duration(long_integer(the_number)) > the_number then
         return long_integer(the_number) - 1;
      else
         return long_integer(the_number);
      end if;
   end Trunc;

   function To_String(from_time : in time;
   with_format : wide_string := "dd/mm/yyyy hh:nn:ss") 
   return wide_string is
   
      function Number_As_Text(from : in integer;
      with_size : in integer) return wide_string is
         zero   : constant wide_character := '0';
         nine   : constant wide_character := '9';
         minus  : constant wide_character := '-';
         radix  : constant integer := 10;
         the_number   : wide_string(1..with_size) := (others => '0');
         strip_number : integer;
         negative     : boolean := (from < 0);
         number_pos   : natural := with_size;
      begin
      -- convert the number to a string
         if from /= 0 then
            strip_number := from;
            if strip_number < 0 then
               strip_number := abs(strip_number);
            end if;
         -- place numbers on the right hand side of the decimal 
         -- point into the temporary string, number_string 
         -- (NB: actually no decimal point)
            while strip_number > 0 and number_pos > 0 loop
               the_number(number_pos) :=
                  wide_character'Val((strip_number - 
                  (strip_number / radix) * radix) +
                  wide_character'Pos(zero));
               strip_number := strip_number / radix;
               number_pos := number_pos - 1;
            end loop;
            if negative and then number_pos > 0 then
               the_number(number_pos) := minus;
            end if;
         end if;
         return the_number;
      end Number_As_Text;
   
      procedure Insert(the_number : in integer;
      into_string : in out wide_string;
      starting_at, for_length : in natural) is
      begin
         if starting_at > 0 then  -- some place to insert to
            into_string(starting_at..starting_at+for_length-1) :=
               Number_As_Text(integer(the_number), for_length);
         end if;
      end Insert;
   
      hours   : constant Duration := 3600.0;
      minutes : constant Duration := 60.0;
      seconds : constant Duration := 1.0;
      the_year    : Year_Number;
      the_month   : Month_Number;
      the_day     : Day_Number;
      daytime     : Day_Duration;
      the_hours   : long_integer range 0..24 := 0;
      the_minutes : long_integer range 0..60 := 0;
      the_seconds : long_integer range 0..60 := 0;
      thous       : Duration;
      hundreds    : long_integer range 0..1000 := 0;
      the_result  : wide_string := with_format;
      year_pos    : natural := Pos("yyyy", with_format);
      month_pos   : natural := Pos("mm",   with_format);
      day_pos     : natural := Pos("dd",   with_format);
      hour_pos    : natural := Pos("hh",   with_format);
      mins_pos    : natural := Pos("nn",   with_format);
      secs_pos    : natural := Pos("ss",   with_format);
      hund_sec_pos: natural := Pos("uuu",  with_format);
   begin
      Split(from_time, the_year, the_month, the_day, daytime);
      the_hours   := Trunc(daytime / hours);
      the_minutes := Trunc((daytime - Duration(the_hours) *
         hours) / minutes);
      the_seconds := Trunc(daytime - (Duration(the_hours) *
         hours + Duration(the_minutes) * minutes));
      thous       := Duration(daytime) - 
         (Duration(the_hours) * hours +
         Duration(the_minutes) * minutes + Duration(the_seconds));
      if thous > Duration'(0.0) and thous < seconds then
         hundreds := long_integer(thous * 1000);
      end if;
      Insert(the_number => the_year, into_string => the_result,
         starting_at => year_pos, for_length => 4);
      Insert(the_number => the_month, into_string => the_result,
         starting_at => month_pos, for_length => 2);
      Insert(the_number => the_day, into_string => the_result,
         starting_at => day_pos, for_length => 2);
      Insert(the_number => integer(the_hours),
         into_string => the_result,
         starting_at => hour_pos, for_length => 2);
      Insert(the_number => integer(the_minutes), 
         into_string => the_result,
         starting_at => mins_pos, for_length => 2);
      Insert(the_number => integer(the_seconds), 
         into_string => the_result,
         starting_at => secs_pos, for_length => 2);
      Insert(the_number => integer(hundreds), 
         into_string => the_result,
         starting_at => hund_sec_pos, for_length => 3);
      return the_result;
   end To_String;

   function To_Time(from_string : in wide_string;
   with_format : wide_string := "dd/mm/yyyy hh:nn:ss") 
   return time is
      hours   : constant Duration := 3600.0;
      minutes : constant Duration := 60.0;
      seconds : constant Duration := 1.0;
      the_year    : Year_Number;
      the_month   : Month_Number;
      the_day     : Day_Number;
      daytime     : Day_Duration;
      the_secs    : integer range 0..60 := 0;
      the_hours   : integer range 0..24 := 0;
      the_mins    : integer range 0..60 := 0;
      time_start  : positive;
      last        : positive;
      day_pos         : natural := Pos("dd", with_format);
      hour_pos        : natural := Pos("hh", with_format);
      minute_pos      : natural := Pos("nn", with_format);
      second_pos      : natural := Pos("ss", with_format);
      year_pos        : natural := Pos("yyyy", with_format);
      month_pos       : natural := Pos("mm", with_format);
      one_digit_day   : boolean := false;
      one_digit_hour  : boolean := false;
      width_reduction : natural := 0;
   begin
      -- work out if we have a one or 2 digit day of month
      if day_pos > 0 and then
         not (from_string(day_pos) in '0'..'9' and
              from_string(day_pos + 1) in '0'..'9')
      then
         width_reduction := 1;
         one_digit_day   := true;
         if hour_pos > day_pos then
            hour_pos     := hour_pos - 1;
         end if;
      end if;
      -- similarly work out if we have a 1 or 2 digit hour
      if hour_pos > 0 and then
      not (from_string(hour_pos) in '0'..'9' and
           from_string(hour_pos + 1) in '0'..'9')
      then
         one_digit_hour := true;
         if year_pos > hour_pos and month_pos > hour_pos and day_pos > hour_pos
         then
            width_reduction := width_reduction - 1;
         end if;
      end if;
      if year_pos > 0 then
         time_start := year_pos;
      elsif month_pos > 0 then  -- no year specified
         time_start := month_pos;
      elsif day_pos > 0 then  -- no month or year specified
         time_start := day_pos;
      else  -- no date specified, just time
         time_start := 1;
      end if;
      if day_pos < time_start and one_digit_day
      then
         time_start := time_start - width_reduction;
      end if;
      if year_pos > 0 then  -- Get the year
         Get(from_string(time_start .. time_start+3), the_year, last);
      else
         the_year := Year_Number'First;
      end if;
      if month_pos > 0 then
         if day_pos < month_pos and one_digit_day then
            time_start := month_pos - width_reduction;
         else
            time_start := month_pos;
         end if;
         Get(from_string(time_start .. time_start+1),the_month, last);
      else
         the_month := Month_Number'First;
      end if;
      if day_pos > 0 then
         if one_digit_day then
            Get(from_string(day_pos.. day_pos),  the_day, last);
         else
            Get(from_string(day_pos.. day_pos+1),the_day, last);
         end if;
      else
         the_day := Day_Number'First;
      end if;
      if hour_pos > 0 then
         if day_pos < hour_pos and one_digit_day then
            time_start := hour_pos - 1;
         else
            time_start := hour_pos;
         end if;
         if one_digit_hour then
            Get(from_string(time_start..time_start),the_hours,
               last);
         else
            Get(from_string(time_start..time_start+1),the_hours,
               last);
         end if;
      end if;
      if minute_pos > 0 then
         if day_pos < minute_pos and one_digit_day then
            time_start := minute_pos - 1;
         else
            time_start := minute_pos;
         end if;
         if hour_pos < time_start and one_digit_hour then
            time_start := time_start - 1;
         end if;
         Get(from_string(time_start..time_start+1),the_mins,last);
      end if;
      if second_pos > 0 then
         if day_pos < second_pos and one_digit_day then
            time_start := second_pos - 1;
         else
            time_start := second_pos;
         end if;
         if hour_pos < time_start and one_digit_hour then
            time_start := time_start - 1;
         end if;
         Get(from_string(time_start..time_start+1),the_secs,last);
      end if;
      daytime := Day_Duration(the_secs) +
         Day_Duration(the_mins) * minutes +
         Day_Duration(the_hours) * hours;
      return Time_Of(the_year, the_month, the_day, daytime);
   end To_Time;

   
   function Day_of_The_Week(for_date : time) return day_of_week is
      -- Use Zeller's rule to work out which day of the week it is
      -- for the specified time.  Formula:
      --   f = dd + [(13*mm-1)/5] + yy + [yy/4] + [cc/4] - 2*cc
      -- where
      --   dd = day number of month
      --   mm = month number, but March = month 1, but Jan and Feb
      --        are counted as months of previous year
      --   yy = last 2 digits of year
      --   cc = century number (i.e. yyyy div 100)
      -- and the result is f mod 7 where 0 = Sunday
      dd   : Day_Number   := Day(for_date);
      mm   : Month_Number := Month(for_date);
      m    : natural;
      yyyy : Year_Number  := Year(for_date);
      yy   : natural;
      cc   : natural;
      f    : integer;
      dn   : natural;  -- calculated day number where 0 = Sunday
   begin
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"Day_of_The_Week: start - "&To_String(from_time=>for_date));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"dd="&To_Wide_String(Day_Number'Image(dd)));
      -- Fix up month and year if necessary
      if mm < 3 then
         m   := 10 + Integer(mm);
         yyyy := yyyy - 1;
      else
         m := mm - 2;
      end if;
      -- split up the year and the century
      yy := Integer(yyyy) rem 100;
      cc := (Integer(yyyy) - yy) / 100;
      --  Apply formula as integer mathematics
      f := natural(dd) + ((13*m-1)/5) + yy + (yy/4) + (cc/4) - 2*cc;
      if f < 0 then
         dn := 7-((-f) rem 7);
      else
         dn := f rem 7;
      end if;
      -- adjust fo 0 = Sunday
      if dn = 0 then
         dn := 7;
      end if;
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"m="&To_Wide_String(Integer'Image(m))&" yyyy="&To_Wide_String(Integer'Image(Integer(yyyy))));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>" yy="&To_Wide_String(Integer'Image(yy)));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>" cc="&To_Wide_String(Integer'Image(cc)));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"f="&To_Wide_String(Integer'Image(f)));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"dn="&To_Wide_String(Integer'Image(dn)));
      -- Error_Log.Debug_Data(at_level=>9, with_details=>"Day_of_The_Week: Finish");
      return day_of_week'Val(dn-1);  -- enumeration type is 0 based
   end Day_of_The_Week;

   function To_Full_Day_Of_Week(for_day_of_week : day_of_week) 
    return full_day_of_week is
   begin
      return full_day_of_week'Val(day_of_week'Pos(for_day_of_week));
   end To_Full_Day_Of_Week;
    
   function To_Day_Of_Week(for_day_of_week : full_day_of_week)
    return day_of_week is
   begin
      return day_of_week'Val(full_day_of_week'Pos(for_day_of_week));
   end To_Day_Of_Week;
    
   function To_Full_Month(for_month : months) return full_months is
   begin
      return full_months'Val(months'Pos(for_month));
   end To_Full_Month;
    
   function To_Month(for_month : full_months) return months is
   begin
      return months'Val(full_months'Pos(for_month));
   end To_Month;

begin  -- Calendar_Extensions
   null;
end Calendar_Extensions;
