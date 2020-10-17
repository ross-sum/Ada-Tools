-----------------------------------------------------------------------
--                                                                   --
--                     H O S T _ F U N C T I O N S                   --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001,2020  Hyper Quantum Pty Ltd.             --
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

with Ada.Interrupts, Ada.Interrupts.Names;
package Host_Functions is

   Naming_Error : exception;
   -- This exception is raised when the name cannot be determined.
   
   Terminate_Application : exception;
   -- This exception is raised when a SIGTERM is received by the 
   -- application.

   function Host_Name return Wide_String;
    --  Return the name of the current host

   procedure Execute(app_name : wide_string; args : wide_string;
   envs : wide_string := "");
    -- Execute the specified application name.
    -- The arguments are space (" ") separated.
    -- The environment variables are also space separated.
    -- If the environment variables are specified, then the
    -- application name must be the full path to the application.
    -- Otherwise (when environment variables are left at ""), the
    -- PATH environment variable will be searched for the app_name
    -- if the app_name does not specify a path to the application.

   function Daemonise return integer;
    -- Daemonise the current application.
    -- It returns the process identifier if parent or 0 if child
    -- or 1 if an error.  If an error, an exception is raised.
    -- Usage: if Daemonise = 0 then Do_Child_Functions;
    --        else Exit_Gracefully; end if;
  
   function Told_To_Die return boolean;
    -- Indicate if the task has received a SIGTERM message already
   function Got_User_Signal return boolean;
    -- Indicate if the task has received a SIGUSR1 message already
    
   procedure Check_Reservation(attached, installed : out boolean);
    -- This procedure is for debugging purposes.  It verifies that the
    -- SIGTERM signal is available to this package and that it is indeed
    -- assigned to the private protected signal handler below.
   procedure Check_Reservation;
   -- As above but print the results to standard out.
      
private
   use Ada.Interrupts, Ada.Interrupts.Names;
    -----------------------
    -- OS Signal Handler --
    -----------------------   
   protected OS_Signal_Handler is
      procedure SigTERM_Response;
      pragma Attach_Handler(SigTERM_Response, SIGTERM);
      procedure SigUSR1_Response;
      pragma Attach_Handler(SigUSR1_Response, SIGUSR1);
      function Are_We_Dead_Yet return boolean;
      function User_Sig_Trapped return boolean;
     private
      sig_term_received : boolean := false;
      sig_user_received : boolean := false;
   end;

end Host_Functions;
