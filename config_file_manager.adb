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
with dStrings.IO;       use dStrings.IO;
with Strings_Functions; use Strings_Functions;
with Ada.Characters.Latin_1;
with Ada.Characters.Handling;
with Unchecked_Deallocation;
package body Config_File_Manager is
   -- use Ada.Wide_Text_IO;
   --    type config_file is limited private;
   --
   -- private
   --
   --    type ini_line_dets;
   --    type ini_line is access ini_line_dets;
   --    type ini_line_dets is record
   --          data : text;
   --          next : ini_line;
   --       end record;
   --
   --    type section_dets;
   --    type section is access section_dets;
   --    type section_dets is record
   --          name         : text;
   --          start_line   : ini_line;
   --          last_line    : ini_line;
   --          next         : section;
   --       end record;
   --
   --    type config_file is record
   --          file         : dStrings.IO.file_type;
   --          file_name    : text;
   --          lines        : ini_line;
   --          line_count   : natural := 0;
   --          current_line : ini_line;
   --          sections     : section;
   --          section_count: natural := 0;
   --          general      : ini_line;
   --          general_end  : ini_line;
   --          general_name : text := To_Text("GENERAL");
   --          comment_str  : text := Clear;
   --       end record;

   function To_Wide_Character(item : in character) return wide_character
   renames Ada.Characters.Handling.To_Wide_Character;

   function To_String(item : in wide_string;
                      substitute : in character := ' ') return string
   renames Ada.Characters.Handling.To_String;

   procedure Dispose_Line is new
             Unchecked_Deallocation(ini_line_dets, ini_line);
   procedure Dispose_Section is new
             Unchecked_Deallocation(section_dets, section);

   procedure Set_General_Section(to : in text; for_file: in out config_file) is
   begin
      for_file.general_name := to;
   end Set_General_Section;

   function General_Section(for_file : in config_file) return text is
   begin
      return for_file.general_name;
   end General_Section;

   procedure Set_Extra_Comment_Identifier(to : in text;
                                          for_file : in out config_file) is
   -- Specify an additional string to use to identify the
   -- start of a comment (e.g. "//").
   begin
      for_file.comment_str := to;
   end Set_Extra_Comment_Identifier;

   function Extra_Comment_Identifier(for_file: in config_file) return text is
   begin
      return for_file.comment_str;
   end Extra_Comment_Identifier;

   procedure Clear(the_configuration_details: in out config_file) is
      -- empty out any lists
      procedure Release_Storage(for_line : in out ini_line) is
      begin
         if for_line.next /= null then  -- get next first
            Release_Storage(for_line.next);
         end if;
         Dispose_Line(for_line);
      end Release_Storage;
      procedure Release_Storage(for_section: in out section) is
      begin
         if for_section.next /= null then  -- get next first
            Release_Storage(for_section.next);
         end if;
         Dispose_Section(for_section);
      end Release_Storage;
      the_file : config_file  renames the_configuration_details;
   begin
      if the_file.lines /= null then
         Release_Storage(for_line    => the_file.lines);
         the_file.lines    := null;
      end if;
      if the_file.sections /= null then
         Release_Storage(for_section => the_file.sections);
         the_file.sections := null;
      end if;
      if the_file.general /= null then
         the_file.general  := null;
      end if;
      if the_file.general_end /= null then
         the_file.general_end := null;
      end if;
      the_file.current_line  := null;
      the_file.line_count    := 0;
      the_file.section_count := 0;
   end Clear;

   procedure Load(the_file : in out dStrings.IO.file_type;
                  into_the_configuration_details : in out config_file) is
      -- load the list
      procedure Insert(the_line : text; into: in out ini_line) is
      begin
         if into /= null then
            Insert(the_line, into => into.next);
         else
            into := new ini_line_dets;
            into.data := the_line;
         end if;
      end Insert;
      procedure Terminate_Last_Section
      (for_config : in out config_file) is
         line_ptr    : ini_line := for_config.lines;
         section_ptr : section  := for_config.sections;
      begin
            -- Go to the last section entry
         while section_ptr /= null
         and then section_ptr.next /= null loop
            section_ptr := section_ptr.next;
         end loop;
            -- go to the second last (1 before current) line entry
         while line_ptr /= null
         and then line_ptr.next.next /= null loop
            line_ptr := line_ptr.next;
         end loop;
         section_ptr.last_line := line_ptr;
      end Terminate_Last_Section;
      procedure Start_New_Section(for_config : in out config_file)
      is
         line_ptr     : ini_line := for_config.lines;
         section_ptr  : section  := for_config.sections;
         section_name : text;
         num_chars    : positive;
         more_comments: text renames for_config.comment_str;
      begin
         -- Go to the last section entry
         while section_ptr /= null
         and then section_ptr.next /= null loop
            section_ptr := section_ptr.next;
         end loop;
         -- go to the last (i.e. current) line entry
         while line_ptr /=null and then line_ptr.next /= null loop
            line_ptr := line_ptr.next;
         end loop;
         -- extract the section name
         section_name := Upper_Case(line_ptr.data);
         if Pos(To_Text("#"), section_name) > 0 then
            num_chars := Length(section_name) -
               Pos(To_Text("#"), section_name) + 1;
            Delete(section_name,
               Pos(To_Text("#"), section_name), num_chars);
         end if;
         if Length(more_comments) > 0 and then
         Pos(more_comments, section_name) > 0 then
            num_chars := Length(section_name) -
               Pos(more_comments, section_name) + 1;
            Delete(section_name,
               Pos(more_comments, section_name), num_chars);
         end if;
         Delete(section_name, 1,
            Pos(To_Text("["), section_name));
         num_chars := Length(section_name) -
            Pos(To_Text("]"), section_name) + 1;
         Delete(section_name,
            Pos(To_Text("]"),section_name), num_chars);
            -- create and initialise the new section
         if section_ptr = null then  -- first section
            for_config.sections := new section_dets;
            for_config.sections.start_line := line_ptr;
            for_config.sections.name       := section_name;
         else  -- not the first section
            section_ptr.next := new section_dets;
            section_ptr.next.start_line := line_ptr;
            section_ptr.next.name       := section_name;
         end if;
      end Start_New_Section;
      procedure Terminate_General(for_config : in out config_file) is
         line_ptr    : ini_line := for_config.lines;
      begin
         -- go to the second last (1 before current) line entry
         while line_ptr /= null
         and then line_ptr.next.next /= null loop
            line_ptr := line_ptr.next;
         end loop;
         -- terminate the general section
         for_config.general_end := line_ptr;
      end Terminate_General;
      procedure Start_General(for_config : in out config_file) is
         line_ptr    : ini_line := for_config.lines;
      begin
         -- go to the last (i.e. current) line entry
         while line_ptr /=null and then line_ptr.next /=null loop
            line_ptr := line_ptr.next;
         end loop;
         -- initialise the general section
         for_config.general := line_ptr;
      end Start_General;
      the_config    : config_file
      renames into_the_configuration_details;
      more_comments: text renames the_config.comment_str;
      full_line     : text;
      stripped_line : text;
      in_general    : boolean := false;
      lbox          : constant wide_character := '[';
      rbox          : constant wide_character := ']';
      general_title : text:=lbox & the_config.general_name & rbox;
      num_chars     : positive;
   begin  -- Load
      Clear(the_config);
      Reset(the_file, mode => in_file);
      -- the_config.file := the_file;
      the_config.file_name := Value(Name(the_file));
      while not End_Of_File(the_file) loop
         begin
            Get_Line(the_file, full_line);
            exception
               when End_Error =>  -- on the last line?
                  if End_Of_File(the_file) then
                     Clear(full_line);  -- ignore its contents
                  else
                     raise;  -- reraise the error
                  end if;
         end;
         Insert(the_line => full_line, into => the_config.lines);
         the_config.line_count := the_config.line_count + 1;
         -- is this a section that is not the 'general' section ?
         if Pos(To_Text("#"), full_line) > 0 then
            num_chars := Length(full_line) -
               Pos(To_Text("#"), full_line) + 1;
            Delete(full_line, Pos(To_Text("#"), full_line),
               num_chars);
         end if;
         if Length(more_comments) > 0 and then
         Pos(more_comments, full_line) > 0 then
            num_chars := Length(full_line) -
               Pos(more_comments, full_line) + 1;
            Delete(full_line,
               Pos(more_comments, full_line), num_chars);
         end if;
         if Pos(To_Text("["), full_line) = 1 and then
         Pos(To_Text("]"), full_line) > 1 then  -- a section
            if Pos(general_title, full_line) = 1
            then  -- the 'general' section starting here
               if the_config.line_count > 1 and then
               the_config.sections /= null then  -- end off last
                  Terminate_Last_Section(for_config=> the_config);
               end if;
               Start_General(for_config => the_config);
               in_general := true;
            else  -- not a 'general' section
               if in_general then -- terminated the 'general' sctn
                  Terminate_General(for_config => the_config);
                  in_general := false;
               elsif the_config.line_count > 1 and then
               the_config.sections /= null then  -- end off last
                  Terminate_Last_Section(for_config => the_config);
               end if;
               Start_New_Section(for_config  => the_config);
               the_config.section_count :=
                  the_config.section_count + 1;
            end if;  -- general test
         end if;  -- section start
      end loop;  -- while not end of file
   end Load;

   procedure Load(the_file_with_name : wide_string;
                  into_the_configuration_details : in out config_file) is
      the_config : config_file renames into_the_configuration_details;
      a_file : dStrings.IO.file_type renames the_config.file;
   begin
      Open(a_file, mode => in_file,
         name => To_String(the_file_with_name),
         form => "WCEM=8");
      Load(the_file => a_file,
         into_the_configuration_details => the_config);
   end Load;

   procedure Load(into_the_configuration_details : in out config_file) is
      the_config : config_file renames into_the_configuration_details;
   begin
      Load(the_file => the_config.file,
           into_the_configuration_details => the_config);
   end Load;

   procedure Save(to_the_file : in out dStrings.IO.file_type;
                  with_the_configuration_details : in out config_file) is
      the_config : config_file renames with_the_configuration_details;
      the_file   : file_type renames to_the_file;
      line_ptr   : ini_line := the_config.lines;
   begin
      Reset(the_file, mode => out_file);
      while line_ptr /= null loop
         Put_Line(the_file, line_ptr.data);
         line_ptr := line_ptr.next;
      end loop;
      Flush(the_file);
   end Save;

   procedure Save(to_the_file_with_name : wide_string;
                  with_the_configuration_details :  in out config_file) is
      the_config : config_file renames with_the_configuration_details;
      a_file : file_type renames the_config.file;
   begin
      if Is_Open(a_file) then
         Close(the_config.file);   
      end if;
      Open(a_file, mode => out_file,
            name => To_String(to_the_file_with_name),
            form => "WCEM=8");
      Save(to_the_file => a_file,
            with_the_configuration_details => the_config);
   end Save;
   
   procedure Save(the_configuration_details :  in out config_file) is
      the_config : config_file renames the_configuration_details;
      a_file : dstrings.io.file_type renames the_config.file;
   begin
      if not Is_Open(a_file) then
         begin
            Open(a_file, mode => out_file,
                 name => Value(the_config.file_name),
                 form => "WCEM=8");
            exception
               when Use_Error =>  -- was actually open
                  null;  -- do nothing here
         end;
      end if;
      Save(to_the_file => a_file,
           with_the_configuration_details => the_config);
   end Save;
   
   procedure Close(the_configuration_file : in out config_file) is
      a_file : file_type renames the_configuration_file.file;
   begin
      Close(a_file);
   end Close;
   
   function Is_Config_File_Loaded(for_config: in config_file) return boolean is
   begin
      return Length(for_config.file_name) > 0;
   end Is_Config_File_Loaded;

   function Number_Of_Sections(in_file : in config_file) return natural is
   begin
      return in_file.section_count;
   end Number_Of_Sections;

   function The_Section(in_file : in config_file;
   at_number : in positive) return wide_string is
      section_ptr : section  := in_file.sections;
      section_number : natural := 0;
   begin
      -- Go to the desired section entry
      for section_number in 1 .. at_number - 1 loop
         if section_ptr /= null
         and then section_ptr.next /= null then
            section_ptr := section_ptr.next;
         else
            return "";  -- section number is beyond the end
         end if;
      end loop;
      if section_ptr /= null then
         return Value(section_ptr.name);
      else  -- did not find any such section
         return "";
      end if;
   end The_Section;

   procedure Reset_Line(from_file : in out config_file;
   to_start_of_section : in wide_string := "") is
      section_ptr : section := from_file.sections;
   begin
      if to_start_of_section'Length = 0 then
         from_file.current_line := from_file.lines;
      else  -- not looking to start from the start
         -- get the desired section
         while section_ptr /= null and then
         section_ptr.name /= To_Text(to_start_of_section) loop
            section_ptr := section_ptr.next;
         end loop;
         if section_ptr /= null then
            from_file.current_line := section_ptr.start_line;
         else  -- section does not exist
            from_file.current_line := null;
         end if;
      end if;
   end Reset_Line;

   function End_Of_File(file : in config_file) return boolean is
   begin
      return file.current_line = null;
   end End_Of_File;

   procedure Get_Line(from_file : in out config_file;
   the_line : out text; with_comments : boolean := true;
   concatenated : boolean := true) is
      tab : constant wide_character :=
      To_Wide_Character(Ada.Characters.Latin_1.HT);
      more_comments: text renames from_file.comment_str;
      num_chars : positive;
   begin
      if from_file.current_line /= null then
         loop
            the_line := from_file.current_line.data;
            from_file.current_line := from_file.current_line.next;
            if not with_comments then
               if Pos(To_Text("#"), the_line) > 0 then
                  num_chars := Length(the_line) -
                     Pos(To_Text("#"), the_line) + 1;
                  Delete(the_line,Pos(To_Text("#"),the_line),
                     num_chars);
               end if;
               if Length(more_comments) > 0 and then
               Pos(more_comments, the_line) > 0 then
                  num_chars := Length(the_line) -
                     Pos(more_comments, the_line) + 1;
                  Delete(the_line,
                     Pos(more_comments, the_line), num_chars);
               end if;
            end if;
            exit when Length(the_line) > 0 or else
               from_file.current_line = null;
         end loop;
         while (concatenated and from_file.current_line /= null)
         and then Length(Right_Trim(Right_Trim(the_line),tab)) > 0
         and then Element(Right_Trim(Right_Trim(the_line),tab),
         at_position=>Length(Right_Trim(Right_Trim(the_line),tab)))=
         '\' loop
            the_line := Right_Trim(Right_Trim(the_line),tab);
            Delete(the_line, Length(the_line), 1);
            the_line := the_line & from_file.current_line.data;
            from_file.current_line := from_file.current_line.next;
            if not with_comments then
               if Pos(To_Text("#"), the_line) > 0 then
                  num_chars := Length(the_line) -
                     Pos(To_Text("#"), the_line) + 1;
                  Delete(the_line,Pos(To_Text("#"),the_line),
                     num_chars);
               end if;
            end if;
         end loop;
      else  -- no line to return - return an empty line
         Clear(the_line);
      end if;
   end Get_Line;

   procedure Get_Line(from_file : in out config_file;
   the_line : out wide_string; with_comments : boolean := true) is
      a_line : text;
   begin
      Get_Line(from_file, a_line, with_comments);
      the_line := To_String(a_line);
   end Get_Line;

   procedure Get_Line(from_file : in out config_file;
   the_line : out wide_string; last : out natural) is
      a_line : text;
   begin
      Get_Line(from_file, a_line);
      the_line := To_String(a_line);
      last     := Length(a_line);
   end Get_Line;

   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string;
   concatenated : boolean := true) return text is
      section_ptr  : section := from_file.sections;
      line_ptr     : ini_line;
      a_line       : text;
      tab          : constant wide_character:=
      To_Wide_Character(Ada.Characters.Latin_1.HT);
      more_comments: text renames from_file.comment_str;
      num_chars    : positive;
   begin
      -- Get the desired section
      if To_Text(in_section) = from_file.general_name then
         section_ptr := new section_dets;
         section_ptr.start_line := from_file.general;
         section_ptr.last_line  := from_file.general_end;
         section_ptr.name       := from_file.general_name;
      end if;
      while section_ptr /= null and then
      section_ptr.name /= To_Text(in_section) loop
         section_ptr := section_ptr.next;
      end loop;
      -- Get the desired parameter (if section was found).
      -- Note that the current line we are on should be the
      -- name of the section.
      if section_ptr /= null and then
      section_ptr.start_line /= null and then
      section_ptr.start_line.next /= null then  -- some data
         -- move past the section name
         line_ptr := section_ptr.start_line.next;
         loop  -- locate the desired line
            a_line := line_ptr.data;
            if Pos(To_Text("#"), a_line) > 0 then
               num_chars := Length(a_line) -
                  Pos(To_Text("#"), a_line) + 1;
               Delete(a_line, Pos(To_Text("#"), a_line),
                  num_chars);
            end if;
            if Length(more_comments) > 0 and then
            Pos(more_comments, a_line) > 0 then
               num_chars := Length(a_line) -
                  Pos(more_comments, a_line) + 1;
               Delete(a_line,
                  Pos(more_comments, a_line), num_chars);
            end if;
            if Pos(To_Text(with_id & '='), a_line) = 1 then
               -- found the desired line
               Delete(a_line, 1, Pos(To_Text("="), a_line));
               if concatenated and line_ptr /= null
               then  -- get the next line
                  line_ptr := line_ptr.next;
               end if;
               while (concatenated and line_ptr /= null)
               and then Length(Right_Trim(Right_Trim(a_line),
               tab)) > 0
               and then Element(Right_Trim(Right_Trim(a_line),
               tab), at_position=>
               Length(Right_Trim(Right_Trim(a_line),tab)))= '\'
               loop
                  a_line := Right_Trim(Right_Trim(a_line),tab);
                  Delete(a_line, Length(a_line), 1);
                  a_line := a_line & line_ptr.data;
                  line_ptr := line_ptr.next;
                  if Pos(To_Text("\#"), a_line) = 0 then
                     Delete(a_line,Pos(To_Text("\#"),a_line),1);
                  elsif Pos(To_Text("#"), a_line) > 0 then
                     num_chars := Length(a_line) -
                        Pos(To_Text("#"), a_line) + 1;
                     Delete(a_line,Pos(To_Text("#"),a_line),
                        num_chars);
                  end if;
               end loop;
               if To_Text(in_section)=from_file.general_name then
                  Dispose_Section(section_ptr);
               end if;
               while Pos(To_Text("\#"), a_line) > 0 loop
                  Delete(a_line,Pos(To_Text("\#"),a_line),1);
               end loop;
               return Trim(Trim(a_line), of_character => tab);
            else  -- haven't got it yet
               Clear(a_line);
               line_ptr := line_ptr.next;
            end if;
            exit when line_ptr = null or -- at the end
               (section_ptr.last_line /= null and then
               line_ptr = section_ptr.last_line.next);
         end loop;
      end if;
      if To_Text(in_section)=from_file.general_name then
         Dispose_Section(section_ptr);
      end if;
      return a_line;  -- this would be empty if we got here
   end Read_Parameter;

   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return wide_string is
   begin
      return Value(Read_Parameter(from_file,in_section, with_id));
   end Read_Parameter;

   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return integer is
      result : integer := 0;
   begin
      result := Get_Integer_From_String
                      (Read_Parameter(from_file,in_section, with_id, false));
      return result;
      exception
         when Empty_String => 
            return result;
         when others =>
            return result;
   end Read_Parameter;

   function Read_Parameter(from_file : in config_file;
   in_section, with_id : in wide_string) return boolean is
   -- Note: boolean is represented in the file as Yes/No.
   begin
      return Read_Parameter(from_file,in_section,with_id,false) =
         To_Text("Yes");
   end Read_Parameter;

   procedure Put(parameter : in text;   into: in out config_file;
   in_section, with_id : in wide_string) is
      section_ptr  : section := into.sections;
      line_ptr     : ini_line;
      a_line       : text;
      more_comments: text renames into.comment_str;
      num_chars    : positive;
      procedure Goto_Last_Line(line_ptr : in out ini_line) is
      begin
        -- go to the last line entry
         while line_ptr /= null
         and then line_ptr.next /= null loop
            line_ptr := line_ptr.next;
         end loop;
      end Goto_Last_Line;
   begin
      -- Find the desired section
      if To_Text(in_section) = into.general_name then
         section_ptr := new section_dets;
         section_ptr.start_line := into.general;
         section_ptr.last_line  := into.general_end;
         section_ptr.name       := into.general_name;
      end if;
      while section_ptr /= null and then
      section_ptr.name /= To_Text(in_section) loop
         section_ptr := section_ptr.next;
      end loop;
      -- Get the desired parameter (if section was found).
      -- Note that the current line we are on should be the
      -- name of the section.
      if section_ptr /= null and then
      section_ptr.start_line /= null and then
      section_ptr.start_line.next /= null then  -- some data
         -- move past the section name
         line_ptr := section_ptr.start_line.next;
         loop  -- locate the desired line
            a_line := line_ptr.data;
            if Pos(To_Text("#"), a_line) > 0 then
               num_chars := Length(a_line) -
                  Pos(To_Text("#"), a_line) + 1;
               Delete(a_line, Pos(To_Text("#"), a_line),
                  num_chars);
            end if;
            if Length(more_comments) > 0 and then
            Pos(more_comments, a_line) > 0 then
               num_chars := Length(a_line) -
                  Pos(more_comments, a_line) + 1;
               Delete(a_line,
                  Pos(more_comments, a_line), num_chars);
            end if;
            if Pos(To_Text(with_id & '='), a_line) = 1 then
               -- found the desired line so load it with new data
               line_ptr.data := To_Text(with_id & '=') & parameter;
               exit;
            else  -- haven't got it yet
               Clear(a_line);
               if line_ptr.next /= null then  -- there is a next line
                  line_ptr := line_ptr.next;
               end if;
            end if;
            if line_ptr = null or else -- this should not happen
               line_ptr.next = null or else -- next line doesn't exist
               (section_ptr.last_line /= null and then
               line_ptr = section_ptr.last_line.next) then
            	-- at the end
               if line_ptr = null then  -- at last line
                  line_ptr := new ini_line_dets;
               elsif line_ptr.next = null then
                  line_ptr.next := new ini_line_dets;
                  line_ptr := line_ptr.next;
               else  -- not at last line, inserting for section
                  declare
                     old_line_ptr : ini_line := line_ptr;
                  begin
                     line_ptr := new ini_line_dets;
                     section_ptr.last_line.next := line_ptr;
                     line_ptr.next := old_line_ptr;
                  end;
               end if;
               line_ptr.data := To_Text(with_id & '=') & parameter;
               section_ptr.last_line := line_ptr;
               exit;
            end if;
         end loop;
         if To_Text(in_section)=into.general_name then
            Dispose_Section(section_ptr);
         end if;
      else -- section does not exist - create it
         if To_Text(in_section) = into.general_name then
            into.lines := new ini_line_dets;
            line_ptr := into.lines;
            line_ptr.data := 
               To_Text("# Automatically generated general section");
            line_ptr.next := new ini_line_dets;
            line_ptr := line_ptr.next;
            line_ptr.data := "[" & into.general_name & "]";
            line_ptr.next := new ini_line_dets;
            line_ptr := line_ptr.next;
            line_ptr.data := To_Text(with_id & '=') & parameter;
            into.general := into.lines;
            into.general_end := line_ptr;
         else
            section_ptr := new section_dets;
            section_ptr.name := To_Text(in_section);
            into.section_count := into.section_count + 1;
            Goto_Last_Line(line_ptr);
            line_ptr.next := new ini_line_dets;
            line_ptr := line_ptr.next;
            line_ptr.data := "# Automatically generated " &
               To_Text(in_section) & " section";
            line_ptr.next := new ini_line_dets;
            line_ptr := line_ptr.next;
            section_ptr.start_line := line_ptr;
            line_ptr.data := "[" & To_Text(in_section) & "]";
            line_ptr.next := new ini_line_dets;
            line_ptr.next.data := 
               To_Text(with_id & '=') & parameter;
            section_ptr.last_line := line_ptr.next;
            if To_Text(in_section)=into.general_name then
               Dispose_Section(section_ptr);
            end if;
         end if;
      end if;
   end Put;

   procedure Put(parameter : in wide_string;
   into: in out config_file; in_section, with_id : in wide_string)
   is
   begin
      Put(To_Text(parameter), into, in_section, with_id);
   end Put;

   procedure Put(parameter : in integer; into: in out config_file;
   in_section, with_id : in wide_string) is
   begin
      Put(Put_Into_String(parameter), into, in_section, with_id);
   end Put;

   procedure Put(parameter : in boolean; into: in out config_file;
   in_section, with_id : in wide_string) is
   begin
      if parameter then  -- put "Yes"
         Put(To_Text("Yes"), into, in_section, with_id);
      else  -- put "No"
         Put(To_Text("No"), into, in_section, with_id);
      end if;
   end Put;

begin
   null;
end Config_File_Manager;
