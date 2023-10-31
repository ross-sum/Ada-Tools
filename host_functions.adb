-----------------------------------------------------------------------
--                                                                   --
--                     H O S T _ F U N C T I O N S                   --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999, 2001, 2020  Hyper Quantum Pty Ltd.           --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a facility to launch another application  --
--  as a fork.                                                       --
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
with Ada.Exceptions;
-- with Ada.Interrupts, Ada.Interrupts.Names;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with GNAT.OS_Lib;                use GNAT.OS_Lib;
        -- provides the Errno function
with Interfaces.C;               use Interfaces.C;
with Interfaces.C.Strings;       use Interfaces.C.Strings;
        -- provides Strings.chars_ptr, char_array_access and To_Chars_Ptr
        -- as well as chars_ptr_array and Null_Ptr.
with Host_Functions_Thin;
with String_Functions;
with Ada.Unchecked_Deallocation;
with Ada.Wide_Text_IO;
-- with Error_Log;
package body Host_Functions is

   use Host_Functions_Thin;

   Default_Buffer_Size : constant := 16384;
   separator           : constant wide_character := ' ';
     -- System constants
   Host_Not_Found      : constant := 16#0001#;
   Try_Again           : constant := 16#0002#;
   File_Not_Found      : constant := 16#0002#;
   No_Recovery         : constant := 16#0003#;
   No_Address          : constant := 16#0004#;

   type String_Access is access string;
   type argument_array is array(positive range<>) of String_Access;

   procedure Free is
   new Ada.Unchecked_Deallocation (String, String_Access);

   procedure Free is
   new Ada.Unchecked_Deallocation (char_array, char_array_access);

   function Allocate (Size : Positive := Default_Buffer_Size)
   return char_array_access;
   --  Allocate a buffer

   procedure Raise_Error
   (err_no  : in integer;
   message  : in wide_string);
   -- Raise the exception Naming_Error with an appropriate error
   -- message.

   function Launch_Process(app_name: wide_string; args: argument_array)
   return boolean;
   function Launch_Process(app_name: wide_string; args: argument_array;
   envs : argument_array) return boolean;
   -- Launch a process and return false if failure.

   --------------
   -- Allocate --
   --------------

   function Allocate
   (Size : Positive := Default_Buffer_Size)
   return char_array_access
   is
   begin
      return new char_array (1 .. size_t (Size));
   end Allocate;

   --------------------
   -- Launch_Process --
   --------------------

   function Launch_Process(app_name: wide_string; args: argument_array)
   return boolean is
      name_buf  : chars_ptr := New_String(To_String(app_name));
      argv      : chars_ptr_array(size_t(args'First)-1..size_t(args'Last)+1);
      res       : int;
   begin
      argv(size_t(args'First)-1) := New_String(To_String(app_name));
      for item in args'Range loop
         argv(size_t(item)) := New_String(args(item).all);
      end loop;
      argv(size_t(args'Last)+1) := Null_Ptr;
      res := C_Execvp(name_buf, argv);
     -- Clean up what we can
      Free (name_buf);
      for item in args'First-1..args'Last+1 loop
         Free(argv(size_t(item)));
      end loop;
      return (res /= Failure);
   end Launch_Process;

   function Launch_Process(app_name: wide_string; args: argument_array;
   envs: argument_array) return boolean is
      name_buf  : chars_ptr := New_String(To_String(app_name));
      envp      :
      chars_ptr_array(size_t(envs'First)..size_t(envs'Last)+1);
      argv      :
      chars_ptr_array(size_t(args'First)..size_t(args'Last)+1);
      res       : int;
   begin
     -- load up the arrays and add a null pointer to the end
      for item in args'Range loop  -- arguments
         argv(size_t(item)) := New_String(args(item).all);
      end loop;
      argv(size_t(args'Last)+1) := Null_Ptr;
      for item in envs'Range loop  -- environment variables
         envp(size_t(item)) := New_String(envs(item).all);
      end loop;
      envp(size_t(envs'Last)+1) := Null_Ptr;
     -- do it
      res := C_Execve(name_buf, argv, envp);
     -- Clean up what we can
      Free (name_buf);
      for item in args'First..args'Last+1 loop
         Free(argv(size_t(item)));
      end loop;
      for item in envs'First..envs'Last+1 loop
         Free(envp(size_t(item)));
      end loop;
      return (res /= Failure);
   end Launch_Process;

   ------------------------
   -- Process Identifier --
   ------------------------

   function Process_ID return natural is
    -- return the process Identifier of the currently running process
   begin
      return natural(C_Get_Process_ID);
   end Process_ID;

   function Process_Exists(for_id : in natural) return boolean is
    -- Indicate whether the specified process ID is still running.
   begin
      return (C_Get_Process_GID(C.int(for_id)) >= 0);
   end Process_Exists;

   ---------------
   -- Host_Name --
   ---------------

   function Host_Name return Wide_String
   is
      Buff   : char_array_access  := Allocate;
      Buffer : constant chars_ptr := To_Chars_Ptr (Buff);
      Res    : constant int       := C_Gethostname (Buffer, Buff'Length);
   begin
      if Res = Failure then
         Free (Buff);
         Raise_Error (Errno, "");
      end if;
      declare
         Result : constant String := Value (Buffer);
      begin
         Free (Buff);
         return To_Wide_String(Result);
      end;
   end Host_Name;

   ------------------
   -- Current_User --
   ------------------

   function Current_User return Wide_String is
    -- Return the login name of the currently logged in user
      Buff   : char_array_access  := Allocate;
      Buffer : constant chars_ptr := To_Chars_Ptr (Buff);
      Res    : constant int       := C_Getlogin_r (Buffer, Buff'Length);
   begin
      if Res = Failure then
         Free (Buff);
         Raise_Error (Errno, "");
      end if;
      declare
         Result : constant String := Value (Buffer);
      begin
         Free (Buff);
         return To_Wide_String(Result);
      end;
   end Current_User;

   function Current_User_ID return natural is
    -- Return the login ID of the currently logged in user
   begin
      return natural(C_Get_E_UID);
   end Current_User_ID;
   
   ---------------------------
   -- Get_Environment_Value --
   ---------------------------

   function Get_Environment_Value(for_variable : wide_string)
    return wide_string is
    -- Return the environemnt variable value for the specified
    -- environment variable.
   -- Follows from: char *getenv(const char *name);
      Buffer : chars_ptr := New_String(To_String(for_variable));
      Res    : chars_ptr := C_GetEnv (Buffer);
   begin
      if Res /= Null_Ptr
      then  -- Some data to get
         declare
            Result : constant String := Value (Res);
         begin
            Free (Buffer);
            return To_Wide_String(Result);
         end;
      else  -- No data to get, return empty string
         Free (Buffer);
         return "";
      end if;
   end Get_Environment_Value;

   -------------
   -- Execute --
   -------------

   procedure Execute(app_name : wide_string; args : wide_string;
   envs : wide_string := "") is
      -- use String_Functions;
      function Convert_To_Array(the_string : in wide_string)
      return argument_array is
         str_len   : natural := the_string'Length;
         str_count : natural := 0;
      begin
         if str_len > 0 then
            for item in 1..str_len loop
               if the_string(item) = separator then
                  str_count := str_count + 1;
               end if;
            end loop;
            if str_count = 0 then str_count := 1; end if;
         end if;
         declare
            elements  : argument_array (1..str_count);
            str_num   : positive := 1;
            str_start : positive := 1;
         begin
            if str_count = 1 then
               elements(1) := new string'(To_String(the_string));
            else
               for item in 1 .. str_len loop
                  if the_string(item) = separator then
                     elements(str_num) := new string'(To_String(
                        the_string(str_start..item-1)));
                     str_start := item + 1;
                     str_num := str_num + 1;
                  end if;
               end loop;
            end if;
            return elements;
         end;
      end Convert_To_Array;
   
      success : boolean;
   begin
      -- fork ourselves
      if C_Fork = 0 then  -- we are the child
         -- Launch the process
         if envs'Length > 0 then
            success := Launch_Process(app_name,
               Convert_To_Array(args), Convert_To_Array(envs));
         else
            success := Launch_Process(app_name,
               Convert_To_Array(args));
         end if;
         if not success then
            Raise_Error(Errno, "");
         end if;
         -- else nothing to do as we are the parent - the child
         --      does the work.
      end if;
   
   end Execute;
   
   ---------------
   -- Daemonise --
   ---------------

   function Daemonise return integer is
    -- Daemonise the current application.
    -- It returns the process identifier if parent or 0 if child
    -- or 1 if an error.  If an error, an exception is raised.
      pid : integer;
   begin
      pid := integer(C_Fork);
      case pid is
         when -1 =>  -- something went wrong
            Raise_Error(Errno, "Daemonising Fork error");
            return 1;
         when 0 =>   -- we are the child. Close stdout, stdin, and stderr
         -- setsid()  -- become session leader
         -- chdir ("/");
         -- umask (0);
            return 0;
         when others =>  -- parent: just exit with the process ID.
            return pid;
      end case;
   end Daemonise;      

   -----------------
   -- Raise Error --
   -----------------

   procedure Raise_Error
   (err_no  : in integer;
   message  : in wide_string) is
   -- Raise the exception Naming_Error with an appropriate error
   -- message.
      function Error_Message return wide_string is
      begin
         case err_no is
            when Host_Not_Found =>
               return "Host not found";
            when Try_Again => -- | File_Not_Found =>
               return "File Not Found/Try again";
            when No_Recovery    =>
               return "No recovery";
            when No_Address     =>
               return "No address";
            when others         =>
               return "Unknown error " & 
                  To_Wide_String(Integer'Image(err_no));
         end case;
      end Error_Message;
   begin
      Ada.Exceptions.Raise_Exception(Naming_Error'Identity,
         To_String(Error_Message) & ": " & To_String(message));
   end Raise_Error;

   -----------------------
   -- OS Signal Handler --
   -----------------------
   procedure Check_Reservation(attached, installed : out boolean) is
      use Ada.Interrupts, Ada.Interrupts.Names;
      
   begin
      attached  := Is_Reserved( SIGTERM );
      installed := Is_Attached( SIGTERM );
   end Check_Reservation;
   
   procedure Check_Reservation is
      attached, installed: boolean;
   begin
      Check_Reservation(attached, installed);
      if attached then
         Ada.Wide_Text_IO.Put_Line( "The SIGTERM handler is reserved" );
      else
         Ada.Wide_Text_IO.Put_Line( "The SIGTERM handler isn't reserved" );
      end if;
      if installed then
         Ada.Wide_Text_IO.Put_Line( "There is a SIGTERM handler installed" );
      else
         Ada.Wide_Text_IO.Put_Line( "There is no SIGTERM handler installed" );
      end if;
   end Check_Reservation;
      
   function Told_To_Die return boolean is
    -- Indicate if the task has received a SIGTERM message already
   begin
      return OS_Signal_Handler.Are_We_Dead_Yet;
   end Told_To_Die;

   function Got_User_Signal return boolean is
    -- Indicate if the task has received a SIGUSR1 message already
   begin
      return OS_Signal_Handler.User_Sig_Trapped;
   end Got_User_Signal;
    
   -- protected OS_Signal_Handler is
   --    procedure Response;
   --   pragma Attach_Handler(Response, Ada.Interrupts.Names.SIGTERM);
   -- end;
   
   protected body OS_Signal_Handler is
      procedure SigTERM_Response is
      begin
         -- Ada.Wide_Text_IO.Put_Line( "SIGTERM received");
         sig_term_received := true;
         raise Terminate_Application;
      end SigTERM_Response;
      procedure SigUSR1_Response is
      begin
         sig_user_received := true;
      end SigUSR1_Response;
      function Are_We_Dead_Yet return boolean is
      begin
         return sig_term_received;
      end Are_We_Dead_Yet;
      function User_Sig_Trapped return boolean is
      begin
         return sig_user_received;
      end User_Sig_Trapped;
     -- private
     --  sig_term_received : boolean := false;
     --  sig_user_received : boolean := false;
   end OS_Signal_Handler;

begin
   null;
end Host_Functions;
