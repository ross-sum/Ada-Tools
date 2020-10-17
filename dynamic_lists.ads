-----------------------------------------------------------------------
--                                                                   --
--                       D Y N A M I C _ L I S T S                   --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a list capability for any specified type  --
--  T.                                                               --
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
with Ada.Finalization, Unchecked_Deallocation;
use  Ada.Finalization;
with General_Storage_Pool;  -- Caution: This method can be slow!!!
generic
type T is private;  -- any type for the list
storage_size : General_Storage_Pool.Storage_Count := 524288;

package Dynamic_Lists is

   type list is new Controlled with private;
   type list_node is private;

   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   procedure Initialize (the_list : in out list );
   procedure Initialise (the_list : in out list; with_data: in T);
   procedure Finalize ( the_list : in out list );
   procedure Adjust ( the_list : in out list);

   function "=" ( f : in list; s : in list ) return boolean;

   procedure Clear(the_list : in out list);

   procedure Assign(the_list : in list; to : in out list);
     -- perform a shallow copy of the list (i.e. point one list
     -- to the other).
     
    -- The following two routines provide the ability to save away
    -- the current pointer handle for a list for later use, then
    -- to use that pointer handle at that later time.
   function Handle(to_current_list : in list) return list_node;
     -- return a handle to the current node pointed to in the
     -- list.  If there is no current node pointed to, then
     -- the handle is set to the first item in the list.
   procedure Go_To(the_handle : in list_node; for_the_list : in out list);
     -- Set the list pointer to the requested handle point for
     -- the specified list.

   procedure First   (in_the_list : in out list);
     -- Set the pointers in the list to the first object in
     -- the list.
   procedure Last    (in_the_list : in out list);
     -- Set the pointers in the list to the last object in
     -- the list.
   procedure Next    (in_the_list : in out list);
     -- Move the list pointer to the next item in the list.  If the
     -- list pointer is not currently pointing at an item, the
     -- list pointer is unmodified.
   procedure Previous(in_the_list : in out list);
     -- Move the list pointer to the previou item in the list.  If
     -- the list pointer is not currently pointing at an item, the
     -- list pointer is unmodified.
   function  Is_End  (of_the_list : in list) return boolean;
     -- Return true when the list pointer is moved beyond the end of
     -- the list, or beyond the start of the list.

   function  Deliver (from_the_list : in list) return T;
     -- Return a copy of the current item pointed to by the
     -- iterator.
   procedure Insert  (into : in out list; the_data : in T );
   procedure Delete  (from_the_list : in out list);
   procedure Replace (the_data : in T; for_the_list: in out list);

    -- The following two procedures set and reset the assignment
    -- switch to allow or disallow a shallow copy of the list
    -- on assignment.  You would want to allow a shallow copy
    -- when assigning a list to a list or inserting a list in a
    -- list.

   procedure Allow_Shallow_Copy(of_the_list : in out list);

   procedure Disallow_Shallow_Copy(of_the_list : in out list);

   function Count(of_items_in_the_list : in list) return natural;

   function Pool_Usage  return wide_string;
		-- storage pool usage as a block representation.

private

   type counter is range 0..long_integer'Last;

   procedure Release_Storage ( for_the_list : in out list );

	-- set up the storage pool
   the_pool : General_Storage_Pool.general_pool
   (size => storage_size,
   start_monitoring_state => General_Storage_Pool.unmonitored);

   type node;  -- tentative declaration
   type list_node is access all node;  -- pointer to the node
pragma Controlled(list_node);
   type node is record
         prev : list_node;   -- previous node
         item : T;           -- the physical item
         next : list_node;   -- next node
      end record;
   for list_node'Storage_Pool use the_pool;

   procedure Dispose_Node is
   new Unchecked_Deallocation(node, list_node);

   type list is new Controlled with record
         first_node   : aliased list_node := null;  -- first item
         last_node    : aliased list_node := null;  -- Last item
         current_node : aliased list_node := null;
         deep_copy    : boolean := true;
         item_count   : counter := 0;
      end record;

end Dynamic_Lists;
