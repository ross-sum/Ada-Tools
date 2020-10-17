-----------------------------------------------------------------------
--                                                                   --
--               C O N F I G _ F I L E _ M A N A G E R               --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides configuration file managmenet facilities.  --
--  It operates on a configuration file (with fully qualified path)  --
--  and may read and write configuration details to that file.  The  --
--  configuration file is assumed to be broken up into sections that --
--  have a header of the form [headername] and details may be either --
--  text or information of the form parameter=value.  Details may    --
--  extend over more than one line by use of the backslash and       --
--  comments may be embedded using the # character to start comments --
--  and are terminated by the end of the line.                       --
--                                                                   --
--  Typical usage:                                                   --
--    my_host := Read_Parameter(ini_file, in_section=>"GENERAL",    --
--                              with_id=>"HOST");                    --
--    for section_num in 1 .. Number_of_Sections(ini_file) loop      --
--      my_param(section_num) :=                                     --
--         Read_Parameter(ini_file, in_section=>                     --
--           The_Section(in_file=>ini_file, at_number=>section_num), --
--           with_id=>"SQL DATA");                                   --
--    end loop;                                                      --
--                                                                   --
--  Configuration file format:                                       --
--    # is treated as the start of a comment.                        --
--    \ means the statement is continued over to the next line.      --
--    [SECTION]            denotes the start of a section.           --
--    <parameter>=<value>  denotes the parameter to value            --
--                         relationship.                             --
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
with dStrings;      use dStrings;
with dStrings.io;
-- with Ada.Wide_Text_IO;
package Config_File_Manager is

   type config_file is limited private;

   procedure Set_General_Section(to : in text;
   for_file : in out config_file);
   function General_Section(for_file : in config_file)
   return text;
   -- Default is "GENERAL" if not previously set.

   procedure Set_Extra_Comment_Identifier(to : in text;
   for_file : in out config_file);
   -- Specify an additional string to use to identify the
   -- start of a comment (e.g. "//").
   function Extra_Comment_Identifier(for_file: in config_file)
   return text;

   procedure Clear(the_configuration_details: in out config_file);
   procedure Load(the_file : in out dStrings.IO.file_type;
   into_the_configuration_details : in out config_file);
   procedure Load(the_file_with_name : wide_string;
   into_the_configuration_details : in out config_file);
   procedure Save(to_the_file : in out dStrings.IO.file_type;
   with_the_configuration_details : in config_file);
   procedure Save(to_the_file_with_name : wide_string;
   with_the_configuration_details :  in out config_file);

   function Number_Of_Sections(in_file : in config_file)
   return natural;
   function The_Section(in_file : in config_file;
   at_number : in positive) return wide_string;

   procedure Reset_Line(from_file : in out config_file;
   to_start_of_section : in wide_string := "");
   function End_Of_File(file : in config_file) return boolean;
   procedure Get_Line(from_file : in out config_file;
   the_line : out text; with_comments : boolean := true;
   concatenated : boolean := true);
   procedure Get_Line(from_file : in out config_file;
   the_line : out wide_string; with_comments : boolean := true);
   procedure Get_Line(from_file : in out config_file;
   the_line : out wide_string; last : out natural);

   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string;
   concatenated : boolean := true) return text;
   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return wide_string;
   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return integer;
   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return boolean;
   -- Note: boolean is represented in the file as Yes/No.

   procedure Put(parameter : in text;   into: in out config_file;
   in_section, with_id : in wide_string);
   procedure Put(parameter : in wide_string;   
   into: in out config_file; in_section, with_id : in wide_string);
   procedure Put(parameter : in integer; into: in out config_file;
   in_section, with_id : in wide_string);
   procedure Put(parameter : in boolean; into: in out config_file;
   in_section, with_id : in wide_string);

private

   type ini_line_dets;
   type ini_line is access ini_line_dets;
   type ini_line_dets is record
         data : text;
         next : ini_line;
      end record;

   type section_dets;
   type section is access section_dets;
   type section_dets is record
         name         : text;
         start_line   : ini_line;
         last_line    : ini_line;
         next         : section;
      end record;

   type config_file is record
         file         : dStrings.IO.file_type;
         file_name    : text;
         lines        : ini_line;
         line_count   : natural := 0;
         current_line : ini_line;
         sections     : section;
         section_count: natural := 0;
         general      : ini_line;
         general_end  : ini_line;
         general_name : text := To_Text("GENERAL");
         comment_str  : text := Clear;
      end record;

end Config_File_Manager;
