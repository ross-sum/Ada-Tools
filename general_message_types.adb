-----------------------------------------------------------------------
--                                                                   --
--             G E N E R A L _ M E S S A G E _ T Y P E S             --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package is a storage mechanism for message types.  It is   --
--  principally used by the VNET technology                          --
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
-- with dStrings;  use dStrings;
with Ada.Unchecked_Conversion;

-- generic
   -- type enum_message_types is (<>);

package body General_Message_Types is

   -- type message_string_array_type is
   -- array (enum_message_types) of text;
   -- type response_list_array_type is
   -- array (enum_message_types) of enum_message_types;

   message_string_array : message_string_array_type;
      -- This should be loaded with the textual names of
      -- the message types.
   response_type_list   : response_list_array_type;
      -- This should be loaded with the response for each
      -- message  type.

   procedure Initialise
   (with_string_array : in message_string_array_type;
   with_response_list : in response_list_array_type) is
   begin
      message_string_array := with_string_array;
      response_type_list   := with_response_list;
   end Initialise;

   function Command_To_Integer is new
   Ada.Unchecked_Conversion(enum_message_types, integer);

   function Message_Type(for_message_type : in text)
   return enum_message_types is
      -- get the matching message type for the text
      the_command : enum_message_types;
   begin
      the_command := enum_message_types'First;  -- default
      for command_number in enum_message_types'Range loop
         if for_message_type = message_string_array(command_number)
         or for_message_type =
         Put_Into_String(Command_To_Integer(command_number))
         then
            the_command := command_number;
            exit;  -- got it, so no point in continuing
         end if;
      end loop;
      return the_command;
   end Message_Type;

   function Message_Type(for_command : in enum_message_types;
   as_a_number : boolean := false) return text is
   begin
      if as_a_number then
         return Put_Into_String(Command_To_Integer(for_command));
      else -- want the text representation
         return message_string_array(for_command);
      end if;
   end Message_Type;

   function Response_Type(
   for_message_type : in enum_message_types)
   return enum_message_types is
   begin
      return response_type_list(for_message_type);
   end Response_Type;

   function Reply_In_Kind(to_the_message_type : in text)
   return text is
      -- reply in the same format as to_the_message_type, i.e. if
      -- it is numeric, then reply in numeric fomat, else reply
      -- in plain english format.
      message_type : ttext renames to_the_message_type;
   begin
      for command_number in enum_message_types'Range loop
         if message_type = message_string_array(command_number)
         then  -- reply is text - use same name for reply
            return message_type;
         elsif message_type =
         Put_Into_String(Command_To_Integer(command_number))
         then
            return Put_Into_String(
               Command_To_Integer(Response_Type(command_number)));
         end if;
      end loop;
      return message_type;
   end Reply_In_Kind;

begin
   null;
end General_Message_Types;
