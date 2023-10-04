-----------------------------------------------------------------------
--                                                                   --
--                          E R R O R _ L O G                        --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides sophisticated error logging facilities    --
--  to an application.                                               --
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
-- with Ada.Strings.Wide_Unbounded;
with dStrings;
with dStrings.IO;
with Dynamic_Lists;
package Error_Log is

   type log_file is limited private;

   type Error_Display is access procedure (with_message : wide_string);
        --  Call back for error message display

   -- Error message information
   procedure Set_Error_Message_Terminator(for_log : in out log_file; 
                                          to : in wide_string);
   procedure Set_Error_Message_Terminator(to : in wide_string);
      -- using internal log file
   function Error_Message_Terminator(for_log : in log_file) return wide_string;
   procedure Set_Error_Display_Call_Back(for_log: in out log_file;
                                         to : Error_Display);
   procedure Set_Error_Display_Call_Back(to : Error_Display);
      -- using internal log file
   function Error_Display_Call_Back (for_log : in log_file)
   return Error_Display;

   -- Error logging
   procedure Set_Log_File_Name(to : in string; for_log : in out log_file; 
                               with_form : string := "");
      -- Load up the log file path and name for further reference.
   procedure Set_Log_File_Name(to : in string; with_form : string := "");
      -- using internal log file

   procedure Put(for_log: in out log_file; at_log_file: in string;
                 an_error_number : in integer;
                 error_intro, error_message : in wide_string);
      -- Log the error message to the specified log file.
   procedure Put(at_log_file: in string;
                 an_error_number : in integer;
                 error_intro, error_message : in wide_string);
      -- using internal log file
   procedure Put(for_log : in log_file; the_error : in integer;
                 error_intro, error_message : in dStrings.text);
   procedure Put(for_log : in log_file; the_error : in integer;
                 error_intro: in wide_string; error_message: in dStrings.text);
   procedure Put(for_log : in log_file; the_error : in integer;
                 error_intro, error_message : in wide_string);
             -- Error logging routine for trapped exceptions and other
             -- errors.
   procedure Put(the_error : in integer;
                 error_intro, error_message : in wide_string);
   procedure Put(the_error : in integer;
                 error_intro: in wide_string; error_message: in dStrings.text);
      -- using internal log file
   procedure Put(for_log : in out log_file;
                 error_exception : in wide_string);
      -- Display a message for an otherwise untrapped error
      -- exception.
   procedure Put_Error(error_exception : in wide_string);
      -- using internal log file

   -- Debug routines
   procedure Set_Debug_Level(for_log : in out log_file; to : in natural);
   procedure Set_Debug_Level(to : in natural);
      -- using internal log file
   function Debug_Level(for_log : in log_file) return natural;
   function Debug_Level return natural;
      -- using internal log file
   procedure Debug_Data(in_log : in log_file;
                        at_level: in natural; with_details : in dStrings.text);
   procedure Debug_Data(in_log : in log_file;
                        at_level : in natural; with_details : in wide_string);
   procedure Debug_Data(at_level : in natural; with_details: in dStrings.text);
   procedure Debug_Data(at_level : in natural; with_details : in wide_string);
      -- using internal log file

   -- Stack routines for determining failure points that cannot
   -- otherwise be detected.
   procedure Push_Stack(for_log : in out log_file; details : in wide_string);
   procedure Push_Stack(details : in wide_string);
      -- using internal log file
   procedure Pop_Stack(for_log : in out log_file; details : in wide_string);
   procedure Pop_Stack(details : in wide_string);
      -- using internal log file

   procedure Set_Email_Address(for_log : in out log_file; to : in wide_string);
   procedure Set_Email_Address(to : in wide_string);
      -- using internal log file
   procedure Set_Email(for_log : in out log_file; allowed : in boolean);
   procedure Set_Email(allowed : in boolean);
      -- using internal log file
   function Prevent_Email(for_log : in log_file) return boolean;

   function system_log return log_file;
   
private

   use dStrings.IO;
   use dStrings;
   -- use Ada.Strings.Wide_Unbounded;
   -- subtype text is unbounded_wide_string;
   -- function Value(source : in string) return text
   -- renames Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String;
   -- function Value(source : in text) return string
   -- renames Ada.Strings.Wide_Unbounded.To_String;

   package String_Lists is new Dynamic_Lists(text);
   use String_Lists;

   type file_access_ptr is access all dStrings.IO.File_Type;
   standard_error_file  : aliased dStrings.IO.File_Type;
   standard_output_file : aliased dStrings.IO.File_Type;

   type log_file is record
         log_file_name_and_path : text;
         the_debug_level        : natural := 0;
         procedure_stack        : string_lists.list;
         recursive_error        : boolean := false;--handler error?
         ini_file_name          : text;
         the_log                : file_access_ptr:= standard_error_file'Access;
         error_display_callback : Error_Display;
         email_address          : text;
         email_allowed          : boolean := false;
         message_terminate_text : text :=
         To_Text("Please see the data base administrator.");
      end record;

   the_error_log : log_file;  -- this is returned by system_log

   procedure Send_Email;
       -- e-mail sending procedure.  This procedure is called if
       -- e-mailing is required.
    
end Error_Log;
