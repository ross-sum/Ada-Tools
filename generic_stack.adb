-----------------------------------------------------------------------
--                                                                   --
--                     G E N E R I C   S T A C K                     --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2023  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides a generic capability to push onto and pop  --
--  items  off of a stack.  To utilise, specify a type to  use  for  --
--  the  elements (either a base type or a record) to  be  operated  --
--  on.                                                              --
--                                                                   --
--  Version History:                                                 --
--  $Log$
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
--  Free  Software  Foundation, 51 Franklin  Street,  Fifth  Floor,  --
--  Boston, MA 02110-1301, USA.                                      --
--                                                                   --
-----------------------------------------------------------------------
-- with Ada.Finalization, Unchecked_Deallocation;
-- use  Ada.Finalization;
-- with General_Storage_Pool;  -- Caution: This method can be slow!!!
-- generic
-- type T is private;  -- any type for the stack
-- storage_size : General_Storage_Pool.Storage_Count := 524288;
package body Generic_Stack is

   -- type stack is new Controlled with private;

   -- private

   procedure Release_Storage ( for_the_stack : in out stack ) is
      current  : stack_node := for_the_stack.end_of_stack;
      -- pointer to the current node
      old_node : stack_node;  -- Node to dispose of
   begin
      while current /= null loop  -- For each item in the list
         old_node := current;      -- Item to dispose
         current  := current.prev; -- Previous node
         Dispose_Node(old_node);   -- Dispose of item
      end loop;
   end Release_Storage;

-- 	-- set up the storage pool
   -- the_pool : General_Storage_Pool.general_pool
   -- (size => storage_size,
   -- start_monitoring_state => General_Storage_Pool.unmonitored);

   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   procedure Initialize (the_stack : in out stack ) is
   begin
      the_stack.end_of_stack := null;  -- empty list
      the_stack.current_node := null;  -- empty list
      the_stack.item_count   := 0;
   end Initialize;
   
   procedure Initialise (the_stack : in out stack; with_data: in T) is
   begin
      the_stack.end_of_stack := new node'(null, with_data);
      the_stack.current_node := the_stack.end_of_stack;
      the_stack.item_count   := 1;
   end Initialise;
   
   procedure Finalize ( the_stack : in out stack ) is
   begin
      if the_stack.deep_copy then  -- only clean up when in
         Clear(the_stack);         -- a deep copy situation
      end if;
   end Finalize;
   
   procedure Adjust ( the_stack : in out stack) is
      current : stack_node := the_stack.end_of_stack; -- original stack
      top     : stack_node := null;      -- last created node (i.e. stack top)
      previous: stack_node := null;      -- previously created node
      bottom  : stack_node := null;      -- the first node
   begin
      if not the_stack.deep_copy then
         return;  -- only stick around in a deep copy situation
      end if;
      while current /= null loop
         top := new node'(previous, current.item);
         if bottom = null then bottom := top; end if;
         -- if previous /= null then previous.prev := top; end if;
         previous := top;
         current := current.prev;     -- Next node
      end loop;
      the_stack.end_of_stack   := bottom;   -- Update
      the_stack.current_node := top;
   end Adjust;

   procedure Clear(the_stack : in out stack) is
   begin
      if the_stack.end_of_stack /= null then
         Release_Storage(the_stack);
         the_stack.end_of_stack   := null;
         the_stack.current_node := null;
         the_stack.item_count   := 0;
      end if;
   end Clear;

   procedure Assign(the_stack : in stack; to : in out stack) is
     -- perform a shallow copy of the stack (i.e. point one stack
     -- to the other).
   begin
      to.deep_copy    := false;  -- don't allow it at the moment
      to.end_of_stack := the_stack.end_of_stack;
      to.current_node := the_stack.current_node;
      to.deep_copy    := true;  -- switch it back on
   end Assign;

   function "=" ( f : in stack; s : in stack ) return boolean is
     -- check if the two stacks contain the same thing.
      f_node : stack_node := f.end_of_stack;  -- first list
      s_node : stack_node := s.end_of_stack;  -- second list
   begin
      while f_node /= null and s_node /= null loop
         if f_node.item /= s_node.item then
            return false;        -- Different items
         end if;
         f_node := f_node.prev;
         s_node := s_node.prev;
      end loop;
      return f_node = s_node;  -- Both null if equal
   end "=";
   
   procedure Push(the_item : in T; onto : in out stack) is
      -- Add the_item to the top of the stack.
      new_node: stack_node;
      current : stack_node := onto.current_node; -- current element
      first   : stack_node renames onto.end_of_stack;
   begin
      if current = null and first = null
      then  -- the stack is empty
         new_node          := new Node'(null, the_item);
         onto.current_node := new_node;
         first             := new_node;
      else
         new_node          := new Node'(current, the_item);
         onto.current_node := new_node;
      end if;
      onto.item_count := onto.item_count + 1;
   end Push;
   
   procedure Pop (the_item : out T; off_of : in out stack) is
      -- Grab the most recently pushed item off (the top of) the stack.
      -- In doing so, delete the top of the stack and set the top
      -- of stack to the previous top of stack.
      current : stack_node := off_of.current_node;
   begin
      if off_of.current_node /= null
      then  -- Get the most recently pushed item
         the_item := off_of.current_node.item;
          -- Move the pointers back one and delete the old top of stack
         off_of.current_node := off_of.current_node.prev;
         Dispose_Node(current);  -- Release storage
         off_of.item_count := off_of.item_count - 1;
      else  -- nothing is on the stack!
         the_item := empty_item;
      end if;
   end Pop;
   
   function Depth(of_the_stack : in stack) return natural is
      -- A count of the total number of items that have been pushed
      -- onto the stack.
   begin
      return natural(of_the_stack.item_count);
   end Depth;

   function Pool_Usage  return wide_string is
      -- storage pool usage as a block representation.
   begin
      return General_Storage_Pool.Pool_Usage(the_pool);
   end Pool_Usage;
   
end Generic_Stack;