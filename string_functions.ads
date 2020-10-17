-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                           I N T E R B A S E                             --
--                                                                         --
--                                B o d y                                  --
--                                                                         --
--                             Version: 1.0.0                              --
--                                                                         --
--  Copyright (C) 1999  Hyper Quantum Pty Ltd.                             --
--                                                                         --
--  This software was developed using AdaSockets as the base for commun-   --
--  icating with an InterBase data base.  Access to the data base is via   --
--  InterBase's standard block based communications (determined by trial   --
--  and error).  Loggiing on is via a single command line of the form:     --
--    "[server:]/path/to/data/base.gdb username userpassword;".            --
--  Results are in the form of comma separated values, with the first      --
--  line being the header line.  The whole application can be thought of   --
--  as a primitive SQL data base engine interface server, similar to       --
--  Borland's BDE.                                                         --
--                                                                         --
--   InterBase is free software; you can  redistribute it and/or modify    --
--   it  under terms of the GNU  General  Public Licence as published by   --
--   the Free Software Foundation; either version 2, or (at your option)   --
--   any later version.   InterBase is distributed  in the hope that it    --
--   will be useful, but WITHOUT ANY  WARRANTY; without even the implied   --
--   warranty of MERCHANTABILITY   or FITNESS FOR  A PARTICULAR PURPOSE.   --
--   See the GNU General Public  Licence  for more details.  You  should   --
--   have received a copy of the  GNU General Public Licence distributed   --
--   with InterBase; see   file COPYING.  If  not,  write  to  the Free    --
--   Software  Foundation, 59   Temple Place -   Suite  330,  Boston, MA   --
--   02111-1307, USA.                                                      --
--                                                                         --
--                                                                         --
-----------------------------------------------------------------------------

   package String_Functions is
   
      function Pos (of_string, within_string : in wide_string;
      starting_at : positive := 1) return integer;
    -- Find the position of_string within the string within_string.
    -- If the string cannot be found, return -1.
   
      function Upper_Case(of_object : in wide_string) return wide_string;
    -- Return the upper case equivalent of the string.
   
      function Lower_Case(of_object : in wide_string) return wide_string;
    -- Return the lower case equivalent of the string.
   
      procedure Upper_Case(of_object : in out wide_string);
    -- Return the upper case equivalent of the string.
   
      procedure Lower_Case(of_object : in out wide_string);
    -- Return the lower case equivalent of the string.
   
      function Left_Trim (the_string : wide_string; 
      of_character : wide_character := ' ') return wide_string;
    -- Trim characters (usually spaces) from the left hand side
      function Right_Trim (the_string : wide_string; 
      of_character : wide_character := ' ') return wide_string;
    -- Trim characters (usually spaces) from the right hand side
      function Trim (the_string : wide_string; 
      of_character : wide_character := ' ') return wide_string;
    -- Trim characters (usually spaces) from both sides of the string.
      function Assign(the_string : in wide_string;
      of_length  : in natural;
      with_padding : in wide_character := ' ') return wide_string;
    -- Assign the_string to the result.  Pad out the result with 
    -- with_padding.  The result has a length of of_length.
      procedure Assign(the_string : in wide_string;
      of_length  : out natural;
      to_string  : out wide_string;
      with_padding : in wide_character := ' ');
    -- Assign the_string to to_string.  Set of_length to the_string's
    -- length and pad out to_string with with_padding.
   
      function There_Is(equivalence_between : in wide_string;
      and_the_string : in wide_string;
      of_length : in natural) return boolean;
    -- returns true if the string equivalence_between contains the
    -- same information as and_the_string(1..of_length).
   
   end String_Functions;