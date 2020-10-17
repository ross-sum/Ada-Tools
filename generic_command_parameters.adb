-----------------------------------------------------------------------
--                                                                   --
--        G E N E R I C _ C O M M A N D _ P A R A M E T E R S        --
--                                                                   --
--                             B o d y                               --
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
--  $Log: generic_command_parameters.adb,v $
--  Revision 1.1  2001/04/29 01:11:48  ross
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
      -- with dStrings;  use dStrings;
   with Ada.Command_Line;  use Ada.Command_Line;
   with Ada.Wide_Text_IO;
   with Ada.Characters.Handling;
   -- generic
   -- with function Ver return wide_string;
      -- Return the version number (for use with the -v or --version
      -- parameter)
      -- 
   -- parameter_list : wide_string;
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
   -- compulsory_nameless_parameters : natural := 0;
      -- number of nameless (i.e. with a name of 'NONAMEx', as described
      -- above) parameters (that should exist at the end of the list of
      -- parameters) that must be provided.
      --
   -- use_exceptions : boolean := true;
      -- either use exceptions to signal failure or help or version
      -- parameters requested, or set flags (in which case the 
      -- exceptions are not raised).
      --
   package body Generic_Command_Parameters is
   
      --    type parameter_type is (pstring, pinteger, pboolean);
      --    type flag_type is new character;
      --    no_flag : constant flag_type := ' ';
      --    type parameter_details(ptype: parameter_type) is private;
      -- private
      --    type parameter_details(ptype: parameter_type) is record
      --          flag : flag_type := no_flag;
      --          name : text;
      --          case ptype is
      --             when pstring  => svalue : text;
      --             when pinteger => ivalue : integer;
      --             when pboolean => bvalue : boolean;
      --          end case;
      --       end record;
      --    type parameter_pointer is access parameter_details;
   
      --    type parameter_lists is array (positive  range <>) 
      --    of parameter_pointer;
      --    number_of_parameters : constant positive :=
      --    Component_Count(Value(parameter_list));
      --    the_parameters : parameter_lists(1..number_of_parameters);
   
      function To_Wide_String(item : in string) return wide_string
      renames Ada.Characters.Handling.To_Wide_String;
   
      function Parameter(with_flag : in flag_type) return text is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.flag = with_flag then
               case the_parameters(param_number).all.ptype is
                  when pstring =>
                     return the_parameters(param_number).all.svalue;
                  when pinteger =>
                     return Put_Into_String
                        (the_parameters(param_number).all.ivalue);
                  when pboolean =>
                     if the_parameters(param_number).all.bvalue then
                        return To_Text("TRUE");
                     else
                        return To_Text("FALSE");
                     end if;
               end case;
            end if;
         end loop;
         return Clear;  -- result if not found
      end Parameter;
   
      function Parameter(with_flag : in flag_type) return integer is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.flag = with_flag then
               if the_parameters(param_number).all.ptype = pinteger 
               then
                  return the_parameters(param_number).all.ivalue;
               else  -- looking for data of the wrong type
                  return 0;  -- default for error in type
               end if;
            end if;
         end loop;
         return 0;      -- result if not found
      end Parameter;
   
      function Parameter(with_flag : in flag_type) return boolean is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.flag = with_flag then
               if the_parameters(param_number).all.ptype = pboolean 
               then
                  return the_parameters(param_number).all.bvalue;
               else  -- looking for data of the wrong type
                  return false;  -- default for error in type
               end if;
            end if;
         end loop;
         return false;  -- result if not found
      end Parameter;
   
      function Parameter(with_name : in text) return text is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.name = with_name then
               case the_parameters(param_number).all.ptype is
                  when pstring =>
                     return the_parameters(param_number).all.svalue;
                  when pinteger =>
                     return Put_Into_String
                        (the_parameters(param_number).all.ivalue);
                  when pboolean =>
                     if the_parameters(param_number).all.bvalue then
                        return To_Text("TRUE");
                     else
                        return To_Text("FALSE");
                     end if;
               end case;
            end if;
         end loop;
         return Clear;  -- result if not found
      end Parameter;
   
      function Parameter(with_name : in text) return integer is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.name = with_name then
               if the_parameters(param_number).all.ptype = pinteger 
               then
                  return the_parameters(param_number).all.ivalue;
               else  -- looking for data of the wrong type
                  return 0;  -- default for error in type
               end if;
            end if;
         end loop;
         return 0;      -- result if not found
      end Parameter;
   
      function Parameter(with_name : in text) return boolean is
      begin
         for param_number in 1 .. number_of_parameters loop
            if the_parameters(param_number).all.name = with_name then
               if the_parameters(param_number).all.ptype = pboolean 
               then
                  return the_parameters(param_number).all.bvalue;
               else  -- looking for data of the wrong type
                  return false;  -- default for error in type
               end if;
            end if;
         end loop;
         return false;  -- result if not found
      end Parameter;
   
      procedure Usage(with_cause : in wide_string := "") is
         use Ada.Wide_Text_IO;
         package Int_IO is new Ada.Wide_Text_IO.Integer_IO(integer);
         use Int_IO;
         unflagged_count : positive := 1;
      begin
         Put_Line(Standard_Error, To_Wide_String(Command_Name) & 
      	   ", version " & Ver & ", usage:");
         -- List the command line with options
         Put(Standard_Error, To_Wide_String(Command_Name) & " -hv");
         for cntr in 1 .. number_of_parameters loop
            if the_parameters(cntr).all.flag /=no_flag then
               Put(Standard_Error, 
                  wide_character(the_parameters(cntr).all.flag));
            end if;
         end loop;
         Put(Standard_Error, " --help --version ");
         for cntr in 1 .. number_of_parameters loop
            if Length(the_parameters(cntr).all.name) > 0 then
               if Pos(To_Text("NONAME"), the_parameters(cntr).all.name)
               = 0 then
                  Put(Standard_Error, "--" &
                     To_String(the_parameters(cntr).all.name) & " ");
               else
                  if unflagged_count > compulsory_nameless_parameters
                  then 
                     Put(Standard_Error, '[');
                  end if;
                  Put(Standard_Error, 
                     To_String(the_parameters(cntr).all.hint));
                  if unflagged_count > compulsory_nameless_parameters
                  then 
                     Put(Standard_Error, ']');
                  end if;
                  Put(Standard_Error, " ");
                  unflagged_count := unflagged_count + 1;
               end if;
            end if;
         end loop;
         New_Line(Standard_Error);
         New_Line(Standard_Error);
         -- List each parameter and its definition vertically
         Put_Line(Standard_Error, "Parameters:");
         Put_Line(Standard_Error, "    " & 
            "-h, --help: print these usage details");
         Put_Line(Standard_Error, "    " & 
            "-v, --version: print the application's version number");
         for cntr in 1 .. number_of_parameters loop
            Put(Standard_Error, "    ");
            if the_parameters(cntr).all.flag /= no_flag then
               Put(Standard_Error, "-" & 
                  wide_character(the_parameters(cntr).all.flag));
               if Length(the_parameters(cntr).all.name) > 0 then
                  Put(Standard_Error, ", ");
               end if;
            end if;
            if Length(the_parameters(cntr).all.name) > 0 and then
            Pos(To_Text("NONAME"), the_parameters(cntr).all.name) = 0 
            then
               Put(Standard_Error, "--" & 
                  To_String(the_parameters(cntr).all.name));
            end if;
            if Length(the_parameters(cntr).all.name) = 0 or else
            Pos(To_Text("NONAME"), the_parameters(cntr).all.name) = 0 
            then
               Put(": ");
            end if;
            case the_parameters(cntr).all.ptype is
               when pstring  => Put (Standard_Error, "(string) ");
               when pinteger => Put (Standard_Error, "(number) ");
               when pboolean => 
                  if Length(the_parameters(cntr).all.name)>0 and then
                  Pos(To_Text("NONAME"),the_parameters(cntr).all.name)=1
                  then
                     Put (Standard_Error, 
                        "({True,False}|{Yes,No}|{T,F}|{Y|N}) ");
                  else
                     Put (Standard_Error, "(presence means true)");
                  end if;
            end case;
            if Length(the_parameters(cntr).all.hint) > 0 then
               Put(Standard_Error, 
                  To_String(the_parameters(cntr).all.hint));
            end if;
            case the_parameters(cntr).all.ptype is
               when pstring  => 
                  if Length(the_parameters(cntr).all.svalue) > 0 then
                     Put (Standard_Error, " [" & 
                        To_String(the_parameters(cntr).all.svalue) & "]");
                  end if;
               when pinteger => 
                  if the_parameters(cntr).all.ivalue /= 0 then
                     Put (Standard_Error, " [");
                     Put(Standard_Error, 
                        the_parameters(cntr).all.ivalue);
                     Put(Standard_Error, ']');
                  end if;
               when pboolean => null;
            end case;
            New_Line(Standard_Error);
         end loop;
         -- Print out any with_cause message
         if with_cause'Length > 0 then
            New_Line(Standard_Error);
            Put_Line(Standard_Error, with_cause);
         end if;
         New_Line(Standard_Error);
      end Usage;
   
      parameter_list_as_text : constant text := To_Text(parameter_list);
      current_parameter_string : text;
      flag           : flag_type;
      param_type     : parameter_type;
      details        : text;
      string_word    : constant text := To_Text("string");
      integer_word   : constant text := To_Text("integer");
      boolean_word   : constant text := To_text("boolean");
   begin
      -- Load up the parameters into the_parameters list
      for param_number in 1.. number_of_parameters loop
         -- set up the parameter skeleton
         current_parameter_string := 
            Component(of_the_string => parameter_list_as_text,
            at_position => param_number, separated_by => ';');
         details:= Component(of_the_string=>current_parameter_string,
            at_position => 1, separated_by => ',');
      	--@ Ada.wide_Text_IO.Put("Components: " & Integer'Image(
            --@ Component_Count(current_parameter_string,','))); 
         if Length(details) = 1 then
            flag := 
               flag_type(Wide_Element(of_string=>details,at_position=>1));
         	--@ Ada.wide_Text_IO.Put(" Flag:" & character(flag));
         else
            flag := no_flag;
         end if;
         Clear(details);  -- clean up
         details:= Component(of_the_string=>current_parameter_string,
            at_position => 3, separated_by => ',');
         if details = string_word then
            param_type := pstring;
         	--@ Ada.wide_Text_IO.Put(" type:pstring");
         elsif details = integer_word then
            param_type := pinteger;
         	--@ Ada.wide_Text_IO.Put(" type:pinteger");
         elsif details = boolean_word then
            param_type := pboolean;
         	--@ Ada.wide_Text_IO.Put(" type:pboolean");
         else  -- use default
            param_type := pstring;
         end if;
         Clear(details);  -- clean up
         the_parameters(param_number) := 
            new parameter_details(param_type);
         the_parameters(param_number).all.flag := flag;
         the_parameters(param_number).all.name := Component(
            of_the_string => current_parameter_string,
            at_position => 2, separated_by => ',');
      	--@ Ada.wide_Text_IO.Put_Line(" name:'" & 
            --@ Value(the_parameters(param_number).all.name) & "'.");
         if Component_Count(current_parameter_string,',') > 3 and
         then Length(Component(current_parameter_string, 4, ',')) > 0
         then
            details := Component(
               of_the_string => current_parameter_string,
               at_position => 4, separated_by => ',');
            case param_type is
               when pstring =>
                  the_parameters(param_number).all.svalue := details;
               when pinteger =>
                  the_parameters(param_number).all.ivalue := 
                     Get_Integer_From_String(details);
               when pboolean =>
                  the_parameters(param_number).all.bvalue := 
                     Upper_Case(details) = To_Text("TRUE") or
                     Upper_Case(details) = To_Text("T") or
                     Upper_Case(details) = To_Text("YES") or
                     Upper_Case(details) = To_Text("Y") or
                     details = To_Text("1");
            end case;
            Clear(details);
         end if;
         if Component_Count(current_parameter_string,',') > 4 then
            the_parameters(param_number).all.hint := Component(
               of_the_string => current_parameter_string,
               at_position => 5, separated_by => ',');
            --@ Ada.Text_IO.Put_Line(" hint:'" & 
               --@ Value(the_parameters(param_number).all.hint) & "'.");
         end if;
         Clear(current_parameter_string);  -- clean up
      end loop;
   	-- Extract the parameter details from the command line
      declare
         param_number    : positive := 1;
         unflagged_count : positive := 1;
         found_it        : boolean;
         use Ada.Wide_Text_IO;
      begin
         while param_number <= Argument_Count loop
            details := Value(Argument(param_number));
            if Length(details) > 1 then
               if Length(details) > 2 and then
               (Element(details, 1) = '-' and 
               Element(details, 2) = '-') then
                  -- It is a full flag value
                  found_it := false;
                  -- Get the flag name
                  Delete(details, 1, 2);  -- get rid of the indicator
                  for item in 1 .. number_of_parameters loop
                     if the_parameters(item).all.name = details then
                        case the_parameters(item).all.ptype is
                           when pstring => 
                              the_parameters(item).all.svalue :=
                                 Value(Argument(param_number + 1));
                              param_number := param_number + 1;  
                           when pinteger => 
                              if Argument_Count <= param_number or 
                              else Argument(param_number+1)'Length=0
                              then
                                 Usage("Parameter '--" & 
                                    To_String(details) & 
                                    "' (at parameter position" & 
                                    To_Wide_String(
                              		Integer'Image(param_number)) & 
                                    ") requires a number.");
                                 is_invalid_parameter := true;
                                 raise Invalid_Parameter;
                              end if;
                              the_parameters(item).all.ivalue :=
                                 Get_Integer_From_String(
                                 Value(Argument(param_number + 1)));
                              param_number := param_number + 1;
                           when pboolean =>
                              the_parameters(item).all.bvalue:= true;
                        end case;
                        found_it := true;
                        exit;
                     end if;
                  end loop;
                  if not found_it and then details = To_Text("help") then
                     -- i.e. check for help
                     found_it := true;
                     Usage;
                     is_help_parameter := true;
                     raise Help_Parameter;
                  elsif not found_it and 
                  then details = To_Text("version") then
                     -- i.e. check for version
                     found_it := true;
                     Put_Line(Standard_Error, "Version: " & Ver);
                     is_version_parameter := true;
                     raise Version_Parameter;
                  end if;
                  if not found_it then
                     Usage("Parameter " & 
                  	   To_Wide_String(Argument(param_number)) & 
                        " not found at argument position " & 
                        To_Wide_String(Integer'Image(param_number)) & ".");
                     is_invalid_parameter := true;
                     raise Invalid_Parameter;
                  end if;
               elsif Wide_Element(details, 1) = '-' then
                  -- one or more single character flags
                  found_it := false;
                  Delete(details, 1, 1);  -- get rid of the indicator
                  for cntr in 1 .. Length(details) loop
                     for item in 1 .. number_of_parameters loop
                        if the_parameters(item).all.flag =
                        flag_type(Wide_Element(details, cntr)) then
                           case the_parameters(item).all.ptype is
                              when pstring => 
                                 the_parameters(item).all.svalue :=
                                    Value(Argument(param_number + 1));
                                 param_number := param_number + 1;  
                              when pinteger => 
                                 if Argument_Count <= param_number 
                                 or else
                                 Argument(param_number+1)'Length=0
                                 then
                                    Usage("Parameter '-" & 
                                       Wide_Element(details, cntr) & 
                                       "' (at parameter position" & 
                                       To_Wide_String(
                                 		Integer'Image(param_number)) & 
                                       ") requires a number.");
                                    is_invalid_parameter := true;
                                    raise Invalid_Parameter;
                                 end if;
                                 the_parameters(item).all.ivalue :=
                                    Get_Integer_From_String(
                                    Value(Argument(param_number+1)));
                                 param_number := param_number + 1;
                              when pboolean =>
                                 the_parameters(item).all.bvalue:=true;
                           end case;
                           found_it := true;
                           exit;
                        end if;
                     end loop;
                     if not found_it and then 
                     Wide_Element(details, cntr) = 'h' then
                        -- i.e. check for help
                        found_it := true;
                        Usage;
                        is_help_parameter := true;
                        raise Help_Parameter;
                     elsif not found_it and then
                     Wide_Element(details, cntr) = 'v' then
                        -- i.e. check for version
                        found_it := true;
                        Put_Line(Standard_Error, "Version: " & Ver);
                        is_version_parameter := true;
                        raise Version_Parameter;
                     end if;
                     if not found_it then
                        Usage("A parameter in '-" & 
                           Wide_Element(details, cntr) & 
                           "' not found at argument number " & 
                           To_Wide_String(
                     		Integer'Image(param_number)) & ".");
                        is_invalid_parameter := true;
                        raise Invalid_Parameter;
                     end if;
                  end loop;
               else  -- an unflagged value
                  found_it := false;
                  for item in 1 .. number_of_parameters loop
                     if the_parameters(item).all.name=To_Text("NONAME")
                     & Put_Into_String(unflagged_count) then
                        case the_parameters(item).all.ptype is
                           when pstring => 
                              the_parameters(item).all.svalue :=
                                 details;
                           when pinteger => 
                              the_parameters(item).all.ivalue :=
                                 Get_Integer_From_String(details);
                           when pboolean =>
                              the_parameters(item).all.bvalue:=
                                 Upper_Case(details) = To_Text("TRUE") or
                                 Upper_Case(details) = To_Text("T") or
                                 Upper_Case(details) = To_Text("YES") or
                                 Upper_Case(details) = To_Text("Y") or
                                 details = Value("1");
                        end case;
                        unflagged_count := unflagged_count + 1;
                        found_it := true;
                        exit;
                     end if;
                  end loop;
                  if not found_it then
                     Usage("Parameter " & 
                  	   To_Wide_String(Argument(param_number)) & 
                        " not found at argument position " & 
                        To_Wide_String(Integer'Image(param_number)) & 
                  		".");
                     is_invalid_parameter := true;
                     raise Invalid_Parameter;
                  end if;
               end if;
            else
               null;
            end if;
            param_number := param_number + 1;
         end loop;
         if unflagged_count < compulsory_nameless_parameters then
            Usage("Insufficient parameters in command line.");
            is_invalid_parameter := true;
            raise Invalid_Parameter;
         end if;
         exception
            when Constraint_Error =>
               Usage("Invalid value at parameter " & 
                  To_Wide_String(Integer'Image(param_number)));
               is_invalid_parameter := true;
               if use_exceptions then
                  raise Invalid_Parameter;
               end if;
            when No_Number =>
               Usage("Invalid number at parameter " & 
                  To_Wide_String(Integer'Image(param_number)));
               is_invalid_parameter := true;
               if use_exceptions then
                  raise Invalid_Parameter;
               end if;
            when Invalid_Parameter | Help_Parameter | Version_Parameter=>
               if use_exceptions then
                  raise;
               end if;
      end;
   end Generic_Command_Parameters;
