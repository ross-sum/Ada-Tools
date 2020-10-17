-----------------------------------------------------------------------
--                                                                   --
--               G E N E R I C _ B I N A R Y _ T R E E S             --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a binary tree facility for any specified  --
--  type T. As well as being able to move through the tree in sorted --
--  order, a find function is provided for a fully defined key.      --
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

   generic
   type T is private;  -- any type for the list
   with function "<" (X, Y: T) return Boolean is <>;

   package Generic_Binary_Trees is

      type list is new Controlled with private;

      -- Initialisation and finalisation is exposed here so that
      -- descendent components can call the inherited operation
      -- as a part of their initialisation and finalisation.
      procedure Initialize (the_list : in out list );
      procedure Initialise (the_list : in out list; with_data: in T);
      procedure Finalize ( the_list : in out list );
      procedure Adjust ( the_list : in out list);
      procedure Clear(the_list : in out list);

      procedure Assign(the_list : in list; to : in out list);
        -- perform a shallow copy of the list (i.e. point one list
        -- to the other).

      procedure Top (of_the_list : in out list);
      -- go to the top of the list (i.e. to the first item entered
      -- into the list).
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
      function Is_Empty (for_the_list : in list) return boolean;
      -- Return true when the list is empty (has no entries).
      function Depth(of_the_list : in list) return natural;
      -- Return the number of nodes down the tree at its deepest
      -- point.

      function The_List_Contains (the_item:in T; in_the_list:in list)
      return boolean;
      -- Return true if the specified item is in the list, otherwise
      -- return false.

      procedure Find (the_item : in T; in_the_list : in out list);
      -- Find the designated item in the list.  The list will move
      -- to the last item if it is not present.

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

   private

      type counter is range 0..long_integer'Last;

      procedure Release_Storage ( for_the_list : in out list );

      type node;  -- tentative declaration
      type handle is access all node;  -- pointer to the node
      type node is record
            prev : handle;   -- previous node
            item : T;           -- the physical item
            next : handle;   -- next node
            left : handle;   -- node down the left (<) of the tree
            right: handle;   -- node down the right (>) of the tree
         end record;

      procedure Dispose_Node is
      new Unchecked_Deallocation(node, handle);

      type list is new Controlled with record
            root_node    : aliased handle := null;  -- top of tree
            first_node   : aliased handle := null;  -- first item
            last_node    : aliased handle := null;  -- Last item
            current_node : aliased handle := null;
            deep_copy    : boolean := true;
            item_count   : counter := 0;
         end record;

   end Generic_Binary_Trees;
