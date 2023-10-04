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
-- with Ada.Finalization, Unchecked_Deallocation;
-- use  Ada.Finalization;
--@ with Ada.Wide_Text_IO;

-- generic
-- type T is private;  -- any type for the list

package body Generic_Binary_Trees is

   -- type list is new Controlled with private;
   --
   -- private
   --
   --    type node;  -- tentative declaration
   --    type handle is access all node;  -- pointer to the node
   --    type node is record
     --          prev : handle;   -- previous node
   --          item : T;           -- the physical item
   --          next : handle;   -- next node
   --          left : handle;   -- node down the left of the tree
   --          right: handle;   -- node down the right of the tree
   --       end record;
   --
   --    procedure Dispose_Node is
   --    new Unchecked_Deallocation(node, handle);
   --
   --    type list is new Controlled with record
   --          root_node    : aliased handle := null; -- tree top
   --          first_node   : aliased handle := null; -- first item
   --          last_node    : aliased handle := null; -- Last item
   --          current_node : aliased handle := null;
   --          deep_copy    : boolean := true;
   --          item_count   : counter := 0;
   --       end record;


   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   procedure Initialize (the_list : in out list ) is
   begin
      the_list.first_node   := null;  -- empty list
      the_list.last_node    := null;  -- empty list
      the_list.current_node := null;  -- empty list
      the_list.root_node    := null;  -- empty list
      the_list.item_count   := 0;
   end Initialize;

   procedure Initialise (the_list : in out list; with_data: in T) is
   begin
      the_list.first_node   :=
         new node'(null, with_data, null, null, null);
      the_list.last_node    := the_list.first_node;
      the_list.current_node := the_list.first_node;
      the_list.root_node    := the_list.first_node;
      the_list.item_count   := 0;
   end Initialise;

   procedure Finalize ( the_list : in out list ) is
   begin
      if the_list.deep_copy then  -- only clean up when in
         Clear(the_list);         -- a deep copy situation
      end if;
   end Finalize;

   procedure Adjust ( the_list : in out list) is
      current : handle := the_list.first_node; -- original list
      last    : handle := null;      -- last created node
      previous: handle := null;      -- previously created node
      first   : handle := null;      -- the first node
   begin
      if not the_list.deep_copy then
         return;  -- only stick around in a deep copy situation
      end if;
      while current /= null loop
         last := new node'(previous, current.item,null,null,null);
         if first = null then first := last; end if;
         if previous /= null then previous.next := last; end if;
         previous := last;
         current := current.next;     -- Next node
      end loop;
      the_list.first_node   := first;   -- Update
      the_list.last_node    := last;
      the_list.current_node := first;
   end Adjust;

   procedure Clear(the_list : in out list) is
   begin
      if the_list.first_node /= null then
         Release_Storage(the_list);
         the_list.first_node   := null;
         the_list.current_node := null;
         the_list.root_node    := null;
         the_list.item_count   := 0;
      end if;
   end Clear;

   procedure Assign(the_list : in list; to : in out list) is
     -- perform a shallow copy of the list (i.e. point one list
     -- to the other).
   begin
      to.deep_copy    := false;  -- don't allow it at the moment
      to.root_node    := the_list.root_node;
      to.first_node   := the_list.first_node;
      to.last_node    := the_list.last_node;
      to.current_node := the_list.current_node;
      to.item_count   := the_list.item_count;
      to.deep_copy    := true;  -- switch it back on
   end Assign;

   procedure Release_Storage ( for_the_list : in out list ) is
      current  : handle := for_the_list.first_node;
      -- pointer to the current node
      old_node : handle;  -- Node to dispose of
   begin
      while current /= null loop  -- For each item in the list
         old_node := current;      -- Item to dispose
         current  := current.next; -- Next node
         Dispose_Node(old_node);   -- Dispose of item
      end loop;
   end Release_Storage;

   procedure Top (of_the_list : in out list) is
   -- go to the top of the list (i.e. to the first item entered
   -- into the list).
   begin
      of_the_list.current_node := of_the_list.root_node;
   end Top;

   procedure First   (in_the_list : in out list) is
   -- Set the pointers in the list to the first object in
   -- the list.
   begin
      in_the_list.current_node := in_the_list.first_node;
        -- set to 1st
   end First;

   procedure Last    (in_the_list : in out list) is
   -- Set the pointers in the list to the last object in
   -- the list.
   begin
      in_the_list.current_node := in_the_list.last_node;
        -- set to last
   end Last;

   procedure Next    (in_the_list : in out list) is
   -- Move the list pointer to the next item in the list.  If the
   -- list pointer is not currently pointing at an item, the
   -- list pointer is unmodified.  This is a sequential move.
   begin
      if in_the_list.current_node /= null then
         in_the_list.current_node :=
            in_the_list.current_node.next;  -- Next
      end if;
   end Next;

   procedure Previous(in_the_list : in out list) is
      -- Move the list pointer to the previou item in the list.  If
      -- the list pointer is not currently pointing at an item, the
      -- list pointer is unmodified.
      -- The end of the list is indicated by the pointer pointing
      -- to a null value.  By inspecting the list, this case can
      -- be distinguished from the case of an empty list.
   begin
      if in_the_list.current_node /= null then
         in_the_list.current_node :=
            in_the_list.current_node.prev;  -- Previous
      end if;
   end Previous;

   function  Is_End  (of_the_list : in list) return boolean is
      -- Return true when the lsit pointer is moved beyond the end
      -- of the list, or beyond the start of the list.
   begin
      return of_the_list.current_node = null;  -- true if end
   end Is_End;

   function Is_Empty (for_the_list : in list) return boolean is
     -- Return true when the list is empty (has no entries).
   begin
      return for_the_list.root_node = null;
   end Is_Empty;

   function Depth(of_the_list : in list) return natural is
     -- Return the number of nodes down the tree at its deepest
     -- point.
      function Depth(of_tree : in handle) return natural is
      begin
         if of_tree = null then
            return 0;
         else
            return 1 + Natural'Max(Depth(of_tree.left),
               Depth(of_tree.right));
         end if;
      end Depth;  -- of_tree handle
   begin
      if of_the_list.root_node = null then
         return 0;
      else
         return Depth(of_the_list.root_node);
      end if;
   end Depth;

   function The_List_Contains (the_item:in T; in_the_list:in list)
   return boolean is
      -- Return true if the specified item is in the list, otherwise
      -- return false.
      current_node : aliased handle := in_the_list.root_node;
   begin
      while current_node /= null loop
         if current_node.item = the_item then  -- found it
            return true;
         else
            if the_item < current_node.item then
               current_node := current_node.left;
            else
               current_node := current_node.right;
            end if;
         end if;
      end loop;
      return false;  -- did not find it if we got here
   end The_List_Contains;

   procedure Find (the_item : in T; in_the_list : in out list) is
      -- Find the designated item in the list.  The list will move
      -- to the last item if it is not present.  The process used here
      -- is the same as for The_List_Contains function, but the list
      -- pointer is actually moved.
   begin
      Top(of_the_list => in_the_list);
      while not Is_End(of_the_list => in_the_list) and then
      Deliver(from_the_list => in_the_list) /= the_item loop
         if the_item < Deliver(from_the_list => in_the_list)
         then
            in_the_list.current_node :=
               in_the_list.current_node.left;
         else
            in_the_list.current_node :=
               in_the_list.current_node.right;
         end if;
      end loop;
   end Find;

   function  Deliver (from_the_list : in list) return T is
   -- Return a copy of the current item pointed to by the
   -- iterator.
   begin
      return from_the_list.current_node.item;  -- current item
   end Deliver;

   procedure Insert  (into : in out list; the_data : in T ) is
      -- This inserts the item in the list at the appropriate
      -- point down the tree.  It traverses the tree from the
      -- top until it finds an empty node.  It loads itself
      -- into this point.
      -- The exception is the root node, which it will insert
      -- itself into if this node is empty.
      -- It ensures the pointers are appropriately updated.
      -- First points to the least (minimum) and Last points
      -- to the most (maximum).
      current  : handle := into.root_node;
      present  : handle := null;
      new_node : handle;
      first    : handle renames into.first_node;
      last     : handle renames into.last_node;
      on_first,
      on_last  : boolean := true;  -- assumption to prove wrong
   begin
      new_node := new Node'(null, the_data, null, null, null);
      if current = null then -- Empty list
         first := new_node;
         last  := new_node;
         into.current_node := new_node;
         into.root_node := new_node;
      else -- Have data, so find its order in the list
         while current /= null loop
            present := current;
            if the_data < current.all.item then
               current := current.left;
               on_last := false;   -- not down the last item here
            else
               current := current.right;
               on_first := false;  -- not down the first itm here
            end if;
         end loop;
             -- adjust first or last pointers if necessary
         if on_first then
            first := new_node;
         elsif on_last then
            last  := new_node;
         end if;
             -- insert the data into the right part of the tree
         if the_data < present.all.item then
            new_node.prev := present.prev;
            new_node.next := present;
            if present.prev /= null and then
            present.prev.next /= new_node then
               present.prev.next := new_node;
            end if;
            present.prev  := new_node;
            present.left  := new_node;
         else
            new_node.prev := present;
            new_node.next := present.next;
            present.next  := new_node;
            present.right := new_node;
         end if;
      end if;
      into.item_count := into.item_count + 1;
   end Insert;

   procedure Delete  (from_the_list : in out list) is
      -- There are four different pointers to fix: the forward
      -- pointer and the previous pointer, the left pointer and
      -- the right pointer.  Each of these cases leads to further
      -- options depending on whether the object deleted is the
      -- first, last or middle object in the list.
      current: handle := from_the_list.current_node; -- current
      first  : handle renames from_the_list.first_node;
      last   : handle renames from_the_list.last_node;
      tree_walker : handle;  -- used to walk the tree
   begin
      if current /= null then  -- something to delete
         -- Fix up the prev and next pointers to not refer to the
         -- current node.
         if current.prev /= null then  -- Fix forward pointer:
            current.prev.next := current.next;  -- Not first in chain
         else
            first := current.next;  -- First in chain
            if first = null then
               last := null;   -- Empty list
            end if;
         end if; -- else for current.prev /= null
         if current.next /= null then  -- Fix backward pointer:
            current.next.prev := current.prev;  -- Not last in chain
         else
            last := current.prev;   -- Last in chain
            if last = null then
               first := null;  -- Empty list
            end if;
         end if;  -- else for current.next /= null
             -- Point the current_node at a value that will still exist
         if current.next /= null then  -- Fix current pointer:
            from_the_list.current_node := current.next;  -- next
         elsif current.prev /= null then
            from_the_list.current_node := current.prev; -- previous
         else
            from_the_list.current_node := null;  -- empty list
         end if;  -- elses for current.next /= null
             -- Fix up the left and right pointers of the current
             -- node to bypass the current node.
         if current.right /= null then  -- Fix >= pointer
            -- put right pointer under left's right most arm
            if current.left /= null then
               tree_walker := current.left;
               while tree_walker.right /= null loop
                  tree_walker := tree_walker.right;
               end loop;
               tree_walker.right := current.right;
            else  -- no left arm - put under parent's arm
               tree_walker := from_the_list.root_node;
               while tree_walker /= null and then
               (tree_walker.left /= current and
               tree_walker.right /= current )loop
                  if current.item < tree_walker.item then
                     tree_walker := tree_walker.left;
                  else
                     tree_walker := tree_walker.right;
                  end if;
               end loop;
               if tree_walker /= null then
                  if tree_walker.left = current then
                     tree_walker.left := current.right;
                  else
                     tree_walker.right := current.right;
                  end if;
               end if;
            end if;
         end if;
         if current.left /= null then  -- Fix < pointer
            -- Find the parent node, then link it's left into
            -- this node's left arm
            tree_walker := from_the_list.root_node;
            while tree_walker /= null and then
            (tree_walker.left /= current and
            tree_walker.right /= current )loop
               if current.item < tree_walker.item then
                  tree_walker := tree_walker.left;
               else
                  tree_walker := tree_walker.right;
               end if;
            end loop;
            if tree_walker /= null then
               if tree_walker.left = current then
                  tree_walker.left := current.left;
               else
                  tree_walker.right := current.left;
               end if;
            end if;
         end if;
         if current.left = null and current.right = null then
            -- we are at a child node, so null the parent
            tree_walker := from_the_list.root_node;
            while tree_walker /= null and then
            (tree_walker.left /= current and
            tree_walker.right /= current )loop
               if current.item < tree_walker.item then
                  tree_walker := tree_walker.left;
               else
                  tree_walker := tree_walker.right;
               end if;
            end loop;
            if tree_walker /= null then
               if tree_walker.left = current then
                  tree_walker.left := null;
               else
                  tree_walker.right := null;
               end if;
            end if;
         end if;
         if current = from_the_list.root_node then
            from_the_list.root_node    := null;
            from_the_list.first_node   := null;
            from_the_list.last_node    := null;
            from_the_list.current_node := null;
         end if;
         Dispose_Node(current);  -- Release storage
         from_the_list.item_count := from_the_list.item_count - 1;
      end if;  -- current /= null (something to delete)
   end Delete;

   procedure Replace (the_data : in T; for_the_list: in out list) is
      the_list : list := for_the_list;
   begin
      if the_list.current_node /= null then  -- exists, remove it
         Delete(from_the_list => the_list);
      -- else nothing to replace - just insert
      end if;  -- current /= null (something to replace)
      Insert(into => for_the_list, the_data => the_data);
   end Replace;


   -- The following two procedures set and reset the assignment
   -- switch to allow or disallow a shallow copy of the list
   -- on assignment.  You would want to allow a shallow copy
   -- when assigning a list to a list or inserting a list in a
   -- list.

   procedure Allow_Shallow_Copy(of_the_list : in out list) is
   begin
      of_the_list.deep_copy := false;
   end Allow_Shallow_Copy;

   procedure Disallow_Shallow_Copy(of_the_list : in out list) is
   begin
      of_the_list.deep_copy := true;
   end Disallow_Shallow_Copy;

   function Count(of_items_in_the_list : in list) return natural is
   begin
      return natural(of_items_in_the_list.item_count);
   end Count;

end Generic_Binary_Trees;
