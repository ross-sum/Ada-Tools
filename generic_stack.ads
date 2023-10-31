-----------------------------------------------------------------------
--                                                                   --
--                     G E N E R I C   S T A C K                     --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Ada.Finalization, Unchecked_Deallocation;
use  Ada.Finalization;
with General_Storage_Pool;  -- Caution: This method can be slow!!!
generic
type T is private;  -- any type for the stack
empty_item : T;  -- used for when popping off an empty stack
storage_size : General_Storage_Pool.Storage_Count := 524288;
package Generic_Stack is

   type stack is new Controlled with private;

   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   procedure Initialize (the_stack : in out stack );
   procedure Initialise (the_stack : in out stack; with_data: in T);
   procedure Finalize ( the_stack : in out stack );
   procedure Adjust ( the_stack : in out stack);

   procedure Clear(the_stack : in out stack);
   procedure Assign(the_stack : in stack; to : in out stack);
     -- perform a shallow copy of the stack (i.e. point one stack
     -- to the other).

   function "=" ( f : in stack; s : in stack ) return boolean;
     -- check if the two stacks contain the same thing.
   
   procedure Push(the_item : in T; onto : in out stack);
      -- Add the_item to the top of the stack.
   procedure Pop (the_item : out T; off_of : in out stack);
      -- Grab the most recently pushed item off (the top of) the stack.

   function Depth(of_the_stack : in stack) return natural;
      -- A count of the total number of items that have been pushed
      -- onto the stack.

   function Pool_Usage  return wide_string;
		-- storage pool usage as a block representation.

private

   procedure Release_Storage (for_the_stack : in out stack);

	-- set up the storage pool
   the_pool : General_Storage_Pool.general_pool
              (size => storage_size,
               start_monitoring_state => General_Storage_Pool.unmonitored);

   type node;  -- tentative declaration
   type stack_node is access all node;  -- pointer to the node
pragma Controlled(stack_node);
   type node is record
         prev : stack_node;   -- previous node
         item : T;           -- the physical item
      end record;
   for stack_node'Storage_Pool use the_pool;

   procedure Dispose_Node is
   new Unchecked_Deallocation(node, stack_node);

   type stack is new Controlled with record
         end_of_stack : aliased stack_node := null;  -- first item pushed on
         current_node : aliased stack_node := null;  -- most recent item pushed
         deep_copy    : boolean := true;
         item_count   : natural := 0;
      end record;

end Generic_Stack;