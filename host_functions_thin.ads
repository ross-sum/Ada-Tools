-----------------------------------------------------------------------
--                                                                   --
--                  H O S T _ F U N C T I O N S _ T H I N            --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package is a thin interface to the host system to          --
--  facilitate launching another application.  It is principally     --
--  used by the host functions package.                              --
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

with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
-- stdlib.h
package Host_Functions_Thin is

   package C renames Interfaces.C;
   package Strings renames C.Strings;
   generic package Pointers renames C.Pointers;

   use type C.int;
--  This is an ugly hack to be able to declare the Failure constant
--  below.

   Success : constant C.int :=  0;
   Failure : constant C.int := -1;

   function C_Gethostname
   (Name    : Strings.chars_ptr;
   Namelen  : C.int)
   return C.int;

   function C_Gethostname
   (Name    : System.Address;
   Namelen  : C.int)
   return C.int;

   function C_Execve
   (filename : Strings.chars_ptr;
   argv      : Strings.chars_ptr_array;
   envp      : Strings.chars_ptr_array)
   return C.int;
     -- filename is the full path to the executable (or script)
     -- argv is an array of parameter strings
     -- envp is an array of environment variables of the form key=value
     -- Both argv and envp must be terminated by a null pointer.
     -- If the function is successful, it does not return,
     -- otherwise it returns -1 and sets the error code in errno.

   function C_Execvp
   (filename : Strings.chars_ptr;
   argv      : Strings.chars_ptr_array)
   return C.int;
     -- filename is the executable (or script) with or without a path.
     -- If the path is not specified, then the $PATH environment
     -- variable is used to search for filename.
     -- argv is an array of parameter strings.
     -- argv must be terminated by a null pointer.
     -- If the function is successful, it does not return,
     -- otherwise it returns -1 and sets the error code in errno.

   function C_Execlp
   (filename : Strings.chars_ptr;
   arg0 : Strings.chars_ptr; nullptr : C.int := 0)
   return C.int;
     -- Execute the specified filename, searching the $PATH environment
     -- variable for it if not specified.
     -- If the function is successful, it does not return,
     -- otherwise it returns -1 and sets the error code in errno.

   function C_Fork return C.int;
   -- Fork the current process and start execution at the return
   -- of the fork.  The parent process gets the return value of
   -- the child's process, whereas the child process gets a return
   -- value of 0 (no process ID, since it is the child).

   function C_GetEnv(env : Strings.chars_ptr) return Strings.chars_ptr;
   -- return the environment varlable string for the
   -- specified environment variable.
   -- Follows from: char *getenv(const char *name);
   -- This returns a pointer to the environment variable if it is found,
   -- otherwise it returns a null pointer.

private

pragma Import (C, C_Gethostname, "gethostname");
pragma Import (C, C_Execve,      "execve");
pragma Import (C, C_Execvp,      "execvp");
pragma Import (C, C_Execlp,      "execlp");
pragma Import (C, C_Fork,        "fork");
pragma Import (C, C_GetEnv,      "getenv");

end Host_Functions_Thin;
