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
-- with Ada.Finalization, Unchecked_Deallocation;
-- use  Ada.Finalization;
-- generic
--   type T is private;  -- any type for the list
--@ with Ada.Text_IO;

package body Dynamic_Lists is

   -- type list is new Controlled with private;

   procedure Initialize ( the_list : in out list ) is
   begin
      the_list.first_node   := null;  -- empty list
      the_list.last_node    := null;  -- empty list
      the_list.current_node := null;  -- empty list
      the_list.item_count   := 0;
   end Initialize;

   procedure Initialise (the_list : in out list; with_data : in T) is
   begin
      the_list.first_node   := new node'(null, with_data, null);
      the_list.last_node    := the_list.first_node;
      the_list.current_node := the_list.first_node;
      the_list.item_count   := 0;
   end Initialise;

   procedure Finalize ( the_list : in out list ) is
   begin
      if the_list.deep_copy then  -- only clean up when in
         Clear(the_list);         -- a deep copy situation
      end if;
   end Finalize;

   procedure Clear(the_list : in out list) is
   begin
      if the_list.first_node /= null then
         Release_Storage(the_list);
         the_list.first_node   := null;
         the_list.current_node := null;
         the_list.item_count   := 0;
      end if;
   end Clear;

   procedure Adjust ( the_list : in out list) is
      current : list_node := the_list.first_node; -- original list
      last    : list_node := null;      -- last created node
      previous: list_node := null;      -- previously created node
      first   : list_node := null;      -- the first node
   begin
      if not the_list.deep_copy then
         return;  -- only stick around in a deep copy situation
      end if;
      while current /= null loop
         last := new node'(previous, current.item, null);
         if first = null then first := last; end if;
         if previous /= null then previous.next := last; end if;
         previous := last;
         current := current.next;     -- Next node
      end loop;
      the_list.first_node   := first;   -- Update
      the_list.last_node    := last;
      the_list.current_node := first;
   end Adjust;

   procedure Assign(the_list : in list; to : in out list) is
      -- perform a shallow copy of the list (i.e. point one list
      -- to the other).
   begin
      to.deep_copy    := false;  -- don't allow it at the moment
      to.first_node   := the_list.first_node;
      to.last_node    := the_list.last_node;
      to.current_node := the_list.current_node;
      to.deep_copy    := true;  -- switch it back on
   end Assign;

   function "=" ( f : in list; s : in list ) return boolean is
      f_node : list_node := f.first_node;  -- first list
      s_node : list_node := s.first_node;  -- second list
   begin
      while f_node /= null and s_node /= null loop
         if f_node.item /= s_node.item then
            return false;        -- Different items
         end if;
         f_node := f_node.next;
         s_node := s_node.next;
      end loop;
      return f_node = s_node;  -- Both null if equal
   end "=";

   procedure Release_Storage ( for_the_list : in out list ) is
      current  : list_node := for_the_list.first_node;
      -- pointer to the current node
      old_node : list_node;  -- Node to dispose of
   begin
      while current /= null loop  -- For each item in the list
         old_node := current;      -- Item to dispose
         current  := current.next; -- Next node
         Dispose_Node(old_node);   -- Dispose of item
      end loop;
   end Release_Storage;
     
   function Handle(to_current_list : in list) return list_node is
     -- return a handle to the current node pointed to in the
     -- list.  If there is no current node pointed to, then
     -- the handle is set to the first item in the list.
   begin
      if to_current_list.current_node /= null then
         return to_current_list.current_node;
      else
         return to_current_list.first_node;
      end if;
   end Handle;
   
   procedure Go_To(the_handle : in list_node; for_the_list : in out list) is
     -- Set the list pointer to the requested handle point for
     -- the specified list.
   begin
      for_the_list.current_node := the_handle;
   end Go_To;

   procedure First (in_the_list : in out list) is
      -- Set the pointers in the list to the first object in
      -- the list.
   begin
      in_the_list.current_node := in_the_list.first_node;
        -- set to 1st
   end First;

   procedure Last  (in_the_list : in out list) is
      -- Set the pointers in the list to the last object in
      -- the list.
   begin
      in_the_list.current_node := in_the_list.last_node;
        -- set to last
   end Last;

   procedure Next    (in_the_list : in out list) is
      -- Move the pointer to the next item in the list.  If the
      -- pointer is not currently pointing at an item, the
      -- poiner is unmodified.
      -- The end of the list is indicated by the pointer pointing
      -- to a null value.  By inspecting the list, this case can
      -- be distinguished from the case of an empty list.
   begin
      if in_the_list.current_node /= null then
         in_the_list.current_node :=
            in_the_list.current_node.next;  -- Next
      end if;
   end Next;

   procedure Previous(in_the_list : in out list) is
      -- Move the pointer to the previou item in the list.  If
      -- the pointer is not currently pointing at an item, the
      -- pointer is unmodified.
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
      -- Return true when the iterator is moved beyond the end of
      -- the list, or beyond the start of the list.
   begin
      return of_the_list.current_node = null;  -- true if end
   end Is_End;

   function  Deliver (from_the_list : in list)
   return T is
      -- Return a copy of the current item pointed to by the
      -- iterator.
   begin
      return from_the_list.current_node.item;  -- current item
   end Deliver;

   procedure Insert  (into : in out list; the_data : in T) is
      -- This is complex due to the necessity of handling insertion
      -- at different places in the linked list.  The iterator only
      -- knows about the current position in the list.
      -- There are 4 cases to handle:
      --   On an empty list: need to update list's access values
      --                     "first" and "last" as well as update
      --                     the current position in the iterator.
      --   Beyond last item in list:  need to update the list's
      --                     access value "last" as well as update
      --                     the current position in the iterator.
      --   Before first item: need to update the list's access
      --                     value "first".
      --   In the middle of the list: no updating required to the
      --                     list's access values nor the current
      --                     position of the iterator.
      new_node: list_node;
      current : list_node := into.current_node; -- current element
      first   : list_node renames into.first_node;
      last    : list_node renames into.last_node;
   begin
      if current = null then  -- Empty list or last item
         if first = null then  -- empty list
            new_node := new Node'(null, the_data, null);
            first := new_node;
            last  := new_node;
            into.current_node := new_node;
         else  -- last item
            new_node := new Node'(last, the_data, null);
            last.all.next := new_node;
            last          := new_node;
            into.current_node := new_node;
         end if;  -- else for first.all = null
      else  -- current /= null
         new_node := new Node'(current.prev, the_data, current);
         if current.prev = null then  -- First item
            first         := new_node;
         else  -- middle of the list
            current.prev.next := new_node;
         end if;  -- else for current.prev = null
         current.prev     := new_node;
         -- into.current_node := new_node;  -- point to node just loaded
      end if;  -- else for current = null
      into.item_count := into.item_count + 1;
   end Insert;

   procedure Delete  (from_the_list : in out list) is
      -- There are two different pointers to fix: the forward
      -- pointer and the previous pointer.  Each of these cases
      -- leads to further options depending on whether the object
      -- deleted is the first, last or middle object in the list.
      current: list_node := from_the_list.current_node; -- current
      first  : list_node renames from_the_list.first_node;
      last   : list_node renames from_the_list.last_node;
   begin
      if current /= null then  -- something to delete
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
         if current.next /= null then  -- Fix current pointer:
            from_the_list.current_node := current.next;  -- next
         elsif current.prev /= null then
            from_the_list.current_node := current.prev; -- previous
         else
            from_the_list.current_node := null;  -- empty list
         end if;  -- elses for current.next /= null
         Dispose_Node(current);  -- Release storage
         from_the_list.item_count := from_the_list.item_count - 1;
      end if;  -- current /= null (something to delete)
   end Delete;

   procedure Replace (the_data:in T; for_the_list:in out list) is
      current : list_node := for_the_list.current_node; -- current
   begin
      if current /= null then  -- something to replace
         current.item := the_data;
      else  -- nothing to replace - insert instead
         Insert(into => for_the_list, the_data => the_data);
      end if;  -- current /= null (something to replace)
   end Replace;

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

   function Pool_Usage  return wide_string is
      -- storage pool usage as a block representation.
   begin
      return General_Storage_Pool.Pool_Usage(the_pool);
   end Pool_Usage;

begin
   null;
end Dynamic_Lists;
