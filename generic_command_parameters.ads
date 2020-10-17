-----------------------------------------------------------------------
--                                                                   --
--        G E N E R I C _ C O M M A N D _ P A R A M E T E R S        --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  extracts parameters from the command  line.   It  --
--  then   makes  those  parameters  available  for  use   by   the  --
--  application  on  an  individual  basis.    The  parameters  are  --
--  generally  of the form "-p" or "--param".  Built in  parameters  --
--  are provided for help and for the application's version number.  --
--  The instantiated package must provide a function to present the  --
--  version number.                                                  --
--                                                                   --
--  Version History:                                                 --
--  $Log: generic_command_parameters.ads,v $
--  Revision 1.1  2001/04/29 01:10:05  ross
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
with dStrings;  use dStrings;
with Strings_Functions;
generic
with function Ver return wide_string;
-- Return the version number (for use with the -v or --version
-- parameter)
-- 
parameter_list : wide_string;
-- parameter list of the form 
--  <flag>,<name>,<type>[[,<default],<hint>];<flag>,<name>...
-- where <flag> is a single character (preceded by '-');
--       <name> is a string (preceded by '--') ;
--       <type> is the parameter type (string/integer/boolean);
--       <default> is an optional default value; and
--       <hint is an optional usage clause (with no ',' or ';').
-- A flag of ' ' represents no flag for this name.
-- Trailing parameters of name 'NONAMEx' (where x is a sequential
-- number starting at 1) represent unnamed parameters.  This
-- structure would be used for passing directory paths for 
-- example.
-- Valid values for boolean are TRUE, FALSE, YES, NO, 1, 0.
-- Predefined parameters are:
--   -h, --help: display application usage (i.e. command line
--               parameters); and
--   -v, --version: display the application's version number.
-- Example invocation:
--   package Parameters is new Generic_Command_Parameters
--   ("p,param,string;i,other,integer;b,ok,boolean");
--
compulsory_nameless_parameters : natural := 0;
-- number of nameless (i.e. with a name of 'NONAMEx', as described
-- above) parameters (that should exist at the end of the list of
-- parameters) that must be provided.
--
use_exceptions : boolean := true;
-- either use exceptions to signal failure or help or version
-- parameters requested, or set flags (in which case the 
-- exceptions are not raised).
--
package Generic_Command_Parameters is

   type parameter_type is (pstring, pinteger, pboolean);
   type flag_type is new wide_character;
   no_flag : constant flag_type := ' ';
   type parameter_details(ptype: parameter_type) is private;

   Invalid_Parameter : exception;
   Help_Parameter    : exception;
   Version_Parameter : exception;
   is_invalid_parameter : boolean := false;
   is_help_parameter    : boolean := false;
   is_version_parameter : boolean := false;

   function Parameter(with_flag : in flag_type) return text;
   function Parameter(with_flag : in flag_type) return integer;
   function Parameter(with_flag : in flag_type) return boolean;

   function Parameter(with_name : in text) return text;
   function Parameter(with_name : in text) return integer;
   function Parameter(with_name : in text) return boolean;

   procedure Usage(with_cause : in wide_string := "");

private

   use Strings_Functions;

   type parameter_details(ptype: parameter_type) is record
         flag : flag_type := no_flag;
         name : text;
         hint : text;
         case ptype is
            when pstring  => svalue : text;
            when pinteger => ivalue : integer := 0;
            when pboolean => bvalue : boolean := false;
         end case;
      end record;
   type parameter_pointer is access parameter_details;

   type parameter_lists is array (positive  range <>) 
   of parameter_pointer;
   number_of_parameters : constant positive :=
   Component_Count(To_Text(parameter_list));
   the_parameters : parameter_lists(1..number_of_parameters);

end Generic_Command_Parameters;
