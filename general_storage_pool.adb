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
   with Ada.Exceptions;            use Ada.Exceptions;
   with Ada.Wide_Text_IO;          use Ada.Wide_Text_IO;
   with Ada.Integer_Wide_Text_IO;  use Ada.Integer_Wide_Text_IO;
   -- with System.Storage_Pools;     use System.Storage_Pools;
   -- with System.Storage_Elements;  use System.Storage_Elements;
   -- use System;

   package body General_Storage_Pool is
   
      --    type monitoring_states is (monitored, unmonitored);
      --    type general_pool(size : Storage_Count;
      --    start_monitoring_state : monitoring_states) is
      --    new Root_Storage_Pool with private;
      -- 
      -- private
      -- 
      --    type integer_array is array(storage_count range <>)of integer;
      --    type boolean_array is array(storage_count range <>)of boolean;
      --    type general_pool(size : Storage_Count;
      --    start_monitoring_state : monitoring_states) is
      --    new Root_Storage_Pool with record
      --          free : storage_count;
      --          count : integer_array(1..size);
      --          used  : boolean_array(1..size);
      --          store : storage_array(1..size);
      --          block_size      : storage_count;  -- reserved ffu.
      --          first_available : storage_offset := 1;
      --       end record;
   
      monitoring : monitoring_states := unmonitored;
   
      procedure Put_Usage (pool : in general_pool) is
         NoItems : integer := 0;
         mark : constant array(boolean) of wide_character := ".*";
      begin
         if monitoring = monitored then
            for item in 1 .. pool.size loop
               put(mark(pool.used(item)));
               NoItems := NoItems + 1;
               if NoItems = 80 then
                  New_Line;
                  NoItems := 0;
               end if;
            end loop;
            Skip_Line;
         end if;
      end Put_Usage;
   
      function Pool_Usage (pool : in general_pool) return wide_string is
         col_width : constant natural := 80;
         separator : constant wide_character := wide_character'Val(16#0A#);
         mark      : constant array(boolean) of wide_character := ".*";
         result : wide_string(1..
         (Integer(pool.size) + Integer(pool.size) / col_width + 1));
         item_pos  : natural := 1;
         row_pos   : integer := 0;
      begin
         for item in 1 .. pool.size loop
            result(item_pos) := mark(pool.used(item));
            row_pos := row_pos + 1;
            if row_pos = 80 then
               item_pos := item_pos + 1;
               result(item_pos) := separator;
               row_pos := 0;
            end if;
            item_pos := item_pos + 1;
         end loop;
         return result;	
      end Pool_Usage;
   
      procedure  Allocate(pool : in out general_pool;
      storage_address : out address;
      SISE : in storage_count;
      align : in storage_count) is
         index : storage_offset;
      begin
         if monitoring = monitored then
            Set_Col(40);
            Put("Allocating "); Put(Integer(SISE), 2); Put(", ");
            Put(Integer(align), 1); Put("(Start "); 
            Put(Integer(pool.first_available), 2); Put("):");
            New_Line;
         end if;
         if pool.free < SISE then
            Raise_Exception(Pool_Error'Identity, "Not enough space");
         end if;
         index := align - pool.store(align)'Address mod align;
         if index < pool.first_available then
            index := pool.first_available;
         end if;
         while index < pool.size - SISE + 1 loop
            if pool.used(index .. index + SISE- 1) = (1..SISE=>false)
            then
               for item in index .. index + SISE - 1 loop
                  pool.used(item)  := true;
                  if monitoring = monitored 
                  then  -- only bother in this case
                     if pool.count(item) = integer'Last then
                        pool.count(item) := 1;
                     else
                        pool.count(item) := pool.count(item) + 1;
                     end if;
                  end if;
               end loop;
               pool.first_available := index + SISE;
               pool.free := pool.free - SISE;
               storage_address := pool.store(index)'Address;
               Put_Usage(pool);
               return;
            end if;
            index := index + align;
         end loop;
      end Allocate;
   
   
      procedure Deallocate(pool : in out general_pool;
      storage_address : in address;
      SISE : in storage_count;
      align : in storage_count) is
         index : storage_offset;
      begin
         index := storage_address - pool.store(1)'Address;
         if pool.first_available > index + 1 then
            pool.first_available := index+1;
         end if;
         if monitoring = monitored then
            Set_Col(40);
            Put("Deallocating "); Put(Integer(SISE), 2);
            Put(" (Start now "); 
            Put(Integer(pool.first_available), 2); Put(")");
            New_Line;
         end if;
         for item in 1 .. SISE loop
            pool.used(item + index) := false;
         end loop;
         pool.free := pool.free + SISE;
         Put_Usage(pool);
      end Deallocate;
   
   
      function Storage_Size(pool : in general_pool)
      return storage_count is
      begin
         return pool.size;
      end Storage_Size;
   
      procedure Set_Monitoring(to : in monitoring_states) is
      begin
         monitoring := to;
      end Set_Monitoring;
   
      function Monitoring_State return monitoring_states is
      begin
         return monitoring;
      end Monitoring_State;
   
      procedure Initialize(pool : in out general_pool) is
      begin
         if pool.start_monitoring_state /= unmonitored then
            monitoring := pool.start_monitoring_state;
         end if;
         if monitoring = monitored then
            Put_Line("Initialising pool of type general_pool. ");
            Put("Pool size is "); Put(Integer(pool.size), 0);
            New_Line;
         end if;
         pool.free := pool.size;
         for item in 1.. pool.size loop
            pool.count(item) := 0;
            pool.used(item)  := false;
         end loop;
      end Initialize;
   
      procedure Finalize(pool   : in out general_pool) is
         item_number : integer := 0;
      begin
         if monitoring = monitored then
            Put_Line("Finalising pool - usages were");
            for item in 1 .. pool.size loop
               Put(pool.count(item), 4);
               item_number := item_number + 1;
               if item_number = 20 then
                  New_Line;
                  item_number := 0;
               end if;
            end loop;
            New_Line;
         end if;
      end Finalize;
   
   begin
      null;
   end General_Storage_Pool;