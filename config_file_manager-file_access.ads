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
--  Typical usage:                                                   --
--   Open(ini_file,at_parameter=>Value(Parameter(Value("NONAME1"))));--
--   Load(ini_file);                                                 --
--                                                                   --
--  Version History:                                                 --
--  $Log$                                                            --
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
   with dStrings.IO;
   package Config_File_Manager.File_Access is
   
      function Application_Name return wide_string;
         -- Strips the application name from the command line
   
      procedure Open(the_file : in out config_file;
      with_default_name : in wide_string := Application_Name & ".conf";
      at_parameter : in wide_string := "");
         -- Open the configuration file, using the specified parameter
         -- with the default name if the parameter does not exist.
   
      procedure Load(the_configuration_file : in out config_file);
         -- Load the already opened configuration file.
   
      procedure Save(the_configuration_file : in out config_file);
   	   -- Save the already opened configuration file.
   
      procedure Close(the_configuration_file : in out config_file);
   	   -- Close the already opened configuration file.
   
   end Config_File_Manager.File_Access;
