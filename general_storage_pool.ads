-----------------------------------------------------------------------
--                                                                   --
--             G E N E R A L _ S T O R A G E _ P O O L S             --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 2003  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a storage pool capability for any type    --
--  of access type.  The structure is based on that provided by      --
--  John Barnes in his book "Programming in Ada95, with some         --
--  modifications made to increase the performance of the pool.      --
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
with System.Storage_Pools;     use System.Storage_Pools;
with System.Storage_Elements;  use System.Storage_Elements;
use System;
package General_Storage_Pool is

   Pool_Error : exception;

   subtype Storage_Count is System.Storage_Elements.Storage_Count;

   type monitoring_states is (monitored, unmonitored);
	-- Default monitoring state is unmonitored.  The internal
	-- value is kept inside a global variable in this unit.
	-- The easiest way to set it at the start is when declaring
	-- the following type.  It may be switched on or off at any
	-- time, but statistics will only be kept when it is switched
	-- on.
   type general_pool(size : Storage_Count;
   start_monitoring_state : monitoring_states) is
   new Root_Storage_Pool with private;
	-- size is the amount of storage space to allocate to
	-- the storage object.  If the pool usage is generally large,
	-- this should be equally large.
	-- Pool_Error will be raised if it is exceeded.
	-- Note that start_monitoring_state will override any other
	-- setting of this value including that by any variable
	-- previously declared.

   procedure Allocate(pool : in out general_pool;
   storage_address : out address;
   SISE : in storage_count;
   align : in storage_count);

   procedure Deallocate(pool : in out general_pool;
   storage_address : in address;
   SISE : in storage_count;
   align : in storage_count);

   function Storage_Size(pool : in general_pool)
   return storage_count;

   procedure Set_Monitoring(to : in monitoring_states);
   function Monitoring_State return monitoring_states;
   function Pool_Usage (pool : in general_pool) return wide_string;

   procedure Initialize(pool : in out general_pool);
   procedure Finalize(pool   : in out general_pool);

private

   type integer_array is array(storage_count range <>)of integer;
   type boolean_array is array(storage_count range <>)of boolean;
   type general_pool(size : Storage_Count;
   start_monitoring_state : monitoring_states) is
   new Root_Storage_Pool with record
         free  : storage_count;
         count : integer_array(1..size);
         used  : boolean_array(1..size);
         store : storage_array(1..size);
         block_size      : storage_count; -- reserved for future use
         first_available : storage_offset := 1;
      end record;

end General_Storage_Pool;