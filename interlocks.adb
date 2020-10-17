-----------------------------------------------------------------------
--                                                                   --
--                           I N T E R L O C K S                     --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  body  provides two  protected types  to  act  as  --
--  interlocks.   The  first  type is a general  type  for  general  --
--  interlocks.  The Second type is for interlocks where the status  --
--  of   the  interlock  needs  to  be  monitored,  such  as   with  --
--  application termination interlocks.                              --
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

package body Interlocks is
   -- type termination_states is (waiting, terminiated);

   protected body Interlock is
      -- private
      --    is_locked : boolean := false;
      entry Lock when not is_locked is
      begin
         is_locked := true;
      end Lock;
      procedure Release is
      begin
         is_locked := false;
      end Release;
   end Interlock;

   protected body Termination_Flags is
      -- private
      --    termination_flag : termination_states := waiting;
      procedure Set(terminate_to : termination_states) is
      begin
         termination_flag := terminate_to;
      end Set;
      function The_Termination_Status return termination_states is
      begin
         return termination_flag;
      end The_Termination_Status;
      procedure Signal is
      begin
         termination_flag := terminated;
      end Signal;
      entry Wait when termination_flag = terminated is
      begin
         termination_flag := waiting;
      end Wait;
   end Termination_Flags;

begin
   null;
end Interlocks;