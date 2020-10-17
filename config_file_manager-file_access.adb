-----------------------------------------------------------------------
--                                                                   --
--   C O N F I G _ F I L E _ M A N A G E R . F I L E _ A C C E S S   --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001,2011  Hyper Quantum Pty Ltd.             --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides file access facilities, namely Open and    --
--  load, for use with the Config_File_Manager package.  It opens    --
--  the configuration file from a series of default locations        --
--  (e.g. /etc/, /usr/local/etc).                                    --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
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
   with Ada.Command_Line;        use Ada.Command_Line;
   with Ada.Characters.Handling; use Ada.Characters.Handling;
   with dStrings;                use dStrings;
   package body Config_File_Manager.File_Access is
      use dStrings.IO;
   
      function Application_Name return wide_string is
         -- Strips the application name from the command line
         the_application : text := Value(Command_Name);
         slash : constant text  := To_Text("/");
      begin
         while Length(the_application) > 0 and then
         Pos(slash, the_application) > 0 loop
            Delete(the_application, 1, Pos(slash, the_application));
         end loop;
         return To_String(the_application);
      end Application_Name;
   
      procedure Open(the_file : in out config_file;
      with_default_name : in wide_string := Application_Name & ".conf";
      at_parameter : in wide_string := "") is
         -- Open the configuration file, using the specified parameter
         -- with the default name if the parameter does not exist.
         config       : file_type renames the_file.file;
         default_name : string    := To_String(with_default_name);
         file_name    : string    := To_String(at_parameter);
      begin
         if at_parameter'Length = 0
         then -- check local, /usr/local/etc +/etc
            begin  -- block to attempt to open locally
               Open(config, in_file, default_name, form=>"WCEM=8");
               exception
                  when Name_Error | Use_Error =>
                     begin  -- attempt to open at /usr/local/etc
                        Open(file => config, mode => in_file,
                           name => "/usr/local/etc/" & default_name,
                           form => "WCEM=8");
                        exception  -- not at /usr/local/etc, try /etc
                           when Name_Error | Use_Error =>
                              Open(file => config, mode => in_file,
                                 name => "/etc/"& default_name,
                                 form => "WCEM=8");
                     end;  -- /usr/local/etc exception block
            end;  -- local exception block
         else  -- first parameter should be the configuration file name
            begin  -- block to attempt to open as a full path name
               Open(config, mode => in_file, name => file_name,
                  form => "WCEM=8");
               exception  -- not a full file name, may be just path name
                  when Name_Error | Use_Error =>
                     begin
                        Open(file => config, mode => in_file,
                           name => file_name & default_name,
                           form => "WCEM=8");
                        exception -- not a path name, try at /usr/local/etc
                           when Name_Error | Use_Error =>
                              begin  -- attempt to open at /usr/local/etc
                                 Open(file => config, mode => in_file,
                                    name=>"/usr/local/etc/"&file_name,
                                    form => "WCEM=8");
                                 exception  -- not there, try /etc
                                    when Name_Error | Use_Error =>
                                       Open(file=>config, mode=>in_file,
                                          name=>"/etc/"& file_name,
                                          form=>"WCEM=8");
                              end;  -- /usr/local/etc exception block
                     end;
            end;  -- exception block
         end if;
      end Open;
   
      procedure Close(the_configuration_file : in out config_file) is
         -- Close the already opened configuration file.
      begin
         Close(the_configuration_file.file);
      end Close;
   
      procedure Load(the_configuration_file : in out config_file) is
         -- Load the already opened configuration file.
      begin
         Load(the_file => the_configuration_file.file,
            into_the_configuration_details => the_configuration_file);
      end Load;
      
      procedure Save(the_configuration_file : in out config_file) is
         -- Save the already opened configuration file.
      begin
         Save(to_the_file => the_configuration_file.file,
            with_the_configuration_details => the_configuration_file);
      end Save;
   
   end Config_File_Manager.File_Access;
