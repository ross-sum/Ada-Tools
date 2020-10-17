-----------------------------------------------------------------------
--                                                                   --
--                           I N T E R L O C K S                     --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides two protected types to act as interlocks.  --
--  The  first type is a general type for general interlocks.   The  --
--  Second type is for interlocks where the status of the interlock  --
--  needs  to  be monitored, such as with  application  termination  --
--  interlocks.                                                      --
--                                                                   --
--  Version History:                                                 --
--  $Log$                                                            --
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

package Interlocks is

   protected type Interlock is
      entry Lock;
      procedure Release;
   private
      is_locked : boolean := false;
   end Interlock;
   type interlock_access is access all Interlock;

   type termination_states is (waiting, terminated);
   protected type Termination_Flags is
      procedure Set(terminate_to : termination_states);
      function The_Termination_Status return termination_states;
      procedure Signal;
      entry Wait;
   private
      termination_flag : termination_states := waiting;
   end Termination_Flags;

end Interlocks;