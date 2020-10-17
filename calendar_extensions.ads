-----------------------------------------------------------------------
--                                                                   --
--                 C A L E N D A R _ E X T E N S I O N S             --
--                                                                   --
--                            $Revision: 1.2 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package enhances Ada.Calendar to provide UTC time and  to  --
--  provide string conversion functions for time.                    --
--                                                                   --
--  Version History:                                                 --
--  $Log: calendar_extensions.ads,v $
--  Revision 1.2  2001/08/26 08:22:07  ross
--  Added missing "=" function.
--
--  Revision 1.1  2001/04/29 00:47:21  ross
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
with Ada.Calendar;
package Calendar_Extensions is

   subtype Time          is Ada.Calendar.Time;
   subtype Year_Number   is Ada.Calendar.Year_Number;
   subtype Month_Number  is Ada.Calendar.Month_Number;
   subtype Day_Number    is Ada.Calendar.Day_Number;
   subtype Day_Duration  is Ada.Calendar.Day_Duration;
   type day_of_week is (Mon, Tue, Wed, Thur, Fri, Sat, Sun);
   subtype weekday is day_of_week range Mon .. Fri;
   type full_day_of_week is (Monday, Tuesday, Wednesday, Thursday, Friday,
                             Saturday, Sunday);
   type months is (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec);
   type full_months is (January, February, March, April, May, June, July,
                        August, September, October, November, December);


   function Clock return Time
   renames Ada.Calendar.Clock;

   function UTC_Clock return Time;

   function Year(Date : Time)   return Year_Number
   renames Ada.Calendar.Year;
   function Month(Date: Time)   return Month_Number
   renames Ada.Calendar.Month;
   function Day(Date: Time)     return Day_Number
   renames Ada.Calendar.Day;
   function Seconds(Date: Time) return Day_Duration
   renames Ada.Calendar.Seconds;

   procedure Split(Date : in Time;
   Year : out Year_Number; Month : out Month_Number;
   Day  : out Day_Number;  Seconds : out Day_Duration)
   renames Ada.Calendar.Split;
   function Time_Of(Year : Year_Number; Month : Month_Number;
   Day : Day_Number; Seconds : Day_Duration) return Time
   renames Ada.Calendar.Time_Of;

   -- The following two functions convert time to or from a
   -- string.  The format is in accordance with a format string.
   -- The format string utilises the following field definitions:
   --
   --   dd   - Day of month (1 .. 31)
   --   mm   - Month of year (1 .. 12)
   --   yyyy - Year (1901 .. 2099) as per Ada.Calendar range
   --   hh   - hour
   --   nn   - minutes
   --   ss   - seconds
   --   uuu  - thousandths of a second (0.000 to 0.999 secs
   --                                   expressed as 000 - 999)
   --
   -- All other text in the format string is treated as litteral
   -- text and is either used to present the string or used as
   -- guidance as to where the date information is located in the
   -- string.
   function To_String(from_time : in time;
   with_format : wide_string := "dd/mm/yyyy hh:nn:ss") 
   return wide_string;
   function To_Time(from_string : in wide_string;
   with_format : wide_string := "dd/mm/yyyy hh:nn:ss") 
   return time;

   function "+"(Left: Time; Right: Duration) return time
   renames Ada.Calendar."+";
   function "+"(Left: Duration; Right: Time) return time
   renames Ada.Calendar."+";
   function "-"(Left: Time; Right: Duration) return time
   renames Ada.Calendar."-";
   function "-"(Left: Time; Right: Time) return Duration
   renames Ada.Calendar."-";
   function "<"(Left: Time; Right: Time) return boolean
   renames Ada.Calendar."<";
   function "<="(Left: Time; Right: Time) return boolean
   renames Ada.Calendar."<=";
   function "="(Left: Time; Right: Time) return boolean
   renames Ada.Calendar."=";
   function ">"(Left: Time; Right: Time) return boolean
   renames Ada.Calendar.">";
   function ">="(Left: Time; Right: Time) return boolean
   renames Ada.Calendar.">=";
   
   function Day_of_The_Week(for_date : time) return day_of_week;
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

   function To_Full_Day_Of_Week(for_day_of_week : day_of_week) 
    return full_day_of_week;
   function To_Day_Of_Week(for_day_of_week : full_day_of_week)
    return day_of_week;
   function To_Full_Month(for_month : months) return full_months;
   function To_Month(for_month : full_months) return months;
    
   Time_Error : exception renames Ada.Calendar.Time_Error;

end Calendar_Extensions;
