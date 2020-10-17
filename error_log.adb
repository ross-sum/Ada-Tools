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
with Calendar_Extensions;     use Calendar_Extensions;
with Ada.Command_Line;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Interlocks;              use Interlocks;
package body Error_Log is

   --       type log_file is limited private;
   --       type Error_Display is access
   --            procedure (with_message:string);
     --          --  Call back for error message display
   --    private
   --       use Ada.Wide_Text_IO;
   --       use use dStrings;
   --       package String_Lists is new Dynamic_Lists(text);
   --       use String_Lists;
   --       type file_access_ptr is access all Ada.Text_IO.File_Type;
   --       standard_error_file  : aliased Ada.Text_IO.File_Type;
   --       standard_output_file : aliased Ada.Text_IO.File_Type;
   --       type log_file is record
   --             log_file_name_and_path : text;
   --             the_debug_level : natural := 0;
   --             procedure_stack : string_lists.list;
   --             recursive_error : boolean := false;--handler error?
   --             ini_file_name   : text;
   --             the_log         : file_Access_ptr :=
   --             standard_error_file'Access;
   --             error_display_callback : Error_Display;
   --             email_address          : text;
   --             email_allowed          : boolean := false;
   --             message_terminate_text : text :=
   --             Value("Please see the data base administrator.");
   --          end record;

   Log_Write_Lock : Interlocks.Interlock;
   
   -- Error message information
   procedure Set_Error_Message_Terminator(
               for_log : in out log_file; to : in wide_string) is
   begin
      for_log.message_terminate_text := To_Text(to);
   end Set_Error_Message_Terminator;

   procedure Set_Error_Message_Terminator(to : in wide_string) is
      -- using internal log file
   begin
      Set_Error_Message_Terminator(the_error_log, to);
   end Set_Error_Message_Terminator;

   function Error_Message_Terminator(for_log : in log_file)
                                    return wide_string is
   begin
      return Value(for_log.message_terminate_text);
   end Error_Message_Terminator;

   procedure Set_Error_Display_Call_Back(for_log: in out log_file;
                                         to : Error_Display) is
   begin
      for_log.error_display_callback := to;
   end Set_Error_Display_Call_Back;

   procedure Set_Error_Display_Call_Back(to : Error_Display) is
      -- using internal log file
   begin
      Set_Error_Display_Call_Back(the_error_log, to);
   end Set_Error_Display_Call_Back;

   function Error_Display_Call_Back (for_log : in log_file)
   return Error_Display is
   begin
      return for_log.error_display_callback;
   end Error_Display_Call_Back;

   -- Error logging
   procedure Set_Log_File_Name(to : in string;
   for_log : in out log_file) is
      -- Load up the log file path and name for further reference.
   begin
      for_log.log_file_name_and_path := Value(to);
      -- ensure we have a file type to handle the desired file
      if for_log.the_log = standard_error_file'Access or
      for_log.the_log = standard_output_file'Access then
         for_log.the_log := new Ada.Wide_Text_IO.File_Type;
      else
         Close(for_log.the_log.All);
      end if;
      -- Open (or create) the file if it is not a standard type,
      -- otherwise assign it to the appropriate standard file type.
      if to = "Standard_Error" then
         for_log.the_log := standard_error_file'Access;
      elsif to = "Standard_Output" then
         for_log.the_log := standard_output_file'Access;
      else
         begin
            Open(for_log.the_log.all, Append_File, to);
            exception
               when Name_Error =>
                  Create(for_log.the_log.all, Out_File, to);
         end;
      end if;
   end Set_Log_File_Name;

   procedure Set_Log_File_Name(to : in string) is
      -- using internal log file
   begin
      Set_Log_File_Name(to, the_error_log);
   end Set_Log_File_Name;

   procedure Put(for_log : in out log_file; at_log_file : in string;
                 an_error_number : in integer;
                 error_intro, error_message : in wide_string) is
      -- Log the error message to the specified log file.
   begin
      Set_Log_File_Name(for_log => for_log, to => at_log_file);
      Put(for_log, an_error_number, error_intro, error_message);
   end Put;

   procedure Put(at_log_file: in string;
   an_error_number : in integer;
   error_intro, error_message : in wide_string) is
      -- using internal log file
   begin
      Put(the_error_log, at_log_file, an_error_number,
         error_intro, error_message);
   end Put;

   procedure Put(for_log : in log_file; the_error : in integer;
                 error_intro, error_message : in wide_string) is
      function Put (n : in integer) return wide_string is
         result : wide_string(1..1);
      begin
         if n < 0 then  -- this is the first time in
            return '-' & Put(n);
         elsif n >= 10 then
            return wide_character'Val(n rem 10 + 
               wide_character'Pos('0')) &
               Put( n / 10);
         else
            result(1) := wide_character'Val(n rem 10 + 
               wide_character'Pos('0'));
            return result;
         end if;
      end Put;
      statement       : text;
      display_message : text;
      log_message     : text;
   begin
      if error_intro'Length > 0 then  -- a message to display
         -- Display the message and wait for the user to respond with
         -- okay.
         if the_error >= 0 then  -- (i.e. not negative)
            display_message := To_Text(
               Put(the_error) & ": " & error_intro &
               "  Message is '" & error_message & "'.  ") &
               for_log.message_terminate_text;
         else  -- user wants mssage displayed, but not the system error
            display_message := To_Text(error_intro);
         end if;
             -- Display the message in a dialogue box
         if for_log.error_display_callback /= null then  -- defined
            for_log.error_display_callback(Value(display_message));
         end if;
         statement := To_Text(" - Error: ");
      else  -- no message to display means just a message
         statement := To_Text(" - Message: ");  -- not an error?
      end if;
      log_message := To_Text("At " & To_String(Clock) & ", No. " &
         Put(abs the_error)) & statement & To_Text(error_message);
      if for_log.the_log = standard_error_file'Access then
         Log_Write_Lock.Lock;  -- in case this is called bya atask
         Put_Line(Standard_Error, To_String(log_message));
         Log_Write_Lock.Release;
      elsif for_log.the_log = standard_output_file'Access then
         Log_Write_Lock.Lock;  -- in case this is called bya atask
         Put_Line(Standard_Output, To_String(log_message));
         Log_Write_Lock.Release;
      else
         Log_Write_Lock.Lock;  -- in case this is called bya atask
         Put_Line(for_log.the_log.all, To_String(log_message));
         Flush(for_log.the_log.all);
         Log_Write_Lock.Release;
      end if;
   end Put;

   procedure Put(the_error : in integer;
                 error_intro, error_message : in wide_string) is
      -- using internal log file
   begin
      Put(the_error_log, the_error, error_intro, error_message);
   end Put;

   procedure Put(for_log : in out log_file;
                 error_exception : in wide_string) is
      -- Display a message for an otherwise untrapped error
      -- exception.
      use Ada.Command_Line;
      function Call_Stack(for_list:string_lists.list) return text is
         the_result : text;
         stack_list : string_lists.list;
      begin
         Assign(the_list => for_list, to => stack_list);
         Allow_Shallow_Copy(of_the_list => stack_list);
         First(in_the_list => stack_list);
         while not Is_End(of_the_list=>stack_list) loop
            if Length(the_result) > 0 then
               the_result := the_result & ',';
            end if;
            the_result := the_result &
               Deliver(from_the_list => stack_list);
            Next(in_the_list => stack_list);
         end loop;
         return the_result;
      end Call_Stack;
      procedure_name : text;
      procedure_list : text;
      error_message  : text;
   begin
      if String_Lists.
      Count(of_items_in_the_list=>for_log.procedure_stack) > 0
      then  -- get the last one
         Last(in_the_list =>for_log.procedure_stack);
         procedure_name :=
            Deliver(from_the_list=>for_log.procedure_stack);
         procedure_list :=
            Call_Stack(for_list=>for_log.procedure_stack);
      else  -- no procedure names pushed on stack
         procedure_name := To_Text("NONE");
      end if;
      Push_Stack(for_log, "Error_Log.Put");
      error_message := "Untrapped application error for " &
         To_Wide_String(Command_Name) & ": Exception '" & 
         error_exception &
         "' raised at procedure/function '" & 
         procedure_name & "'.";
      Put(for_log, the_error => 2,
         error_intro => "Untrapped Exception",
         error_message => To_String(error_message));
      Put(for_log, the_error => -3, error_intro => "",
         error_message => "Call stack: " & To_String(procedure_list));
      if for_log.email_allowed then  -- e-mail the log file to support
         Send_Email;
      end if;
   end Put;

   procedure Put_Error(error_exception : in wide_string) is
      -- using internal log file
   begin
      Put(the_error_log, error_exception);
   end Put_Error;

   -- Debug routines
   procedure Set_Debug_Level(for_log : in out log_file;
   to : in natural) is
   begin
      for_log.the_debug_level := to;
   end Set_Debug_Level;

   procedure Set_Debug_Level(to : in natural) is
      -- using internal log file
   begin
      Set_Debug_Level(the_error_log, to);
   end Set_Debug_Level;

   function Debug_Level(for_log : in log_file) return natural is
   begin
      return for_log.the_debug_level;
   end Debug_Level;

   function Debug_Level return natural is
      -- using internal log file
   begin
      return Debug_Level(the_error_log);
   end Debug_Level;

   procedure Debug_Data(in_log : in log_file;
                        at_level : in natural; with_details : in wide_string) is
   begin
      if in_log.the_debug_level >= at_level then
         Put(in_log, the_error => at_level, error_intro => "",
            error_message => with_details);
      end if;
   end Debug_Data;

   procedure Debug_Data(at_level : in natural;
                        with_details : in wide_string) is
      -- using internal log file
   begin
      Debug_Data(the_error_log, at_level, with_details);
   end Debug_Data;

   -- Stack routines for determining failure points that cannot
   -- otherwise be detected.
   procedure Push_Stack(for_log : in out log_file;
                        details : in wide_string) is
   begin
      Last(for_log.procedure_stack);
      Insert(into => for_log.procedure_stack,
         the_data => To_Text(details));
   end Push_Stack;

   procedure Push_Stack(details : in wide_string) is
      -- using internal log file
   begin
      Push_Stack(the_error_log, details);
   end Push_Stack;

   procedure Pop_Stack(for_log : in out log_file;
                       details : in wide_string) is
   begin
      if String_Lists.
      Count(of_items_in_the_list=>for_log.procedure_stack) > 0
      then
         Last(in_the_list => for_log.procedure_stack);
         Delete(from_the_list => for_log.procedure_stack);
      end if;
   end Pop_Stack;

   procedure Pop_Stack(details : in wide_string) is
      -- using internal log file
   begin
      Pop_Stack(the_error_log, details);
   end Pop_Stack;

   procedure Set_Email_Address(for_log : in out log_file;
   to : in wide_string) is
   begin
      for_log.email_address := To_Text(to);
   end Set_Email_Address;

   procedure Set_Email_Address(to : in wide_string) is
      -- using internal log file
   begin
      Set_Email_Address(the_error_log, to);
   end Set_Email_Address;

   procedure Set_Email(for_log : in out log_file;
   allowed : in boolean) is
   begin
      for_log.email_allowed := allowed;
   end Set_Email;

   procedure Set_Email(allowed : in boolean) is
      -- using internal log file
   begin
      Set_Email(the_error_log, allowed);
   end Set_Email;

   function Prevent_Email(for_log : in log_file) return boolean is
   begin
      return for_log.email_allowed;
   end Prevent_Email;

   procedure Send_Email is
     -- e-mail sending procedure.  This procedure is called if
     -- e-mailing is required.
   begin
      null;
   end Send_Email;

   function system_log return log_file is
   begin
      return the_error_log;
   end system_log;

begin
   null;
   -- standard_error_file  := Standard_Error;
   -- standard_output_file := Standard_Output;
end Error_Log;
